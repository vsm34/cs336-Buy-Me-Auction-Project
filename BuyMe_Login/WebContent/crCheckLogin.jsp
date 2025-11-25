<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");
String cridParam = request.getParameter("crid");
String pass      = request.getParameter("password");

boolean ok = false;
String crid = null;

try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT CRID FROM customer_rep_create WHERE CRID = ? AND Password = ?")) {

    ps.setInt(1, Integer.parseInt(cridParam));
    ps.setString(2, pass);

    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            ok = true;
            crid = rs.getString("CRID");
        }
    }
} catch (Exception e) {
    ok = false;
}

if (ok) {
    session.setAttribute("username", "rep#" + crid);
    session.setAttribute("role", "cr");
    response.sendRedirect("crDashboard.jsp");
} else {
    response.sendRedirect("crLogin.jsp?error=Invalid+rep+credentials");
}
%>
