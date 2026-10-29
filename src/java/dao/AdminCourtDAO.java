package dao;

import dal.DbContext;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import models.Court;

/**
 * DAO cho chức năng Admin quản lý sân: lấy danh sách, tìm theo tên, thêm, sửa, ngừng/kích hoạt, xóa sân.
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
    //    (Ngừng hoạt động chỉ ẩn sân với khách, vẫn giữ dữ liệu. Muốn xóa hẳn thì dùng delete ở dưới.)
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

    // 7. Tìm sân theo tên: lấy các sân có tên CHỨA từ khóa (ví dụ "A" -> "Sân A", "Sân Ab")
    public List<Court> searchByName(String keyword) {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT CourtID, CourtName, SportType, PricePerHour, IsActive "
                   + "FROM Courts WHERE CourtName LIKE ? ORDER BY CourtID";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
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

    // 8. Đếm số lượt đặt của 1 sân (sân đã có lượt đặt thì không được xóa). Lỗi thì trả về -1
    public int countBookings(int courtId) {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE CourtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, courtId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            handle(e);
        }
        return -1;
    }

    // 9. Xóa hẳn 1 sân khỏi database
    public boolean delete(int id) {
        String sql = "DELETE FROM Courts WHERE CourtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            handle(e);
        }
        return false;
    }

    // 10. Đóng kết nối khi dùng xong (servlet gọi trong khối finally)
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