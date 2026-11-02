
package dao;

import dal.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import models.Court;

public class CourtDAO extends DbContext {

    public List<Court> searchCourts(String keyword, String sportType) {
        List<Court> courts = new ArrayList<>();

        String sql = "SELECT CourtID, CourtName, SportType, PricePerHour, IsActive "
                   + "FROM Courts "
                   + "WHERE CourtName LIKE ? "
                   + "AND (? = '' OR SportType = ?) "
                   + "ORDER BY CourtID";

        try {
            if (connection == null) {
                return courts;
            }

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, "%" + keyword + "%");
                ps.setString(2, sportType);
                ps.setString(3, sportType);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Court court = new Court(
                            rs.getInt("CourtID"),
                            rs.getString("CourtName"),
                            rs.getString("SportType"),
                            rs.getBigDecimal("PricePerHour"),
                            rs.getBoolean("IsActive")
                        );
                        courts.add(court);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return courts;
    }
}
