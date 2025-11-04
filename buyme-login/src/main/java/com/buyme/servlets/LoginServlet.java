package com.buyme.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class LoginServlet extends HttpServlet {
  // TODO: set your local DB credentials & schema
  private static final String JDBC_URL  = "jdbc:mysql://localhost:3306/buyme?useSSL=false&serverTimezone=UTC";
  private static final String JDBC_USER = "testuser";
  private static final String JDBC_PASS = "testpass";

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String username = req.getParameter("username");
    String password = req.getParameter("password");

    if (username == null || password == null || username.isBlank() || password.isBlank()) {
      req.setAttribute("error", "Please enter username and password.");
      req.getRequestDispatcher("login.jsp").forward(req, resp);
      return;
    }

    boolean ok = false;
    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS);
         PreparedStatement ps = conn.prepareStatement(
             "SELECT 1 FROM users WHERE username = ? AND password = ? LIMIT 1")) {
      ps.setString(1, username);
      ps.setString(2, password); // plaintext allowed for Deliverable 2
      try (ResultSet rs = ps.executeQuery()) { ok = rs.next(); }
    } catch (SQLException e) {
      req.setAttribute("error", "DB error: " + e.getMessage());
      req.getRequestDispatcher("login.jsp").forward(req, resp);
      return;
    }

    if (ok) {
      HttpSession session = req.getSession(true);
      session.setAttribute("username", username);
      resp.sendRedirect("dashboard.jsp");
    } else {
      req.setAttribute("error", "Invalid credentials.");
      req.getRequestDispatcher("login.jsp").forward(req, resp);
    }
  }

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.getRequestDispatcher("login.jsp").forward(req, resp);
  }
}
