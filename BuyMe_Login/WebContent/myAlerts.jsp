<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ include file="header.jsp" %>

<%
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp?error=Please+log+in+to+see+alerts");
        return;
    }

    String user = currentUser;
    String msg = request.getParameter("msg");
%>

<div class="page">
    <h2>My Alerts</h2>

    <% if (msg != null) { %>
        <p style="color:green;"><%= msg %></p>
    <% } %>

    <table border="1" cellpadding="6">
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Subcategory</th>
            <th>Price</th>
            <th>Close Date</th>
            <th>Close Time</th>
            <th>View</th>
        </tr>
<%
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "SELECT a.A_ID, a.Name, a.Subcategory, a.Price, a.CloseDate, a.CloseTime " +
           "FROM alertsets al " +
           "JOIN watches w ON al.Alert_ID = w.Alert_ID " +
           "JOIN auction a ON w.A_ID = a.A_ID " +
           "WHERE al.Username = ? AND al.isActive = 1 " +
           "ORDER BY a.CloseDate, a.CloseTime")) {

        ps.setString(1, user);
        try (ResultSet rs = ps.executeQuery()) {
            boolean any = false;
            while (rs.next()) {
                any = true;
%>
        <tr>
            <td><%= rs.getInt("A_ID") %></td>
            <td><%= rs.getString("Name") %></td>
            <td><%= rs.getString("Subcategory") %></td>
            <td>$<%= String.format("%.2f", rs.getFloat("Price")) %></td>
            <td><%= rs.getDate("CloseDate") %></td>
            <td><%= rs.getTime("CloseTime") %></td>
            <td><a href="viewAuction.jsp?A_ID=<%= rs.getInt("A_ID") %>">View</a></td>
        </tr>
<%
            }
            if (!any) {
%>
        <tr><td colspan="7">You don’t have any alerts yet.</td></tr>
<%
            }
        }
    } catch (Exception e) {
%>
        <tr><td colspan="7" style="color:red;">Error loading alerts: <%= e.getMessage() %></td></tr>
<%
    }
%>
    </table>
</div>
