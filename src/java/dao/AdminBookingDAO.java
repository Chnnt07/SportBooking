package dao;

import dal.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.Booking;

public class AdminBookingDAO {
    public List<Booking> findAll(String status) throws SQLException {
        List<Booking> result = new ArrayList<>();
        String sql = "SELECT b.BookingID,b.UserID,b.CourtID,b.BookingDate,b.StartTime,b.EndTime,b.TotalPrice,b.Status,b.CreatedAt, "
                + "u.FullName,u.Username,c.CourtName,c.SportType FROM Bookings b "
                + "JOIN Users u ON u.UserID=b.UserID JOIN Courts c ON c.CourtID=b.CourtID "
                + (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status) ? "" : "WHERE b.Status=? ")
                + "ORDER BY b.BookingDate DESC,b.StartTime DESC";
        try (DbContext db = new DbContext(); PreparedStatement ps = db.getConnection().prepareStatement(sql)) {
            if (sql.contains("WHERE")) ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = new Booking();
                    b.setBookingID(rs.getInt("BookingID")); b.setUserID(rs.getInt("UserID")); b.setCourtID(rs.getInt("CourtID"));
                    b.setBookingDate(rs.getString("BookingDate")); b.setStartTime(rs.getString("StartTime")); b.setEndTime(rs.getString("EndTime"));
                    b.setTotalPrice(rs.getDouble("TotalPrice")); b.setStatus(rs.getString("Status")); b.setCreatedAt(rs.getString("CreatedAt"));
                    b.setFullName(rs.getString("FullName")); b.setUsername(rs.getString("Username")); b.setCourtName(rs.getString("CourtName")); b.setSportType(rs.getString("SportType"));
                    result.add(b);
                }
            }
        }
        return result;
    }

    public boolean updateStatus(int bookingID, String status) throws SQLException {
        if (!"Confirmed".equals(status) && !"Cancelled".equals(status)) return false;
        try (DbContext db = new DbContext(); PreparedStatement ps = db.getConnection().prepareStatement("UPDATE Bookings SET Status=? WHERE BookingID=?")) {
            ps.setString(1, status); ps.setInt(2, bookingID); return ps.executeUpdate() == 1;
        }
    }

}
