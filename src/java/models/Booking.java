package models;

public class Booking {
    private int bookingID, userID, courtID;
    private String fullName, username, courtName, sportType, bookingDate, startTime, endTime, status, createdAt;
    private double totalPrice;

    public int getBookingID() { return bookingID; }
    public void setBookingID(int v) { bookingID = v; }
    public int getUserID() { return userID; }
    public void setUserID(int v) { userID = v; }
    public int getCourtID() { return courtID; }
    public void setCourtID(int v) { courtID = v; }
    public String getFullName() { return fullName; }
    public void setFullName(String v) { fullName = v; }
    public String getUsername() { return username; }
    public void setUsername(String v) { username = v; }
    public String getCourtName() { return courtName; }
    public void setCourtName(String v) { courtName = v; }
    public String getSportType() { return sportType; }
    public void setSportType(String v) { sportType = v; }
    public String getBookingDate() { return bookingDate; }
    public void setBookingDate(String v) { bookingDate = v; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String v) { startTime = v; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String v) { endTime = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { status = v; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String v) { createdAt = v; }
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double v) { totalPrice = v; }
}
