<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String cridStr   = request.getParameter("crid");
    String password  = request.getParameter("password");

    if (cridStr == null || password == null ||
        cridStr.trim().isEmpty() || password.trim().isEmpty()) {

        response.sendRedirect("crLogin.jsp?error=Please+enter+CRID+and+password");
        return;
    }

    int crid;
    try {
        crid = Integer.parseInt(cridStr.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("crLogin.jsp?error=CRID+must+be+a+number");
        return;
    }

    boolean ok = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT Password FROM customer_rep_create WHERE CRID = ?"
         )) {

        ps.setInt(1, crid);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String dbPass = rs.getString("Password");
                ok = password.equals(dbPass);
            } else {
                ok = false;   // no such CRID
            }
        }

    } catch (Exception e) {
        e.printStackTrace();   // show full stack trace in Tomcat console
        response.sendRedirect("crLogin.jsp?error=Database+error");
        return;
    }

    if (ok) {
        // For CR pages:
        //  - role is used by header.jsp to show the right nav
        //  - crid can be used by CR-only JSPs when querying tables like deletes, removes, etc.
        session.setAttribute("role", "cr");
        session.setAttribute("crid", crid);
        session.setAttribute("username", "CR-" + crid);  // just for display in header

        response.sendRedirect("crDashboard.jsp");
    } else {
        response.sendRedirect("crLogin.jsp?error=Invalid+credentials");
    }
%>
