package utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL  = "jdbc:mysql://localhost:3306/buyme?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASS = "Srisai12"; // replace locally

    static {
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }
        catch (ClassNotFoundException e) { throw new RuntimeException("MySQL JDBC Driver not found", e); }
    }
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
