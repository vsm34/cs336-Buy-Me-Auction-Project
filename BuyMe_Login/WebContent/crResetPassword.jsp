<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="header.jsp" %>

<%
    // Must be logged in as customer rep
    if (role == null || !"cr".equals(role) || currentUser == null) {
        response.sendRedirect("crLogin.jsp");
        return;
    }

    String search = request.getParameter("search");
    if (search == null) search = "";
    String like = search.trim() + "%";
%>

<div class="page">
    <h2>Reset User Passwords</h2>

    <form method="get" action="crResetPassword.jsp" style="margin-bottom: 10px;">
        <label>Find user by username:
            <input type="text" name="search" value="<%= search %>" />
        </label>
        <button type="submit">Search</button>
        
    </form>

    <table border="1" cellspacing="0" cellpadding="6">
        <tr>
            <th>Username</th>
            <th>Current Password</th>
            <th>Last Reset By CRID</th>
            <th>New Password</th>
            <th>Action</th>
        </tr>

<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        // Join end_user with resets_pass so we know which CR last reset it (if any)
        String sql =
            "SELECT e.Username, e.Password, r.CRID " +
            "FROM end_user e " +
            "LEFT JOIN resets_pass r ON e.Username = r.Username ";

        if (!search.trim().isEmpty()) {
            sql += "WHERE e.Username LIKE ? ";
        }

        sql += "ORDER BY e.Username";

        ps = conn.prepareStatement(sql);
        if (!search.trim().isEmpty()) {
            ps.setString(1, like);
        }

        rs = ps.executeQuery();
        boolean any = false;

        while (rs.next()) {
            any = true;
            String uname   = rs.getString("Username");
            String curPass = rs.getString("Password");
            Integer lastCr = (Integer) rs.getObject("CRID");
%>
        <tr>
            <td><%= uname %></td>
            <td><%= curPass %></td>
            <td><%= (lastCr == null ? "-" : lastCr) %></td>
            <td>
                <form method="post" action="crResetPasswordHandler.jsp" style="margin:0;">
                    <input type="hidden" name="username" value="<%= uname %>" />
                    <input type="password" name="newPassword" required />
            </td>
            <td>
                    <button type="submit">Reset</button>
                </form>
            </td>
        </tr>
<%
        }

        if (!any) {
%>
        <tr>
            <td colspan="5">No users match that search.</td>
        </tr>
<%
        }

    } catch (Exception e) {
%>
        <tr>
            <td colspan="5" style="color:red;">
                Error loading users: <%= e.getMessage() %>
            </td>
        </tr>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
    </table>
</div>
