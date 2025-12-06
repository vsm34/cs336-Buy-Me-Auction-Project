<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username  = request.getParameter("username");
    String password  = request.getParameter("password");
    String confirm   = request.getParameter("confirmPassword");
    String firstName = request.getParameter("firstName"); // currently unused
    String lastName  = request.getParameter("lastName");  // currently unused
    String email     = request.getParameter("email");     // currently unused

    // 1) Basic required-field validation
    if (username == null || password == null || confirm == null ||
        username.trim().isEmpty() || password.trim().isEmpty() || confirm.trim().isEmpty()) {

        response.sendRedirect("signup.jsp?error=Fill+in+all+fields");
        return;
    }

    // 2) Password confirmation
    if (!password.equals(confirm)) {
        response.sendRedirect("signup.jsp?error=Passwords+do+not+match");
        return;
    }

    boolean success = false;

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();

        // 3) Check if username already exists
        try (PreparedStatement check = conn.prepareStatement(
                 "SELECT 1 FROM end_user WHERE Username = ?")) {
            check.setString(1, username);

            try (ResultSet rs = check.executeQuery()) {
                if (rs.next()) {
                    response.sendRedirect("signup.jsp?error=Username+already+exists");
                    return;
                }
            }
        }

        // 4) Insert new user (schema: end_user(Username, Password))
        try (PreparedStatement insert = conn.prepareStatement(
                 "INSERT INTO end_user (Username, Password) VALUES (?, ?)")) {
            insert.setString(1, username);
            insert.setString(2, password);
            insert.executeUpdate();
        }

        // 5) Auto-login new user
        session.setAttribute("username", username);
        session.setAttribute("role", "user");

        success = true;   // <-- mark that everything worked

    } catch (Exception e) {
        e.printStackTrace(); // see Tomcat logs/console
    } finally {
        try {
            if (conn != null) conn.close();
        } catch (Exception ignore) {}
    }

    // Decide redirect AFTER the try/catch so nothing is unreachable
    if (success) {
        response.sendRedirect("buyerSellerDashboard.jsp");
    } else {
        response.sendRedirect("signup.jsp?error=Database+error+creating+account");
    }
%>

