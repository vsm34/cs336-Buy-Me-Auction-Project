<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="header.jsp" %>

<%
    String crRole = (String) session.getAttribute("role");
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(crRole) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
        return;
    }

    String msg = request.getParameter("msg");
    if (msg == null) msg = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset User Accounts</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { margin-bottom: 10px; }
        table { border-collapse: collapse; width: 100%; max-width: 1100px; }
        th, td { border: 1px solid #ccc; padding: 8px 10px; text-align: left; }
        th { background-color: #f2f2f2; }
        input[type="text"], input[type="password"] { width: 100%; box-sizing: border-box; padding: 4px 6px; }
        .btn-save { background-color: #1976d2; color: white; border: none; padding: 4px 10px; cursor: pointer; }
        .btn-delete { background-color: #d32f2f; color: white; border: none; padding: 4px 10px; cursor: pointer; }
        .msg { margin-bottom: 10px; color: green; }
        .error { margin-bottom: 10px; color: red; }
    </style>
</head>
<body>

<h1>Reset User Accounts</h1>

<%
    if (!msg.isEmpty()) {
%>
    <div class="msg"><%= msg %></div>
<%
    }
%>

<table>
    <tr>
        <th>Current Username</th>
        <th>Current Password</th>
        <th>New Username</th>
        <th>New Password</th>
        <th>Actions</th>
    </tr>

<%
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT username, password FROM End_User ORDER BY username";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()) {
            String uname = rs.getString("username");
            String pwd = rs.getString("password");
%>
    <tr>
        <td><%= uname %></td>
        <td><%= pwd %></td>
        <td>
            <form action="crResetPasswordHandler.jsp" method="post" style="display:inline;">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="currentUsername" value="<%= uname %>">
                <input type="text" name="newUsername" placeholder="leave blank to keep same">
        </td>
        <td>
                <input type="text" name="newPassword" placeholder="leave blank to keep same">
        </td>
        <td>
                <button type="submit" class="btn-save">Save</button>
            </form>

            <form action="crResetPasswordHandler.jsp" method="post" style="display:inline;margin-left:6px;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="currentUsername" value="<%= uname %>">
                <button type="submit" class="btn-delete">Delete User</button>
            </form>
        </td>
    </tr>
<%
        }
    } catch (Exception e) {
%>
    <tr>
        <td colspan="5" class="error">Error loading users.</td>
    </tr>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
</table>

</body>
</html>
