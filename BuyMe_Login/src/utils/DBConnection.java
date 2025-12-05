package utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL  = "jdbc:mysql://localhost:3306/buyme?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "balaji";
    private static final String PASS = "password123";

    static {
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }
        catch (Exception e) { throw new RuntimeException(e); }
    }

    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
