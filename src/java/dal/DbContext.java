/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Trinh Ngoc Hieu
 */
public class DbContext implements AutoCloseable {
    protected Connection connection;
    public DbContext()
    {
        //@Students: You are allowed to edit user, pass, url variables to fit 
        //your system configuration
        //You can also add more methods for Database Interaction tasks. 
        //But we recommend you to do it in another class
        // For example : StudentDBContext extends DBContext , 
        //where StudentDBContext is located in dal package, 
        try {
            String user = "sa";
            String password = "123";
            String url = "jdbc:sqlserver://localhost:1433;databaseName=SportBookingDB;encrypt=true;trustServerCertificate=true;";
            // Nạp JDBC driver từ package sqlserver_jdbc_.jar 
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DbContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public Connection getConnection() { return connection; }
    @Override public void close() { try { if (connection != null) connection.close(); } catch (SQLException ignored) { } }
}
