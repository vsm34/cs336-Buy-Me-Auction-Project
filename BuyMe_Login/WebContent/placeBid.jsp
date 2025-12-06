<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Requires a logged in end_user
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;

   
    String aIdStr = request.getParameter("A_ID");
    if (aIdStr == null) {
        out.println("<div class='page'><p style='color:red;'>No auction selected.</p></div>");
        return;
    }

    int A_ID = Integer.parseInt(aIdStr);

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String name = null;
    float currentPrice = 0f;
    boolean closed = false;
    String seller = null;

    try {
        conn = DBConnection.getConnection();

       
        ps = conn.prepareStatement(
            "SELECT a.Name, a.Price, a.Closed, " +
            "       COALESCE(MAX(b.Price), a.Price) AS CurrentPrice, " +
            "       p.Username AS SellerUsername " +
            "FROM auction a " +
            "LEFT JOIN posts p ON a.A_ID = p.A_ID " +
            "LEFT JOIN bids_on bo ON a.A_ID = bo.A_ID " +
            "LEFT JOIN bids b ON bo.BID_ID = b.BID_ID " +
            "WHERE a.A_ID = ? " +
            "GROUP BY a.A_ID, a.Name, a.Price, a.Closed, p.Username"
        );
        ps.setInt(1, A_ID);
        rs = ps.executeQuery();

        if (!rs.next()) {
            out.println("<div class='page'><p style='color:red;'>Auction not found.</p></div>");
            return;
        }

        name         = rs.getString("Name");
        currentPrice = rs.getFloat("CurrentPrice");
        closed       = rs.getBoolean("Closed");
        seller       = rs.getString("SellerUsername");

    } catch (SQLException e) {
        out.println("<div class='page'><p style='color:red;'>Error loading auction: " + e.getMessage() + "</p></div>");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<div class="page">
  <h2>Place a Bid</h2>
  <p><b>Auction:</b> <%= name %></p>
  <p><b>Current Price:</b> $<%= currentPrice %></p>
  <p><b>Seller:</b> <%= (seller == null ? "-" : seller) %></p>

  <%
   
    if (closed) {
  %>
      <p style="color:red;">This auction is closed. You cannot bid.</p>
  <%
    } else if (seller != null && seller.equals(username)) {
  %>
      <p style="color:red;">You created this auction and cannot bid on your own item.</p>
  <%
    } else {
        String flash = (String) session.getAttribute("flash");
        if (flash != null) {
  %>
        <p style="color:red;"><%= flash %></p>
  <%
            session.removeAttribute("flash");
        }
  %>

  <form action="placeBidHandler.jsp" method="post">
    <input type="hidden" name="A_ID" value="<%= A_ID %>">

    <p>
      <label>Your Bid Amount ($):</label><br>
      <input type="number" name="bidAmount" step="0.01" min="0" required>
    </p>

    <fieldset style="max-width:400px;">
      <legend>Optional Auto-Bid Settings</legend>
      <p>
        <label>Maximum Auto-Bid Limit ($):</label><br>
        <input type="number" name="buyLimit" step="0.01" min="0">
      </p>
      <p>
        <label>Auto-Bid Increment ($):</label><br>
        <input type="number" name="increment" step="0.01" min="0">
      </p>
      <small>
        Leave both fields blank if you want a normal one-time bid.<br>
        If you fill them, the system will automatically outbid others up to your max.
      </small>
    </fieldset>

    <p>
      <button type="submit">Submit Bid</button>
    </p>
  </form>

  <%
    } 
</div>
