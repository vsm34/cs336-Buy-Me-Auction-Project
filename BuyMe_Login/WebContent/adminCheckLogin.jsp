<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");
String aidParam = request.getParameter("aid");
String pass     = request.getParameter("password");

boolean ok = false;
String adminId = null;

try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT AID FROM admin WHERE AID = ? AND Password = ?")) {

    ps.setInt(1, Integer.parseInt(aidParam));
    ps.setString(2, pass);

    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            ok = true;
            adminId = rs.getString("AID");
        }
    }
} catch (Exception e) {
    ok = false;
}

if (ok) {
    session.setAttribute("username", "admin#" + adminId);
    session.setAttribute("role", "admin");
    response.sendRedirect("adminDashboard.jsp");
} else {
    response.sendRedirect("adminLogin.jsp?error=Invalid+admin+credentials");
}
%>

