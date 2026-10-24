package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DbContext {
    // Khai báo đối tượng kết nối
    protected Connection connection;
    // Constructor
    public DbContext(){
        try {
            // Khai báo các thông số của Hệ quản trị CSDL cần làm việc
            String user = "sa";
            String password = "123";
            String url = "jdbc:sqlserver://ADMIN-PC\\MSSQLSERVER02;databaseName=SportBookingDB;encrypt=true;trustServerCertificate=true;";
            // Nạp JDBC driver từ package sqlserver_jdbc_.jar 
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            // Tiến hành kết nối
            connection = DriverManager.getConnection(url,user,password);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DbContext.class.getName()).log(Level.SEVERE,null,ex);
        }
    }
}
