<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, utils.DBConnection" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<%
    String message = null;

    // Which section did the user click on from the dashboard?
    String view = request.getParameter("view");
    boolean showCreate = (view == null || "create".equalsIgnoreCase(view));
    boolean showDelete = (view == null || "delete".equalsIgnoreCase(view));

    // ====== HANDLE FORM ACTIONS (CREATE / DELETE) ======
    String method = request.getMethod();
    String action = request.getParameter("action");

    if ("POST".equalsIgnoreCase(method) && action != null) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
        	conn = DBConnection.getConnection();

            if ("create".equals(action)) {
                String password = request.getParameter("password");
                String aidStr   = request.getParameter("aid");

                if (password != null && !password.trim().isEmpty()
                        && aidStr != null && !aidStr.trim().isEmpty()) {

                    int aid = Integer.parseInt(aidStr.trim());
                    String sql = "INSERT INTO customer_rep_create (Password, AID) VALUES (?, ?)";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, password);
                    ps.setInt(2, aid);
                    int rows = ps.executeUpdate();

                    message = (rows > 0)
                            ? "Customer representative created successfully."
                            : "No representative was created.";
                } else {
                    message = "Please provide both a password and an AID.";
                }

            } else if ("delete".equals(action)) {
                String cridStr = request.getParameter("crid");
                if (cridStr != null && !cridStr.trim().isEmpty()) {
                    int crid = Integer.parseInt(cridStr.trim());
                    String sql = "DELETE FROM customer_rep_create WHERE CRID = ?";
                    ps = conn.prepareStatement(sql);
                    ps.setInt(1, crid);
                    int rows = ps.executeUpdate();

                    message = (rows > 0)
                            ? "Customer representative deleted successfully."
                            : "No representative was deleted (invalid CRID?).";
                } else {
                    message = "Missing CRID for delete.";
                }
            }

        } catch (NumberFormatException nfe) {
            message = "Invalid numeric value (AID or CRID).";
        } catch (Exception e) {
            message = "Error while processing request: " + e.getMessage();
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Manage Customer Representatives</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1   { margin-bottom: 10px; }
        table {
            border-collapse: collapse;
            width: 60%;
            margin-bottom: 20px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 8px 10px;
            text-align: left;
        }
        th { background-color: #f4f4f4; }
        .message {
            margin-bottom: 15px;
            padding: 8px 12px;
            border-radius: 4px;
            background-color: #eef;
        }
        .form-block {
            border: 1px solid #ccc;
            padding: 12px;
            max-width: 350px;
        }
        label { display: block; margin-top: 8px; }
        input[type=text], input[type=password] {
            width: 100%;
            padding: 5px;
            box-sizing: border-box;
        }
        input[type=submit] {
            margin-top: 10px;
            padding: 6px 12px;
        }
        form.inline { display: inline; }
        .section-title { margin-top: 25px; }
        .highlight { text-decoration: underline; }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>
<h1>Manage Customer Representatives</h1>

<% if (message != null) { %>
    <div class="message"><%= message %></div>
<% } %>

<!-- ====== LIST ALL CUSTOMER REPS (ALWAYS SHOWN) ====== -->
<h2 class="section-title">
    Existing Customer Reps
    <% if (showDelete) { %><span class="highlight">(Delete mode)</span><% } %>
</h2>
<table>
    <tr>
        <th>CRID</th>
        <th>Password</th>
        <th>AID</th>
        <% if (showDelete) { %>
        <th>Actions</th>
        <% } %>
    </tr>
    <%
        Connection conn2 = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        try {
        	conn2 = DBConnection.getConnection();

            String sql = "SELECT CRID, Password, AID FROM customer_rep_create ORDER BY CRID";
            ps2 = conn2.prepareStatement(sql);
            rs = ps2.executeQuery();

            while (rs.next()) {
                int crid = rs.getInt("CRID");
                String pwd = rs.getString("Password");
                int aid = rs.getInt("AID");
    %>
    <tr>
        <td><%= crid %></td>
        <td><%= pwd %></td>
        <td><%= aid %></td>
        <% if (showDelete) { %>
        <td>
            <!-- Delete Rep Form -->
            <form class="inline" method="post" action="adminManageReps.jsp?view=delete">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="crid" value="<%= crid %>">
                <input type="submit" value="Delete"
                       onclick="return confirm('Are you sure you want to delete rep CRID=<%= crid %>?');">
            </form>
        </td>
        <% } %>
    </tr>
    <%
            }
        } catch (Exception e) {
    %>
    <tr>
        <td colspan="<%= showDelete ? 4 : 3 %>">Error loading reps: <%= e.getMessage() %></td>
    </tr>
    <%
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps2 != null) ps2.close(); } catch (Exception ignored) {}
            try { if (conn2 != null) conn2.close(); } catch (Exception ignored) {}
        }
    %>
</table>

<!-- ====== CREATE NEW REP FORM (ONLY WHEN view=create OR NO VIEW) ====== -->
<% if (showCreate) { %>
<h2 class="section-title">
    Create New Customer Rep
    <span class="highlight">(Create mode)</span>
</h2>
<div class="form-block">
    <form method="post" action="adminManageReps.jsp?view=create">
        <input type="hidden" name="action" value="create">

        <label>
            Password:
            <input type="password" name="password" required>
        </label>

        <label>
            AID (Admin ID creating this rep):
            <input type="text" name="aid" required>
        </label>

        <input type="submit" value="Create Representative">
    </form>
</div>
<% } %>

</body>
</html>