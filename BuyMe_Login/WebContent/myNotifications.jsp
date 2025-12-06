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
    PreparedStatement psClosed    = null;
    PreparedStatement psOpen      = null;
    PreparedStatement psTop       = null;
    PreparedStatement psAvailable = null;
    ResultSet rsClosed = null;
    ResultSet rsOpen   = null;
    ResultSet rsTop    = null;
    ResultSet rsAvail  = null;
%>

<div class="page">
  <h2>My Notifications</h2>
 

<%
try {
    conn = DBConnection.getConnection();

    /* ---------------------------------------------------------
       1) CLOSED AUCTIONS YOU PARTICIPATED IN
       --------------------------------------------------------- */
    psClosed = conn.prepareStatement(
        "SELECT DISTINCT a.A_ID, a.Name, a.CloseDate, a.CloseTime, a.reserve " +
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
            reserve = rsClosed.getFloat("reserve");
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
    /* ---------------------------------------------------------
       2) OPEN AUCTIONS YOU'RE BIDDING IN
       --------------------------------------------------------- */
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
%>
  </table>

  <br/>

<%
    /* ---------------------------------------------------------
       3) NEW AUCTIONS MATCHING YOUR ITEM ALERTS
          Brand + shoe type + attributes (size/color)
       --------------------------------------------------------- */

    psAvailable = conn.prepareStatement(
        "SELECT DISTINCT s.Alert_ID, " +
        "       t.A_ID   AS TemplateAID, t.Name AS TemplateName, " +
        "       a.A_ID   AS NewAID,      a.Name AS NewName, " +
        "       a.Subcategory, a.SubAttribute, a.Price, a.CloseDate, a.CloseTime " +
        "FROM alertsets s " +
        "JOIN watches w   ON s.Alert_ID = w.Alert_ID " +
        "JOIN auction t   ON w.A_ID = t.A_ID " +
        "JOIN auction a   ON a.Subcategory = t.Subcategory " +
        "                 AND (a.SubAttribute = t.SubAttribute " +
        "                      OR (a.SubAttribute IS NULL AND t.SubAttribute IS NULL) " +
        "                      OR (a.SubAttribute LIKE CONCAT('%', t.SubAttribute, '%')) " +
        "                      OR (t.SubAttribute LIKE CONCAT('%', a.SubAttribute, '%'))) " +
        "WHERE s.Username = ? AND s.isActive = 1 " +
        "  AND a.Closed = 0 " +
        "  AND a.A_ID <> t.A_ID " +
        "  AND a.Name LIKE CONCAT('%', SUBSTRING_INDEX(t.Name,' ',1), '%') " +
        "ORDER BY t.Name, a.CloseDate, a.CloseTime"
    );
    psAvailable.setString(1, username);
    rsAvail = psAvailable.executeQuery();
%>

  <h3>New Auctions Matching My Item Alerts</h3>


  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Template Item</th>
      <th>Alert ID</th>
      <th>New Auction ID</th>
      <th>Available Item</th>
      <th>Category</th>
      <th>Attributes</th>
      <th>Start Price</th>
      <th>Closes</th>
      <th>View</th>
    </tr>
<%
    boolean anyAvail = false;
    while (rsAvail.next()) {
        anyAvail = true;
        int alertId       = rsAvail.getInt("Alert_ID");
        int templateAid   = rsAvail.getInt("TemplateAID");
        String templateNm = rsAvail.getString("TemplateName");
        int newAid        = rsAvail.getInt("NewAID");
        String newName    = rsAvail.getString("NewName");
        String category   = rsAvail.getString("Subcategory");
        String attr       = rsAvail.getString("SubAttribute");
        float price       = rsAvail.getFloat("Price");
        java.sql.Date cd2 = rsAvail.getDate("CloseDate");
        java.sql.Time ct2 = rsAvail.getTime("CloseTime");
%>
    <tr>
      <td><a href="viewAuction.jsp?A_ID=<%= templateAid %>"><%= templateNm %></a></td>
      <td><%= alertId %></td>
      <td><%= newAid %></td>
      <td><%= newName %></td>
      <td><%= (category == null ? "" : category) %></td>
      <td><%= (attr == null ? "" : attr) %></td>
      <td>$<%= String.format("%.2f", price) %></td>
      <td><%= cd2 %> <%= ct2 %></td>
      <td><a href="viewAuction.jsp?A_ID=<%= newAid %>">View Auction</a></td>
    </tr>
<%
    }

    if (!anyAvail) {
%>
    <tr>
      <td colspan="9">
        No new matching auctions are available right now.
        Use <a href="browseAuctions.jsp">Browse</a> and click
        “Set Alert” on items whose brand / size / color you want to track.
      </td>
    </tr>
<%
    }

} catch (Exception e) {
%>
  <p style="color:red;">Error loading notifications: <%= e.getMessage() %></p>
<%
} finally {
    if (rsClosed != null)   try { rsClosed.close(); }   catch (Exception e) {}
    if (rsOpen   != null)   try { rsOpen.close(); }     catch (Exception e) {}
    if (rsTop    != null)   try { rsTop.close(); }      catch (Exception e) {}
    if (rsAvail  != null)   try { rsAvail.close(); }    catch (Exception e) {}

    if (psClosed != null)   try { psClosed.close(); }   catch (Exception e) {}
    if (psOpen   != null)   try { psOpen.close(); }     catch (Exception e) {}
    if (psTop    != null)   try { psTop.close(); }      catch (Exception e) {}
    if (psAvailable != null)try { psAvailable.close(); }catch (Exception e) {}

    if (conn     != null)   try { conn.close(); }       catch (Exception e) {}
}
%>

</div>

