<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");
String user = request.getParameter("username");
String pass = request.getParameter("password");
boolean ok = false;

try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT 1 FROM end_user WHERE Username = ? AND Password = ?")) {

    ps.setString(1, user);
    ps.setString(2, pass);

    try (ResultSet rs = ps.executeQuery()) {
        ok = rs.next();
    }
} catch (Exception e) {
    ok = false;
}

if (ok) {
    session.setAttribute("username", user);
    session.setAttribute("role", "user");
    response.sendRedirect("buyerSellerDashboard.jsp");
} else {
    response.sendRedirect("login.jsp?error=Invalid+credentials");
}
%>


