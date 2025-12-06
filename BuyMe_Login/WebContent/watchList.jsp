<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Only logged-in end users may use watchlist / alerts
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp?error=Please+log+in+to+see+your+watchlist");
        return;
    }

    String username = currentUser;
    String action   = request.getParameter("action");
    String aParam   = request.getParameter("A_ID");
    String message  = null;

    try (Connection conn = DBConnection.getConnection()) {

        // Handle add/remove operations
        if (action != null && aParam != null && !aParam.trim().isEmpty()) {
            int aid = -1;
            try {
                aid = Integer.parseInt(aParam);
            } catch (NumberFormatException nfe) {
                aid = -1;
            }

            if (aid > 0) {
                if ("add".equals(action)) {
                    // 1) Ensure there is an active alertset row for this user
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

                    if (alertId == null) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO alertsets (Username) VALUES (?)",
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

                    // 2) Link that alert to this auction if not already present
                    if (alertId != null) {
                        boolean already = false;
                        try (PreparedStatement ps = conn.prepareStatement(
                                "SELECT 1 FROM watches WHERE Alert_ID = ? AND A_ID = ?")) {
                            ps.setInt(1, alertId);
                            ps.setInt(2, aid);
                            try (ResultSet rs = ps.executeQuery()) {
                                already = rs.next();
                            }
                        }

                        if (!already) {
                            try (PreparedStatement ins = conn.prepareStatement(
                                    "INSERT INTO watches (Alert_ID, A_ID) VALUES (?, ?)")) {
                                ins.setInt(1, alertId);
                                ins.setInt(2, aid);
                                ins.executeUpdate();
                            }

                            // Build a friendly message using the auction's “keywords”
                            String itemName = null;
                            String subcat   = null;
                            String attr     = null;
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "SELECT Name, Subcategory, SubAttribute " +
                                    "FROM auction WHERE A_ID = ?")) {
                                ps.setInt(1, aid);
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        itemName = rs.getString("Name");
                                        subcat   = rs.getString("Subcategory");
                                        attr     = rs.getString("SubAttribute");
                                    }
                                }
                            }
                            if (itemName != null) {
                                message = "Created alert for \"" + itemName + "\""
                                       + (subcat != null ? " in category " + subcat : "")
                                       + (attr != null ? " (" + attr + ")" : "")
                                       + ". You will be notified when similar items become available.";
                            } else {
                                message = "Added auction " + aid + " to your watchlist / alerts.";
                            }
                        } else {
                            message = "This auction is already in your watchlist / alerts.";
                        }
                    }
                } else if ("remove".equals(action)) {
                    // Remove this auction from any alerts owned by the user
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE w FROM watches w " +
                            "JOIN alertsets al ON w.Alert_ID = al.Alert_ID " +
                            "WHERE al.Username = ? AND w.A_ID = ?")) {
                        ps.setString(1, username);
                        ps.setInt(2, aid);
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            message = "Removed auction " + aid + " from your watchlist / alerts.";
                        } else {
                            message = "Auction " + aid + " was not in your watchlist.";
                        }
                    }
                }
            }
        }
%>

<div class="page">
    <h2>My Watchlist / Alerts</h2>
    <p>
        This page shows all <strong>item alerts</strong> you have created.
        Each row is an auction you chose as an example of something you like.
        We treat the item&apos;s <strong>name</strong> and <strong>attributes</strong>
        (e.g., keywords like <em>Nike</em>, <em>Size 10</em>, <em>Red</em>) as the
        alert keywords. Your <a href="myNotifications.jsp">Notifications</a> page
        uses these alerts to show new auctions with matching category and attributes.
    </p>

    <% if (message != null) { %>
        <p style="color:green;"><%= message %></p>
    <% } %>

    <table border="1" cellpadding="6">
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Subcategory</th>
            <th>Attributes</th>
            <th>Price</th>
            <th>Close Date</th>
            <th>Close Time</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
<%
        // Now list all watched auctions for this user
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT a.A_ID, a.Name, a.Subcategory, a.SubAttribute, a.Price, " +
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
                    int aid = rs.getInt("A_ID");
%>
        <tr>
            <td><%= aid %></td>
            <td><%= rs.getString("Name") %></td>
            <td><%= rs.getString("Subcategory") %></td>
            <td><%= rs.getString("SubAttribute") %></td>
            <td>$<%= String.format("%.2f", rs.getFloat("Price")) %></td>
            <td><%= rs.getDate("CloseDate") %></td>
            <td><%= rs.getTime("CloseTime") %></td>
            <td><%= (rs.getBoolean("Closed") ? "Closed" : "Open") %></td>
            <td>
                <a href="viewAuction.jsp?A_ID=<%= aid %>">View</a> |
                <a href="watchList.jsp?action=remove&A_ID=<%= aid %>">Remove</a>
            </td>
        </tr>
<%
                }
                if (!any) {
%>
        <tr>
            <td colspan="9">
                You don’t have any items in your watchlist / alerts yet.
                Go to <a href="browseAuctions.jsp">Browse</a> and click
                “Set Alert” on items you like.
            </td>
        </tr>
<%
                }
            }
        }
    } catch (Exception e) {
%>
        <tr><td colspan="9" style="color:red;">Error loading watchlist: <%= e.getMessage() %></td></tr>
<%
    }
%>
    </table>
</div>
