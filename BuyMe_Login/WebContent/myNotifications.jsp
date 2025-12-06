<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%

    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;

    Connection conn = null;
    PreparedStatement psClosed = null;
    PreparedStatement psOpen   = null;
    PreparedStatement psTop    = null;
    ResultSet rsClosed = null;
    ResultSet rsOpen   = null;
    ResultSet rsTop    = null;
%>

<div class="page">
  <h2>My Notifications</h2>
  <p>This page summarizes auctions you&apos;re involved in: what you&apos;ve won, lost, and where you are currently outbid.</p>

<%
try {
    conn = DBConnection.getConnection();


    psClosed = conn.prepareStatement(
        "SELECT DISTINCT a.A_ID, a.Name, a.CloseDate, a.CloseTime, a.Reserve " +
        "FROM auction a " +
        "JOIN bids_on bo ON a.A_ID = bo.A_ID " +
        "JOIN bids b ON bo.BID_ID = b.BID_ID " +
        "JOIN places pl ON b.BID_ID = pl.BID_ID " +
        "WHERE pl.Username = ? AND a.Closed = 1 " +
        "ORDER BY a.CloseDate DESC, a.CloseTime DESC " +
        "LIMIT 20"
    );
    psClosed.setString(1, username);
    rsClosed = psClosed.executeQuery();

    psTop = conn.prepareStatement(
        "SELECT b.Price, pl.Username " +
        "FROM bids b " +
        "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
        "JOIN places pl ON b.BID_ID = pl.BID_ID " +
        "WHERE bo.A_ID = ? " +
        "ORDER BY b.Price DESC, b.Time ASC " +
        "LIMIT 1"
    );
%>

  <h3>Closed Auctions You Participated In</h3>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Auction ID</th>
      <th>Item</th>
      <th>Closed On</th>
      <th>Result</th>
      <th>Winning Bid</th>
      <th>View</th>
    </tr>

<%
    boolean anyClosed = false;
    while (rsClosed.next()) {
        anyClosed = true;
        int aId = rsClosed.getInt("A_ID");
        String name = rsClosed.getString("Name");
        java.sql.Date cd = rsClosed.getDate("CloseDate");
        java.sql.Time ct = rsClosed.getTime("CloseTime");
        float reserve = 0f;
        try {
            reserve = rsClosed.getFloat("Reserve");
        } catch (Exception ignore) {
            reserve = 0f;
        }

        String topUser = null;
        float topPrice = 0f;

        psTop.setInt(1, aId);
        rsTop = psTop.executeQuery();
        if (rsTop.next()) {
            topPrice = rsTop.getFloat("Price");
            topUser  = rsTop.getString("Username");
        }
        if (rsTop != null) { try { rsTop.close(); } catch (Exception e) {} }

        String result;
        String winStr = (topUser == null ? "-" : String.format("$%.2f", topPrice));

        if (topUser == null) {
            result = "Closed – no bids";
        } else if (reserve > 0 && topPrice < reserve) {
            result = String.format("Closed – reserve $%.2f not met", reserve);
        } else if (username.equals(topUser)) {
            result = "You won this auction";
        } else {
            result = "You were outbid";
        }
%>
    <tr>
      <td><%= aId %></td>
      <td><%= name %></td>
      <td><%= cd %> <%= ct %></td>
      <td><%= result %></td>
      <td><%= winStr %></td>
      <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View</a></td>
    </tr>
<%
    } 
    if (!anyClosed) {
%>
    <tr><td colspan="6">No closed auctions yet.</td></tr>
<%
    }
%>
  </table>

  <br/>

<%

    psOpen = conn.prepareStatement(
        "SELECT DISTINCT a.A_ID, a.Name, a.CloseDate, a.CloseTime " +
        "FROM auction a " +
        "JOIN bids_on bo ON a.A_ID = bo.A_ID " +
        "JOIN bids b ON bo.BID_ID = b.BID_ID " +
        "JOIN places pl ON b.BID_ID = pl.BID_ID " +
        "WHERE pl.Username = ? AND a.Closed = 0 " +
        "ORDER BY a.CloseDate, a.CloseTime"
    );
    psOpen.setString(1, username);
    rsOpen = psOpen.executeQuery();
%>

  <h3>Open Auctions You&apos;re Bidding In</h3>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Auction ID</th>
      <th>Item</th>
      <th>Closes</th>
      <th>Status</th>
      <th>Current Highest Bid</th>
      <th>View</th>
    </tr>
<%
    boolean anyOpen = false;
    while (rsOpen.next()) {
        anyOpen = true;
        int aId = rsOpen.getInt("A_ID");
        String name = rsOpen.getString("Name");
        java.sql.Date cd = rsOpen.getDate("CloseDate");
        java.sql.Time ct = rsOpen.getTime("CloseTime");

        String topUser = null;
        float topPrice = 0f;

        psTop.setInt(1, aId);
        rsTop = psTop.executeQuery();
        if (rsTop.next()) {
            topPrice = rsTop.getFloat("Price");
            topUser  = rsTop.getString("Username");
        }
        if (rsTop != null) { try { rsTop.close(); } catch (Exception e) {} }

        String status;
        if (topUser == null) {
            status = "No bids yet";
        } else if (username.equals(topUser)) {
            status = "You are currently highest bidder";
        } else {
            status = "You are currently outbid";
        }
%>
    <tr>
      <td><%= aId %></td>
      <td><%= name %></td>
      <td><%= cd %> <%= ct %></td>
      <td><%= status %></td>
      <td><%= (topUser == null ? "-" : String.format("$%.2f", topPrice)) %></td>
      <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View / Bid</a></td>
    </tr>
<%
    } 
    if (!anyOpen) {
%>
    <tr><td colspan="6">You are not bidding on any open auctions right now.</td></tr>
<%
    }

} catch (Exception e) {
%>
  <p style="color:red;">Error loading notifications: <%= e.getMessage() %></p>
<%
} finally {
    if (rsClosed != null) try { rsClosed.close(); } catch (Exception e) {}
    if (rsOpen   != null) try { rsOpen.close(); } catch (Exception e) {}
    if (psClosed != null) try { psClosed.close(); } catch (Exception e) {}
    if (psOpen   != null) try { psOpen.close(); } catch (Exception e) {}
    if (psTop    != null) try { psTop.close(); } catch (Exception e) {}
    if (conn     != null) try { conn.close(); } catch (Exception e) {}
}
%>

</div>
