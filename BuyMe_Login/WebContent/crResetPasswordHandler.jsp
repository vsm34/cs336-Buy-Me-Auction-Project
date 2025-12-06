<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
String username = request.getParameter("username");
String newPass  = request.getParameter("newPassword");
String role = (String) session.getAttribute("role");
Integer cridObj = (Integer) session.getAttribute("crid");
if (!"cr".equals(role) || cridObj == null) {
    response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
    return;
}
int crid = cridObj;
if (username == null || username.trim().isEmpty()
        || newPass == null || newPass.trim().isEmpty()) {
    String enc = java.net.URLEncoder.encode("Missing data for reset", "UTF-8");
    response.sendRedirect("crResetPassword.jsp?msg=" + enc);
    return;
}
String msgPlain;
try (Connection conn = DBConnection.getConnection()) {
    conn.setAutoCommit(false);
    try (PreparedStatement ps = conn.prepareStatement(
            "UPDATE end_user SET Password = ? WHERE Username = ?")) {
        ps.setString(1, newPass);
        ps.setString(2, username);
        int updated = ps.executeUpdate();
        if (updated == 0) {
            conn.rollback();
            msgPlain = "User " + username + " not found";
            String enc = java.net.URLEncoder.encode(msgPlain, "UTF-8");
            response.sendRedirect("crResetPassword.jsp?msg=" + enc);
            return;
        }
    }
    try (PreparedStatement ps2 = conn.prepareStatement(
            "INSERT INTO resets_pass (Username, CRID) VALUES (?, ?) " +
            "ON DUPLICATE KEY UPDATE CRID = VALUES(CRID)")) {
        ps2.setString(1, username);
        ps2.setInt(2, crid);
        ps2.executeUpdate();
    }
    conn.commit();
    msgPlain = "Password reset for " + username;
} catch (Exception e) {
    msgPlain = "Error resetting password for " + username;
}
String enc = java.net.URLEncoder.encode(msgPlain, "UTF-8");
response.sendRedirect("crResetPassword.jsp?msg=" + enc);
%>