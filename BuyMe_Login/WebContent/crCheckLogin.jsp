<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String cridParam = request.getParameter("crid");
    String pass      = request.getParameter("password");

   
    if (cridParam == null || cridParam.trim().isEmpty()
        || pass == null || pass.trim().isEmpty()) {

        response.sendRedirect("crLogin.jsp?error=" +
            java.net.URLEncoder.encode("Please enter CRID and password.", "UTF-8"));
        return;
    }

    boolean ok = false;
    int crid   = -1;

    try {
        int cridInt = Integer.parseInt(cridParam.trim());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT CRID FROM customer_rep_create " +
                 "WHERE CRID = ? AND Password = ?")) {

            ps.setInt(1, cridInt);
            ps.setString(2, pass);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ok   = true;
                    crid = rs.getInt("CRID");
                }
            }
        }
    } catch (NumberFormatException nfe) {
        ok = false;
    } catch (Exception e) {
        ok = false;
        e.printStackTrace();  
    }

    if (ok) {

        session.setAttribute("username", "rep#" + crid);
        session.setAttribute("role", "cr");
        session.setAttribute("crid", Integer.valueOf(crid));

        response.sendRedirect("crDashboard.jsp");
    } else {
        response.sendRedirect("crLogin.jsp?error=" +
            java.net.URLEncoder.encode("Invalid rep credentials.", "UTF-8"));
    }
%>
