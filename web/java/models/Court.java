package models;

import java.math.BigDecimal;

/**
 * Model của bảng Courts (mỗi đối tượng Court là một dòng trong bảng).
 * Tên thuộc tính được JSP dùng trực tiếp qua EL, ví dụ: ${c.courtName}, ${c.active}
 */
public class Court {

    private int courtId;            // CourtID
    private String courtName;       // CourtName
    private String sportType;       // SportType (Badminton / Pickleball / Football)
    private BigDecimal pricePerHour; // PricePerHour
    private boolean active;         // IsActive (true = đang hoạt động)

    public Court() {
    }

    public Court(int courtId, String courtName, String sportType,
                 BigDecimal pricePerHour, boolean active) {
        this.courtId = courtId;
        this.courtName = courtName;
        this.sportType = sportType;
        this.pricePerHour = pricePerHour;
        this.active = active;
    }

    public int getCourtId() {
        return courtId;
    }

    public void setCourtId(int courtId) {
        this.courtId = courtId;
    }

    public String getCourtName() {
        return courtName;
    }

    public void setCourtName(String courtName) {
        this.courtName = courtName;
    }

    public String getSportType() {
        return sportType;
    }

    public void setSportType(String sportType) {
        this.sportType = sportType;
    }

    public BigDecimal getPricePerHour() {
        return pricePerHour;
    }

    public void setPricePerHour(BigDecimal pricePerHour) {
        this.pricePerHour = pricePerHour;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
