<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,utils.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe - Reset User Passwords</title>
    <style>
        .page {
            margin: 24px;
            font-family: Arial, sans-serif;
        }
        h2 {
            margin-bottom: 16px;
        }
        .msg {
            margin-bottom: 12px;
            color: #006600;
        }
        .err {
            margin-bottom: 12px;
            color: #cc0000;
        }
        table {
            border-collapse: collapse;
            width: 80%;
        }
        th, td {
            border: 1px solid #000;
            padding: 8px 10px;
            text-align: left;
        }
        th {
            background-color: #f0f0f0;
        }
        input[type="password"] {
            width: 140px;
            padding: 4px;
        }
        button {
            padding: 4px 10px;
            border: none;
            border-radius: 4px;
            background-color: #0073e6;
            color: #fff;
            cursor: pointer;
        }
        button:hover {
            background-color: #005bb5;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
Integer cridObj = (Integer) session.getAttribute("crid");
if (!"cr".equals(role) || cridObj == null) {
    response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
    return;
}
int crid = cridObj;

String msg = request.getParameter("msg");
String err = request.getParameter("err");

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<div class="page">
    <h2>Reset User Passwords</h2>

    <%
        if (msg != null) {
    %>
        <div class="msg"><%= msg %></div>
    <%
        }
        if (err != null) {
    %>
        <div class="err"><%= err %></div>
    <%
        }
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT r.Username, e.Password, r.CRID " +
                         "FROM resets_pass r JOIN end_user e ON r.Username = e.Username";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
    %>

    <table>
        <tr>
            <th>Username</th>
            <th>Current Password</th>
            <th>Last Reset By CRID</th>
            <th>New Password</th>
            <th>Action</th>
        </tr>
        <%
            boolean any = false;
            while (rs.next()) {
                any = true;
                String u = rs.getString("Username");
                String currentPass = rs.getString("Password");
                int lastCrid = rs.getInt("CRID");
        %>
        <tr>
            <td><%= u %></td>
            <td><%= currentPass %></td>
            <td><%= lastCrid %></td>
            <td>
                <form action="crResetPasswordHandler.jsp" method="post" style="margin:0;">
                    <input type="hidden" name="username" value="<%= u %>">
                    <input type="password" name="newPassword" required>
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
            <td colspan="5">No password reset entries found.</td>
        </tr>
        <%
            }
        } catch (Exception e) {
        %>
        <div class="err">Error loading reset list.</div>
        <%
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (ps != null) ps.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
        %>
    </table>
</div>

</body>
</html>
