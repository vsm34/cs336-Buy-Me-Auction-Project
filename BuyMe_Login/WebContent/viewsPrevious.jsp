<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
if (role == null || !"user".equals(role) || currentUser == null) {
    response.sendRedirect("login.jsp?error=Please+log+in+to+see+recent+views");
    return;
}
String username = currentUser;
%>

<div class="page">
    <h2>Recently Viewed Auctions</h2>

    <table border="1" cellpadding="6">
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Subcategory</th>
            <th>Price</th>
            <th>Last Bid Seen Time</th>
            <th>Bid Amount</th>
            <th>View</th>
        </tr>
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT a.A_ID, a.Name, a.Subcategory, a.Price, " +
         "       b.Time, b.Price AS BidPrice " +
         "FROM views_previous vp " +
         "JOIN bids b     ON vp.BID_ID = b.BID_ID " +
         "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
         "JOIN auction a  ON bo.A_ID  = a.A_ID " +
         "WHERE vp.Username = ? " +
         "ORDER BY b.Time DESC")) {

    ps.setString(1, username);
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
            <td><%= rs.getTime("Time") %></td>
            <td>$<%= String.format("%.2f", rs.getFloat("BidPrice")) %></td>
            <td><a href="viewAuction.jsp?A_ID=<%= rs.getInt("A_ID") %>">View</a></td>
        </tr>
<%
        }
        if (!any) {
%>
        <tr><td colspan="7">You haven’t viewed any auctions with bids yet.</td></tr>
<%
        }
    }
} catch (Exception e) {
%>
        <tr><td colspan="7" style="color:red;">Error loading recently viewed: <%= e.getMessage() %></td></tr>
<%
}
%>
    </table>
</div>
