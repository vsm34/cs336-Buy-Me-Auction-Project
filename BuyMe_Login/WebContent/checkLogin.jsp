<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username == null || password == null ||
        username.trim().isEmpty() || password.trim().isEmpty()) {

        response.sendRedirect("login.jsp?error=Please+enter+username+and+password");
        return;
    }

    boolean ok = false;
    String debugMsg = null;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT Password FROM end_user WHERE Username = ?"
         )) {

        ps.setString(1, username);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String dbPass = rs.getString("Password");
                if (password.equals(dbPass)) {
                    ok = true;
                } else {
                    debugMsg = "Wrong password";
                }
            } else {
                debugMsg = "No such user in end_user";
            }
        }

    } catch (Exception e) {
        e.printStackTrace(); // shows in Tomcat console
        response.sendRedirect("login.jsp?error=Database+error");
        return;
    }

    if (ok) {
        session.setAttribute("username", username);
        session.setAttribute("role", "user");   // for header.jsp
        response.sendRedirect("buyerSellerDashboard.jsp");
    } else {
        // while debugging, include reason in query string (you can remove later)
        if (debugMsg == null) debugMsg = "Invalid credentials";
        response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode(debugMsg, "UTF-8"));
    }
%>


