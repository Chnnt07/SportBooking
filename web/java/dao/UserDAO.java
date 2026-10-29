package dao;

import dal.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import models.User;

public class UserDAO extends DbContext {

    public User findByUsername(String username)
            throws SQLException {

        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }

        String sql = "SELECT UserID, FullName, Username, "
                + "PasswordHash, Role "
                + "FROM dbo.Users WHERE Username = ?";

        try (PreparedStatement ps =
                     connection.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();

                    user.setUserID(rs.getInt("UserID"));
                    user.setFullName(rs.getString("FullName"));
                    user.setUsername(rs.getString("Username"));
                    user.setPasswordHash(
                            rs.getString("PasswordHash"));
                    user.setRole(rs.getString("Role"));

                    return user;
                }

                return null;
            }
        } finally {
            closeConnection();
        }
    }

    public boolean createCustomer(
            String fullName, String username, String passwordHash)
            throws SQLException {

        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }

        try {
            String checkSql =
                    "SELECT 1 FROM dbo.Users WHERE Username = ?";

            try (PreparedStatement check =
                         connection.prepareStatement(checkSql)) {

                check.setString(1, username);

                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        return false;
                    }
                }
            }

            String insertSql =
                    "INSERT INTO dbo.Users "
                    + "(FullName, Username, PasswordHash, Role) "
                    + "VALUES (?, ?, ?, 'CUSTOMER')";

            try (PreparedStatement ps =
                         connection.prepareStatement(insertSql)) {

                ps.setString(1, fullName);
                ps.setString(2, username);
                ps.setString(3, passwordHash);

                return ps.executeUpdate() == 1;
            }
        } finally {
            closeConnection();
        }
    }

    private void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}