package dao;

import dal.DbContext;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import models.Booking;
import models.Court;

/**
 * DAO đặt sân của khách hàng (feature/customer-booking).
 * Giờ mở cửa 05:00-24:00, EndTime 00:00 nghĩa là 24:00.
 * Mọi mốc giờ trong code tính bằng số phút từ 00:00 (05:00 = 300, 24:00 = 1440).
 */
public class BookingDAO {

    public static final int OPEN_MIN = 5 * 60;
    public static final int CLOSE_MIN = 24 * 60;
    public static final int STEP_MIN = 15;          // bước chọn giờ
    public static final int MIN_DURATION_MIN = 30;  // thời lượng tối thiểu

    public enum Result { OK, INVALID_TIME, PAST, COURT_UNAVAILABLE, OVERLAP, ERROR }

    // Số phút của StartTime / EndTime (EndTime 00:00 được hiểu là 1440)
    private static final String START_MIN_SQL =
            "DATEDIFF(MINUTE, CAST('00:00:00' AS TIME(0)), StartTime)";
    private static final String END_MIN_SQL =
            "(CASE WHEN EndTime='00:00:00' THEN 1440 "
            + "ELSE DATEDIFF(MINUTE, CAST('00:00:00' AS TIME(0)), EndTime) END)";

    // ---------- Tiện ích giờ ----------

    public static String formatMinutes(int minutes) {
        return String.format("%02d:%02d", minutes / 60, minutes % 60);
    }

    /** "HH:mm" -> số phút ("24:00" = 1440). Sai định dạng trả null. */
    public static Integer parseMinutes(String v) {
        try {
            String[] p = v.trim().split(":");
            if (p.length != 2) {
                return null;
            }
            int h = Integer.parseInt(p[0]);
            int m = Integer.parseInt(p[1]);
            if (h < 0 || h > 24 || m < 0 || m > 59 || (h == 24 && m != 0)) {
                return null;
            }
            return h * 60 + m;
        } catch (Exception e) {
            return null;
        }
    }

    /** Giờ hợp lệ: trong giờ mở cửa, đúng bước 15 phút, dài tối thiểu 30 phút. */
    public static boolean validRange(int startMin, int endMin) {
        return startMin >= OPEN_MIN && endMin <= CLOSE_MIN
                && startMin % STEP_MIN == 0 && endMin % STEP_MIN == 0
                && endMin - startMin >= MIN_DURATION_MIN;
    }

    private static boolean isPast(LocalDate date, int startMin) {
        return LocalDateTime.of(date, LocalTime.ofSecondOfDay(startMin * 60L))
                .isBefore(LocalDateTime.now());
    }

    private static Time toSqlTime(int minutes) {
        return Time.valueOf(LocalTime.ofSecondOfDay((minutes % 1440) * 60L));
    }

    /** "05:30:00" -> "05:30". EndTime 00:00 hiển thị là 24:00. */
    private static String showTime(String raw, boolean isEnd) {
        if (raw == null || raw.length() < 5) {
            return raw;
        }
        String hhmm = raw.substring(0, 5);
        return (isEnd && hhmm.equals("00:00")) ? "24:00" : hhmm;
    }

    // ---------- Sân (dùng cho form đặt sân) ----------

    private static Court mapCourt(ResultSet rs) throws SQLException {
        return new Court(rs.getInt("CourtID"), rs.getString("CourtName"),
                rs.getString("SportType"), rs.getBigDecimal("PricePerHour"),
                rs.getBoolean("IsActive"));
    }

    /** Các sân đang hoạt động, để khách chọn. */
    public List<Court> getActiveCourts() throws SQLException {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT CourtID,CourtName,SportType,PricePerHour,IsActive "
                + "FROM Courts WHERE IsActive=1 ORDER BY SportType, CourtName";
        try (DbContext db = new DbContext();
                PreparedStatement ps = db.getConnection().prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCourt(rs));
            }
        }
        return list;
    }

    /** Một sân đang hoạt động theo ID, không có/ngừng hoạt động trả null. */
    public Court findActiveCourt(int courtId) throws SQLException {
        String sql = "SELECT CourtID,CourtName,SportType,PricePerHour,IsActive "
                + "FROM Courts WHERE CourtID=? AND IsActive=1";
        try (DbContext db = new DbContext();
                PreparedStatement ps = db.getConnection().prepareStatement(sql)) {
            ps.setInt(1, courtId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCourt(rs) : null;
            }
        }
    }

    // ---------- Lịch trống ----------

    /** Các khoảng giờ đã có người đặt (PENDING/CONFIRMED), dạng "HH:mm - HH:mm", theo thứ tự giờ. */
    public List<String> getBusyRanges(int courtId, LocalDate date) throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT " + START_MIN_SQL + " AS s, " + END_MIN_SQL + " AS e "
                + "FROM Bookings WHERE CourtID=? AND BookingDate=? "
                + "AND Status IN ('PENDING','CONFIRMED') ORDER BY StartTime";
        try (DbContext db = new DbContext();
                PreparedStatement ps = db.getConnection().prepareStatement(sql)) {
            ps.setInt(1, courtId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(formatMinutes(rs.getInt("s")) + " - " + formatMinutes(rs.getInt("e")));
                }
            }
        }
        return list;
    }

    // ---------- Đặt sân ----------

    /**
     * Tạo booking (PENDING). Tổng tiền = giá/giờ x số giờ.
     * Chống đặt trùng: khoảng [start,end) không được chồng lên booking PENDING/CONFIRMED nào
     * của cùng sân + ngày. Vì bảng không có unique index cho khoảng giờ, việc kiểm tra và INSERT
     * chạy trong một transaction có khóa sp_getapplock theo (sân, ngày), nên hai người đặt cùng lúc
     * không thể cùng lọt qua bước kiểm tra.
     */
    public Result createBooking(int userId, int courtId, LocalDate date, int startMin, int endMin) {
        if (!validRange(startMin, endMin)) {
            return Result.INVALID_TIME;
        }
        if (isPast(date, startMin)) {
            return Result.PAST;
        }
        try (DbContext db = new DbContext()) {
            Connection con = db.getConnection();
            if (con == null) {
                return Result.ERROR;
            }
            con.setAutoCommit(false);
            try {
                if (!acquireLock(con, courtId, date)) {
                    con.rollback();
                    return Result.ERROR;
                }
                BigDecimal pricePerHour = activeCourtPrice(con, courtId);
                if (pricePerHour == null) {
                    con.rollback();
                    return Result.COURT_UNAVAILABLE;
                }
                if (hasOverlap(con, courtId, date, startMin, endMin)) {
                    con.rollback();
                    return Result.OVERLAP;
                }
                BigDecimal total = pricePerHour
                        .multiply(BigDecimal.valueOf(endMin - startMin))
                        .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
                String sql = "INSERT INTO Bookings(UserID,CourtID,BookingDate,StartTime,EndTime,TotalPrice) "
                        + "VALUES(?,?,?,?,?,?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, courtId);
                    ps.setDate(3, Date.valueOf(date));
                    ps.setTime(4, toSqlTime(startMin));
                    ps.setTime(5, toSqlTime(endMin));
                    ps.setBigDecimal(6, total);
                    ps.executeUpdate();
                }
                con.commit();
                return Result.OK;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return Result.ERROR;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Result.ERROR;
        }
    }

    private boolean acquireLock(Connection con, int courtId, LocalDate date) throws SQLException {
        try (CallableStatement cs = con.prepareCall("{? = call sp_getapplock(?,?,?,?)}")) {
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, "booking:" + courtId + ":" + date);
            cs.setString(3, "Exclusive");
            cs.setString(4, "Transaction");
            cs.setInt(5, 5000);
            cs.execute();
            return cs.getInt(1) >= 0;
        }
    }

    private BigDecimal activeCourtPrice(Connection con, int courtId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT PricePerHour FROM Courts WHERE CourtID=? AND IsActive=1")) {
            ps.setInt(1, courtId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : null;
            }
        }
    }

    private boolean hasOverlap(Connection con, int courtId, LocalDate date, int startMin, int endMin)
            throws SQLException {
        String sql = "SELECT 1 FROM Bookings WHERE CourtID=? AND BookingDate=? "
                + "AND Status IN ('PENDING','CONFIRMED') "
                + "AND " + START_MIN_SQL + " < ? AND " + END_MIN_SQL + " > ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courtId);
            ps.setDate(2, Date.valueOf(date));
            ps.setInt(3, endMin);
            ps.setInt(4, startMin);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ---------- Lịch sử & hủy ----------

    /** Lịch sử đặt sân của một khách, mới nhất trước. */
    public List<Booking> getBookingsByUser(int userId) throws SQLException {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.BookingID,b.UserID,b.CourtID,b.BookingDate,b.StartTime,b.EndTime,"
                + "b.TotalPrice,b.Status,b.CreatedAt,u.FullName,u.Username,c.CourtName,c.SportType "
                + "FROM Bookings b JOIN Users u ON u.UserID=b.UserID "
                + "JOIN Courts c ON c.CourtID=b.CourtID "
                + "WHERE b.UserID=? ORDER BY b.BookingDate DESC, b.StartTime DESC, b.BookingID DESC";
        try (DbContext db = new DbContext();
                PreparedStatement ps = db.getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = new Booking();
                    b.setBookingID(rs.getInt("BookingID"));
                    b.setUserID(rs.getInt("UserID"));
                    b.setCourtID(rs.getInt("CourtID"));
                    b.setBookingDate(rs.getString("BookingDate"));
                    b.setStartTime(showTime(rs.getString("StartTime"), false));
                    b.setEndTime(showTime(rs.getString("EndTime"), true));
                    b.setTotalPrice(rs.getDouble("TotalPrice"));
                    b.setStatus(rs.getString("Status").toUpperCase());
                    b.setCreatedAt(rs.getString("CreatedAt"));
                    b.setFullName(rs.getString("FullName"));
                    b.setUsername(rs.getString("Username"));
                    b.setCourtName(rs.getString("CourtName"));
                    b.setSportType(rs.getString("SportType"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    /**
     * Hủy booking của chính mình. Chỉ hủy được khi còn PENDING/CONFIRMED và chưa đến giờ bắt đầu.
     * Điều kiện UserID chặn hủy booking của người khác.
     */
    public boolean cancelMyBooking(int bookingId, int userId) throws SQLException {
        try (DbContext db = new DbContext()) {
            Connection con = db.getConnection();
            String select = "SELECT BookingDate, StartTime FROM Bookings "
                    + "WHERE BookingID=? AND UserID=? AND Status IN ('PENDING','CONFIRMED')";
            try (PreparedStatement ps = con.prepareStatement(select)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return false;
                    }
                    LocalDateTime start = LocalDateTime.of(
                            rs.getDate("BookingDate").toLocalDate(),
                            rs.getTime("StartTime").toLocalTime());
                    if (!start.isAfter(LocalDateTime.now())) {
                        return false;
                    }
                }
            }
            String update = "UPDATE Bookings SET Status='CANCELLED' "
                    + "WHERE BookingID=? AND UserID=? AND Status IN ('PENDING','CONFIRMED')";
            try (PreparedStatement ps = con.prepareStatement(update)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                return ps.executeUpdate() > 0;
            }
        }
    }
}
