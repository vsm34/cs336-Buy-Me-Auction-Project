<%@ page import="java.sql.*, java.util.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Only logged-in end_user can see this page
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;

    Connection conn = null;
    PreparedStatement psAucs = null;
    PreparedStatement psTop = null;
    PreparedStatement psUserLast = null;
    PreparedStatement psAuto = null;
    ResultSet rsAucs = null;
    ResultSet rs = null;
%>

<div class="page">
    <h2>My Bids</h2>

    <table border="1" cellspacing="0" cellpadding="5">
        <tr>
            <th>Auction ID</th>
            <th>Item</th>
            <th>Your Last Bid</th>
            <th>Current Highest Bid</th>
            <th>Highest Bidder</th>
            <th>Status</th>
            <th>Alert</th>
            <th>Action</th>
        </tr>

<%
    try {
        conn = DBConnection.getConnection();

        // 1) All auctions this user has ever bid on
        psAucs = conn.prepareStatement(
            "SELECT DISTINCT bo.A_ID, a.Name, a.Closed, a.Reserve, a.CloseDate, a.CloseTime " +
            "FROM places pl " +
            "JOIN bids_on bo ON pl.BID_ID = bo.BID_ID " +
            "JOIN auction a ON a.A_ID = bo.A_ID " +
            "WHERE pl.Username = ?"
        );
        psAucs.setString(1, username);
        rsAucs = psAucs.executeQuery();

        // Prepared statements reused for each auction
        psTop = conn.prepareStatement(
            "SELECT b.Price, pl.Username " +
            "FROM bids b " +
            "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
            "JOIN places pl ON b.BID_ID = pl.BID_ID " +
            "WHERE bo.A_ID = ? " +
            "ORDER BY b.Price DESC, b.Time ASC " +
            "LIMIT 1"
        );

        psUserLast = conn.prepareStatement(
            "SELECT b.Price " +
            "FROM bids b " +
            "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
            "JOIN places pl ON b.BID_ID = pl.BID_ID " +
            "WHERE bo.A_ID = ? AND pl.Username = ? " +
            "ORDER BY b.Time DESC " +
            "LIMIT 1"
        );

        psAuto = conn.prepareStatement(
            "SELECT ab.Buy_Limit " +
            "FROM autobid ab " +
            "JOIN bids_on bo ON ab.BID_ID = bo.BID_ID " +
            "JOIN places pl ON ab.BID_ID = pl.BID_ID " +
            "WHERE bo.A_ID = ? AND pl.Username = ? " +
            "LIMIT 1"
        );

        while (rsAucs.next()) {
            int aId = rsAucs.getInt("A_ID");
            String itemName = rsAucs.getString("Name");
            boolean closed = rsAucs.getBoolean("Closed");
            float reserve = rsAucs.getFloat("Reserve");
            java.sql.Date cDate = rsAucs.getDate("CloseDate");
            java.sql.Time cTime = rsAucs.getTime("CloseTime");

            // 2) Highest bid overall for this auction
            float topPrice = 0f;
            String topUser = null;
            psTop.setInt(1, aId);
            rs = psTop.executeQuery();
            if (rs.next()) {
                topPrice = rs.getFloat("Price");
                topUser  = rs.getString("Username");
            }
            rs.close();

            // 3) This user's last bid on this auction
            Float userLastBid = null;
            psUserLast.setInt(1, aId);
            psUserLast.setString(2, username);
            rs = psUserLast.executeQuery();
            if (rs.next()) {
                userLastBid = rs.getFloat("Price");
            }
            rs.close();

            // 4) This user's auto-bid limit on this auction (if any)
            Float autoLimit = null;
            psAuto.setInt(1, aId);
            psAuto.setString(2, username);
            rs = psAuto.executeQuery();
            if (rs.next()) {
                autoLimit = rs.getFloat("Buy_Limit");
            }
            rs.close();

            String statusText = closed ? "Closed" : "Open";
            boolean userIsTop   = (topUser != null && topUser.equals(username));
            boolean reserveMet  = (topPrice >= reserve && topPrice > 0);
            String alert = "";

            // --- ALERT LOGIC ---

            // Manual outbid: auction still open AND user is not the highest bidder
            if (!closed && userLastBid != null && !userIsTop) {
                alert = "You have been outbid.";
            }

            // Auto-bid limit exceeded: auction open, user has auto-bid, someone else on top, and price > limit
            if (!closed && autoLimit != null && topPrice > autoLimit && !userIsTop) {
                if (!alert.isEmpty()) alert += " ";
                alert += "Your auto-bid limit has been exceeded.";
            }

            // Winner: auction closed, user is highest, and reserve met
            if (closed && userIsTop && reserveMet) {
                alert = "You have won this auction!";
            } else if (closed && !reserveMet && userLastBid != null) {
                // Optional informational message if user was involved but reserve not met
                if (alert.isEmpty()) {
                    alert = "Auction closed; reserve not met (no winner).";
                }
            }
%>
        <tr>
            <td><%= aId %></td>
            <td><%= itemName %></td>
            <td><%= (userLastBid == null ? "-" : String.format("$%.2f", userLastBid)) %></td>
            <td><%= (topPrice <= 0 ? "-" : String.format("$%.2f", topPrice)) %></td>
            <td><%= (topUser == null ? "-" : topUser) %></td>
            <td><%= statusText %></td>
            <td><%= alert %></td>
            <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View</a></td>
        </tr>
<%
        } // end while

    } catch (Exception e) {
%>
        <tr>
            <td colspan="8" style="color:red;">
                Error loading your bids: <%= e.getMessage() %>
            </td>
        </tr>
<%
    } finally {
        if (rsAucs != null) try { rsAucs.close(); } catch (Exception e) {}
        if (psAucs != null) try { psAucs.close(); } catch (Exception e) {}
        if (psTop != null) try { psTop.close(); } catch (Exception e) {}
        if (psUserLast != null) try { psUserLast.close(); } catch (Exception e) {}
        if (psAuto != null) try { psAuto.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
    </table>
</div>
