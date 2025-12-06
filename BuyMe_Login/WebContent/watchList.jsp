<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
if (role == null || !"user".equals(role) || currentUser == null) {
    response.sendRedirect("login.jsp?error=Please+log+in+to+see+your+watchlist");
    return;
}
String username = currentUser;
String action   = request.getParameter("action");
String message  = null;

try (Connection conn = DBConnection.getConnection()) {

    if ("add".equals(action)) {
        String aidParam = request.getParameter("A_ID");
        if (aidParam != null) {
            int aid = Integer.parseInt(aidParam);

            Integer alertId = null;


            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT Alert_ID FROM alertsets " +
                    "WHERE Username = ? AND isActive = 1 LIMIT 1")) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        alertId = rs.getInt("Alert_ID");
                    }
                }
            }

s
            if (alertId == null) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO alertsets (isActive, DateCreated, Username) " +
                        "VALUES (1, CURDATE(), ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, username);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            alertId = rs.getInt(1);
                        }
                    }
                }
            }


            if (alertId != null) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM watches WHERE Alert_ID = ? AND A_ID = ?")) {
                    ps.setInt(1, alertId);
                    ps.setInt(2, aid);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            try (PreparedStatement ins = conn.prepareStatement(
                                    "INSERT INTO watches (Alert_ID, A_ID) VALUES (?, ?)")) {
                                ins.setInt(1, alertId);
                                ins.setInt(2, aid);
                                ins.executeUpdate();
                                message = "Added auction " + aid + " to your watchlist.";
                            }
                        } else {
                            message = "This auction is already in your watchlist.";
                        }
                    }
                }
            }
        }
    } else if ("remove".equals(action)) {
        String aidParam = request.getParameter("A_ID");
        if (aidParam != null) {
            int aid = Integer.parseInt(aidParam);
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE w FROM watches w " +
                    "JOIN alertsets al ON w.Alert_ID = al.Alert_ID " +
                    "WHERE al.Username = ? AND w.A_ID = ?")) {
                ps.setString(1, username);
                ps.setInt(2, aid);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    message = "Removed auction " + aid + " from your watchlist.";
                } else {
                    message = "That auction was not in your watchlist.";
                }
            }
        }
    }
%>

<div class="page">
    <h2>My Watchlist / Alerts</h2>
    <% if (message != null) { %>
        <p style="color:green;"><%= message %></p>
    <% } %>

    <table border="1" cellpadding="6">
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Subcategory</th>
            <th>Price</th>
            <th>Close Date</th>
            <th>Close Time</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
<%
    try (PreparedStatement ps = conn.prepareStatement(
            "SELECT a.A_ID, a.Name, a.Subcategory, a.Price, " +
            "       a.CloseDate, a.CloseTime, a.Closed " +
            "FROM alertsets al " +
            "JOIN watches w ON al.Alert_ID = w.Alert_ID " +
            "JOIN auction a ON w.A_ID = a.A_ID " +
            "WHERE al.Username = ? AND al.isActive = 1 " +
            "ORDER BY a.CloseDate, a.CloseTime")) {
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
            <td><%= rs.getDate("CloseDate") %></td>
            <td><%= rs.getTime("CloseTime") %></td>
            <td><%= rs.getBoolean("Closed") ? "Closed" : "Open" %></td>
            <td>
                <a href="viewAuction.jsp?A_ID=<%= rs.getInt("A_ID") %>">View</a> |
                <a href="watchList.jsp?action=remove&A_ID=<%= rs.getInt("A_ID") %>">Remove</a>
            </td>
        </tr>
<%
            }
            if (!any) {
%>
        <tr><td colspan="8">You don’t have any items on your watchlist yet.</td></tr>
<%
            }
        }
    }
%>
    </table>
</div>

<%
} catch (Exception e) {
%>
    <p style="color:red;">Error loading watchlist: <%= e.getMessage() %></p>
<%
}
%>
