<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Must be logged in as a normal end_user
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;
    String aIdStr = request.getParameter("A_ID");

    if (aIdStr == null) {
        out.println("<p style='color:red;'>No auction selected.</p>");
        return;
    }

    int A_ID;
    try {
        A_ID = Integer.parseInt(aIdStr);
    } catch (NumberFormatException e) {
        out.println("<p style='color:red;'>Invalid auction ID.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement psAuction = null;
    PreparedStatement psTop = null;
    PreparedStatement psBids = null;
    PreparedStatement psView = null;
    ResultSet rsAuction = null;
    ResultSet rsTop = null;
    ResultSet rsBids = null;

    String auctionName = null;
    String seller = null;
    String subcat = null;
    String subAttr = null;
    java.sql.Date closeDate = null;
    java.sql.Time closeTime = null;
    boolean closed = false;
    float startPrice = 0f;
    float reserve = 0f;
    float displayPrice = 0f;   // what we show as "Current Price"
    float topPrice = 0f;       // highest bid, if any
    String topUser = null;     // username of highest bidder, if any
    boolean hasAnyBid = false;
    String outcomeMessage = null;  // winner / reserve message
    Integer lastBidIdForView = null; // for views_previous logging
%>

<%
try {
    conn = DBConnection.getConnection();

    // 1) Load auction + seller + whether it should be closed by time
    psAuction = conn.prepareStatement(
        "SELECT a.*, " +
        "       p.Username AS SellerUsername, " +
        "       TIMESTAMP(a.CloseDate, a.CloseTime) <= NOW() AS ShouldClose " +
        "FROM auction a " +
        "LEFT JOIN posts p ON a.A_ID = p.A_ID " +
        "WHERE a.A_ID = ?"
    );
    psAuction.setInt(1, A_ID);
    rsAuction = psAuction.executeQuery();

    if (!rsAuction.next()) {
%>
        <p style="color:red;">Auction not found.</p>
<%
        rsAuction.close();
        psAuction.close();
        conn.close();
        return;
    }

    auctionName = rsAuction.getString("Name");
    startPrice  = rsAuction.getFloat("Price");
    reserve     = rsAuction.getFloat("Reserve");
    closed      = rsAuction.getBoolean("Closed");
    closeDate   = rsAuction.getDate("CloseDate");
    closeTime   = rsAuction.getTime("CloseTime");
    seller      = rsAuction.getString("SellerUsername");
    subcat      = rsAuction.getString("Subcategory");
    subAttr     = rsAuction.getString("SubAttribute");
    boolean shouldClose = rsAuction.getBoolean("ShouldClose");

    rsAuction.close();
    psAuction.close();

    // If time has passed but Closed flag isn't set yet, close it now in DB
    if (!closed && shouldClose) {
        closed = true;
        PreparedStatement psUpdate = conn.prepareStatement(
            "UPDATE auction SET Closed = 1 WHERE A_ID = ?"
        );
        psUpdate.setInt(1, A_ID);
        psUpdate.executeUpdate();
        psUpdate.close();
    }

    // 2) Compute current highest bid (and highest bidder)
    displayPrice = startPrice; // default to starting price

    psTop = conn.prepareStatement(
        "SELECT b.Price, pl.Username " +
        "FROM bids b " +
        "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
        "JOIN places pl ON b.BID_ID = pl.BID_ID " +
        "WHERE bo.A_ID = ? " +
        "ORDER BY b.Price DESC, b.Time ASC " +
        "LIMIT 1"
    );
    psTop.setInt(1, A_ID);
    rsTop = psTop.executeQuery();
    if (rsTop.next()) {
        topPrice = rsTop.getFloat("Price");
        topUser  = rsTop.getString("Username");
        displayPrice = topPrice;
        hasAnyBid = true;
    }
    rsTop.close();
    psTop.close();

    // 3) Decide outcome message (winner / reserve not met) if closed
    if (closed) {
        if (!hasAnyBid) {
            outcomeMessage = "Auction closed. No bids were placed; no winner.";
        } else {
            boolean reserveMet = (topPrice >= reserve);
            if (!reserveMet) {
                outcomeMessage = String.format(
                    "Auction closed. Reserve price of $%.2f was not met; no winner.",
                    reserve
                );
            } else if (topUser != null && topUser.equals(username)) {
                outcomeMessage = String.format(
                    "Auction closed. You won this auction with a bid of $%.2f!",
                    topPrice
                );
            } else {
                outcomeMessage = String.format(
                    "Auction closed. Winning bid was $%.2f.",
                    topPrice
                );
            }
        }
    }
%>

<div class="page">
    <h2>Auction: <%= auctionName %></h2>

    <p><b>Seller:</b> <%= (seller != null ? seller : "Unknown") %></p>
    <p><b>Subcategory:</b> <%= (subcat != null ? subcat : "-") %></p>
    <p><b>Attribute:</b> <%= (subAttr != null ? subAttr : "-") %></p>

    <p><b>Current Price (starting price if no bids yet):</b>
        $<%= String.format("%.2f", displayPrice) %></p>

    <p><b>Closes:</b> <%= closeDate %> <%= closeTime %></p>
    <p><b>Status:</b> <%= closed ? "Closed" : "Open" %></p>

    <% if (closed && outcomeMessage != null) { %>
        <p style="color:blue;"><%= outcomeMessage %></p>
    <% } %>

    <% if (!closed) { %>
        <p>
            <a href="placeBid.jsp?A_ID=<%= A_ID %>">Place a Bid</a> |
            <a href="watchList.jsp?action=add&A_ID=<%= A_ID %>">Add to Watchlist</a>
        </p>
    <% } else { %>
        <p style="color:gray;">
            This auction is closed. You can still see the bid history below.
        </p>
    <% } %>

    <h3>Bid History</h3>

    <table border="1" cellspacing="0" cellpadding="5">
        <tr>
            <th>Bidder</th>
            <th>Amount</th>
            <th>Time</th>
        </tr>
<%
    // 4) Full bid history (highest first)
    psBids = conn.prepareStatement(
        "SELECT b.BID_ID, b.Price, b.Time, pl.Username " +
        "FROM bids b " +
        "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
        "JOIN places pl ON b.BID_ID = pl.BID_ID " +
        "WHERE bo.A_ID = ? " +
        "ORDER BY b.Price DESC, b.Time ASC"
    );
    psBids.setInt(1, A_ID);
    rsBids = psBids.executeQuery();

    boolean historyHasAnyBid = false;
    while (rsBids.next()) {
        historyHasAnyBid = true;
        int bidId = rsBids.getInt("BID_ID");
        if (lastBidIdForView == null) {
            // first row is highest
            lastBidIdForView = bidId;
        }
%>
        <tr>
            <td><%= rsBids.getString("Username") %></td>
            <td>$<%= String.format("%.2f", rsBids.getFloat("Price")) %></td>
            <td><%= rsBids.getTime("Time") %></td>
        </tr>
<%
    }
    rsBids.close();
    psBids.close();

    // 5) Log this view into views_previous (if there is at least one bid)
    if (historyHasAnyBid && lastBidIdForView != null) {
        try {
            psView = conn.prepareStatement(
                "INSERT IGNORE INTO views_previous (Username, BID_ID) VALUES (?, ?)"
            );
            psView.setString(1, username);
            psView.setInt(2, lastBidIdForView);
            psView.executeUpdate();
        } catch (SQLException eIgnore) {
            // ignore duplicate key
        } finally {
            if (psView != null) try { psView.close(); } catch (Exception e) {}
        }
    }

} catch (Exception e) {
%>
        <tr>
            <td colspan="3" style="color:red;">
                Error loading bids: <%= e.getMessage() %>
            </td>
        </tr>
<%
} finally {
    if (rsAuction != null) try { rsAuction.close(); } catch (Exception e) {}
    if (rsTop != null) try { rsTop.close(); } catch (Exception e) {}
    if (rsBids != null) try { rsBids.close(); } catch (Exception e) {}
    if (psAuction != null) try { psAuction.close(); } catch (Exception e) {}
    if (psTop != null) try { psTop.close(); } catch (Exception e) {}
    if (psBids != null) try { psBids.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
    </table>
</div>
