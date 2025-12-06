<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    if (role == null || (!"admin".equals(role) && !"cr".equals(role))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String searchUser = request.getParameter("username");
    if (searchUser != null) {
        searchUser = searchUser.trim();
    }
%>

<div class="page">
  <h2>User History</h2>
  <p>View a buyer/seller&apos;s auction activity (auctions posted and bids placed).</p>

  <form method="get" action="userHistory.jsp" style="margin-bottom: 16px;">
    <label>Username:&nbsp;
      <input type="text" name="username" value="<%= (searchUser == null ? "" : searchUser) %>" />
    </label>
    <button type="submit">Search</button>
  </form>

<%
if (searchUser != null && !searchUser.isEmpty()) {
    Connection conn = null;
    PreparedStatement psCheck = null;
    PreparedStatement psAuctions = null;
    PreparedStatement psBids = null;
    ResultSet rsCheck = null;
    ResultSet rsAuc   = null;
    ResultSet rsBids  = null;

    try {
        conn = DBConnection.getConnection();


        psCheck = conn.prepareStatement(
            "SELECT Username FROM end_user WHERE Username = ?"
        );
        psCheck.setString(1, searchUser);
        rsCheck = psCheck.executeQuery();

        if (!rsCheck.next()) {
%>
  <p style="color:red;">No end_user with username &quot;<%= searchUser %>&quot; was found.</p>
<%
        } else {

            psAuctions = conn.prepareStatement(
                "SELECT a.A_ID, a.Name, a.Price, a.CloseDate, a.CloseTime, a.Closed " +
                "FROM auction a " +
                "JOIN posts p ON a.A_ID = p.A_ID " +
                "WHERE p.Username = ? " +
                "ORDER BY a.CloseDate, a.CloseTime"
            );
            psAuctions.setString(1, searchUser);
            rsAuc = psAuctions.executeQuery();
%>

  <h3>Auctions Posted by <%= searchUser %></h3>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Auction ID</th>
      <th>Item</th>
      <th>Start Price</th>
      <th>Status</th>
      <th>Closes</th>
      <th>View</th>
    </tr>
<%
            boolean anyAuc = false;
            while (rsAuc.next()) {
                anyAuc = true;
                int aId = rsAuc.getInt("A_ID");
                String name = rsAuc.getString("Name");
                float startPrice = rsAuc.getFloat("Price");
                boolean closedFlag = rsAuc.getBoolean("Closed");
                java.sql.Date cd = rsAuc.getDate("CloseDate");
                java.sql.Time ct = rsAuc.getTime("CloseTime");
%>
    <tr>
      <td><%= aId %></td>
      <td><%= name %></td>
      <td>$<%= String.format("%.2f", startPrice) %></td>
      <td><%= (closedFlag ? "Closed" : "Open") %></td>
      <td><%= cd %> <%= ct %></td>
      <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View</a></td>
    </tr>
<%
            }
            if (!anyAuc) {
%>
    <tr><td colspan="6">No auctions posted by this user.</td></tr>
<%
            }
%>
  </table>
  <br/>

<%

            psBids = conn.prepareStatement(
                "SELECT a.A_ID, a.Name, b.Price, b.Time, a.CloseDate, a.CloseTime, a.Closed " +
                "FROM bids b " +
                "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
                "JOIN auction a ON bo.A_ID = a.A_ID " +
                "JOIN places pl ON b.BID_ID = pl.BID_ID " +
                "WHERE pl.Username = ? " +
                "ORDER BY b.Time DESC"
            );
            psBids.setString(1, searchUser);
            rsBids = psBids.executeQuery();
%>

  <h3>Bids Placed by <%= searchUser %></h3>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Auction ID</th>
      <th>Item</th>
      <th>Bid Amount</th>
      <th>Bid Time</th>
      <th>Auction Status</th>
      <th>Closes</th>
      <th>View</th>
    </tr>
<%
            boolean anyBids = false;
            while (rsBids.next()) {
                anyBids = true;
                int aId = rsBids.getInt("A_ID");
                String name = rsBids.getString("Name");
                float bidPrice = rsBids.getFloat("Price");
                java.sql.Time bidTime = rsBids.getTime("Time");
                java.sql.Date cd2 = rsBids.getDate("CloseDate");
                java.sql.Time ct2 = rsBids.getTime("CloseTime");
                boolean closed2 = rsBids.getBoolean("Closed");
%>
    <tr>
      <td><%= aId %></td>
      <td><%= name %></td>
      <td>$<%= String.format("%.2f", bidPrice) %></td>
      <td><%= bidTime %></td>
      <td><%= (closed2 ? "Closed" : "Open") %></td>
      <td><%= cd2 %> <%= ct2 %></td>
      <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View</a></td>
    </tr>
<%
            }
            if (!anyBids) {
%>
    <tr><td colspan="7">This user has not placed any bids.</td></tr>
<%
            }
%>
  </table>

<%
        } 
    } catch (Exception e) {
%>
  <p style="color:red;">Error loading history: <%= e.getMessage() %></p>
<%
    } finally {
        if (rsCheck != null) try { rsCheck.close(); } catch (Exception e) {}
        if (rsAuc   != null) try { rsAuc.close(); }   catch (Exception e) {}
        if (rsBids  != null) try { rsBids.close(); }  catch (Exception e) {}
        if (psCheck != null) try { psCheck.close(); } catch (Exception e) {}
        if (psAuctions != null) try { psAuctions.close(); } catch (Exception e) {}
        if (psBids != null) try { psBids.close(); }    catch (Exception e) {}
        if (conn != null) try { conn.close(); }        catch (Exception e) {}
    }
} 
%>

</div>
