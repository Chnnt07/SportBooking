package dal;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Kết nối SQL Server dùng chung cho toàn bộ DAO.
 *
 * Mặc định: localhost:1433, database SportBookingDB, user sa, mật khẩu 123.
 * Nếu máy của bạn khác (ví dụ mật khẩu sa khác), KHÔNG sửa file này.
 * Hãy tạo file  C:\Users\<tên bạn>\sportbooking-db.properties  với nội dung:
 *
 *     db.user=sa
 *     db.password=mat_khau_cua_ban
 *     db.url=jdbc:sqlserver://localhost:1433;databaseName=SportBookingDB;encrypt=true;trustServerCertificate=true;
 *
 * File này nằm ngoài project nên không bao giờ bị commit hay ghi đè khi đổi nhánh.
 * Chỉ cần ghi các khóa muốn thay đổi; khóa nào thiếu sẽ dùng giá trị mặc định.
 */
public class DbContext implements AutoCloseable {

    private static final Logger LOG = Logger.getLogger(DbContext.class.getName());

    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "123";
    private static final String DEFAULT_URL
            = "jdbc:sqlserver://localhost:1433;databaseName=SportBookingDB;"
            + "encrypt=true;trustServerCertificate=true;";

    protected Connection connection;

    public DbContext() {
        Properties p = new Properties();
        p.setProperty("db.user", DEFAULT_USER);
        p.setProperty("db.password", DEFAULT_PASSWORD);
        p.setProperty("db.url", DEFAULT_URL);

        // Ghi đè bằng file riêng của từng máy (nếu có).
        Path file = Paths.get(System.getProperty("user.home"), "sportbooking-db.properties");
        if (Files.isRegularFile(file)) {
            try (FileInputStream in = new FileInputStream(file.toFile())) {
                p.load(in);
            } catch (IOException ex) {
                LOG.log(Level.WARNING, "Không đọc được " + file + ", dùng cấu hình mặc định.", ex);
            }
        }

        String url = p.getProperty("db.url").trim();
        String user = p.getProperty("db.user").trim();
        String password = p.getProperty("db.password").trim();

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException ex) {
            LOG.log(Level.SEVERE, "Thiếu thư viện mssql-jdbc trong project (Libraries).", ex);
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Không kết nối được SQL Server (url=" + url
                    + ", user=" + user + "): " + ex.getMessage(), ex);
        }
    }

    public Connection getConnection() {
        return connection;
    }

    @Override
    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ignored) {
        }
    }
}
