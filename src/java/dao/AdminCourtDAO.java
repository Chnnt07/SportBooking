package dao;

import dal.DbContext;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import models.Court;

/**
 * DAO cho chức năng Admin quản lý sân: lấy danh sách, thêm, sửa, ngừng/kích hoạt sân.
 * Kế thừa DbContext nên có sẵn biến "connection" để làm việc với database.
 */
public class AdminCourtDAO extends DbContext {

    // Lỗi gần nhất khi làm việc với database (null nếu không có lỗi) -> servlet hiện lên trang
    private String lastError = null;

    public String getLastError() {
        return lastError;
    }

    // Ghi nhớ lỗi để hiện lên trang, đồng thời in ra log Tomcat
    private void handle(Exception e) {
        if (connection == null) {
            lastError = "Không kết nối được database (xem dòng SEVERE trong log Tomcat).";
        } else {
            lastError = e.getMessage() != null ? e.getMessage() : e.toString();
        }
        e.printStackTrace();
    }

    // Chuyển 1 dòng dữ liệu trong ResultSet thành 1 đối tượng Court
    private Court toCourt(ResultSet rs) throws Exception {
        return new Court(
                rs.getInt("CourtID"),
                rs.getString("CourtName"),
                rs.getString("SportType"),
                rs.getBigDecimal("PricePerHour"),
                rs.getBoolean("IsActive"));
    }

    // 1. Lấy tất cả sân (kể cả sân đã ngừng hoạt động)
    public List<Court> getAll() {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT CourtID, CourtName, SportType, PricePerHour, IsActive "
                   + "FROM Courts ORDER BY CourtID";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(toCourt(rs));
            }
        } catch (Exception e) {
            handle(e);
        }
        return list;
    }

    // 2. Lấy 1 sân theo id (không thấy thì trả về null)
    public Court getById(int id) {
        String sql = "SELECT CourtID, CourtName, SportType, PricePerHour, IsActive "
                   + "FROM Courts WHERE CourtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return toCourt(rs);
                }
            }
        } catch (Exception e) {
            handle(e);
        }
        return null;
    }

    // 3. Kiểm tra tên sân đã tồn tại chưa (bỏ qua chính sân có id = excludeId; khi thêm mới truyền 0)
    public boolean nameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Courts WHERE CourtName = ? AND CourtID <> ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            handle(e);
        }
        return false;
    }

    // 4. Thêm sân mới (mặc định đang hoạt động)
    public boolean insert(String name, String sportType, BigDecimal price) {
        String sql = "INSERT INTO Courts (CourtName, SportType, PricePerHour, IsActive) "
                   + "VALUES (?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, sportType);
            ps.setBigDecimal(3, price);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            handle(e);
        }
        return false;
    }

    // 5. Sửa thông tin sân
    public boolean update(int id, String name, String sportType, BigDecimal price) {
        String sql = "UPDATE Courts SET CourtName = ?, SportType = ?, PricePerHour = ? "
                   + "WHERE CourtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, sportType);
            ps.setBigDecimal(3, price);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            handle(e);
        }
        return false;
    }

    // 6. Ngừng hoạt động (active = false) hoặc kích hoạt lại (active = true)
    //    Không xóa sân khỏi database vì các booking cũ vẫn tham chiếu tới sân này.
    public boolean setActive(int id, boolean active) {
        String sql = "UPDATE Courts SET IsActive = ? WHERE CourtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            handle(e);
        }
        return false;
    }

    // 7. Tìm sân theo tên (tên chứa từ khóa, không phân biệt hoa/thường).
    //    Từ khóa rỗng thì trả về tất cả sân.
    public List<Court> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAll();
        }
        List<Court> list = new ArrayList<>();
        String sql = "SELECT CourtID, CourtName, SportType, PricePerHour, IsActive "
                   + "FROM Courts WHERE CourtName LIKE ? ORDER BY CourtID";

        // Các ký tự đặc biệt của LIKE (% _ [) được bọc trong [] để tìm đúng như người dùng gõ
        String pattern = "%" + keyword.trim()
                .replace("[", "[[]")
                .replace("%", "[%]")
                .replace("_", "[_]") + "%";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(toCourt(rs));
                }
            }
        } catch (Exception e) {
            handle(e);
        }
        return list;
    }

    // 8. Xóa sân. Bảng Bookings tham chiếu tới Courts nên phải xóa các booking của sân trước,
    //    rồi mới xóa sân. Hai bước nằm trong 1 giao dịch: lỗi ở bước nào thì hoàn tác cả hai.
    //    Trả về số booking đã bị xóa kèm theo sân, hoặc -1 nếu xóa thất bại.
    public int deleteCourt(int id) {
        try {
            connection.setAutoCommit(false);

            int deletedBookings;
            try (PreparedStatement ps = connection.prepareStatement(
                    "DELETE FROM Bookings WHERE CourtID = ?")) {
                ps.setInt(1, id);
                deletedBookings = ps.executeUpdate();
            }

            int deletedCourts;
            try (PreparedStatement ps = connection.prepareStatement(
                    "DELETE FROM Courts WHERE CourtID = ?")) {
                ps.setInt(1, id);
                deletedCourts = ps.executeUpdate();
            }

            if (deletedCourts == 0) {           // không có sân nào bị xóa -> hoàn tác
                connection.rollback();
                lastError = "Không tìm thấy sân.";
                return -1;
            }
            connection.commit();
            return deletedBookings;

        } catch (Exception e) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            handle(e);
            return -1;
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // 9. Đóng kết nối khi dùng xong (servlet gọi trong khối finally)
    public void close() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (Exception e) {
            handle(e);
        }
    }
}
