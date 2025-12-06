package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // ⚠️ Make sure the DB name here matches your schema: "buyme"
    private static final String URL =
        "jdbc:mysql://localhost:3306/buyme?useSSL=false&serverTimezone=UTC";

    // ⚠️ Change these to whatever you use in MySQL Workbench
    private static final String USER = "root";          // or your MySQL username
    private static final String PASSWORD = "root"; // "" if no password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

