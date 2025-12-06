<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*, utils.DBConnection" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>

<%
    String message = null;
    String error   = null;

    String method = request.getMethod();
    String action = request.getParameter("action");

    String closedOnlyParam = request.getParameter("closedOnly");
    boolean closedOnly = "on".equalsIgnoreCase(closedOnlyParam) || "1".equals(closedOnlyParam);


    String viewBidsFor = request.getParameter("viewBidsFor");

    //admins delete stuff
    if ("POST".equalsIgnoreCase(method) && "delete".equals(action)) {
        String aidStr = request.getParameter("A_ID");
        if (aidStr != null && !aidStr.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                int aid = Integer.parseInt(aidStr.trim());
                conn = DBConnection.getConnection();

              
                String sql = "DELETE FROM auction WHERE A_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, aid);
                int rows = ps.executeUpdate();

                if (rows > 0) {
                    message = "Auction A_ID=" + aid + " deleted successfully.";
                } else {
                    message = "No auction was deleted. Check that A_ID exists.";
                }
            } catch (NumberFormatException nfe) {
                error = "Invalid A_ID value for delete.";
            } catch (Exception e) {
                error = "Error deleting auction: " + e.getMessage();
            } finally {
                try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                try { if (conn != null) conn.close(); } catch (Exception ignored) {}
            }
        } else {
            error = "Missing A_ID for delete.";
        }
    }
%>

<%@ include file="header.jsp" %>

<div class="page">
  <h1>Manage Auctions</h1>

  <% if (message != null) { %>
      <div style="padding:8px 12px; background-color:#e5ffe5; border:1px solid #8c8;">
          <%= message %>
      </div>
      <br>
  <% } %>
  <% if (error != null) { %>
      <div style="padding:8px 12px; background-color:#ffe5e5; border:1px solid #c88; color:#a00;">
          <strong>Error:</strong> <%= error %>
      </div>
      <br>
  <% } %>

  <!-- Filter form -->
  <form method="get" action="adminManageAuctions.jsp" style="margin-bottom:16px;">
      <label>
          <input type="checkbox" name="closedOnly" <%= closedOnly ? "checked" : "" %> />
          Show only closed auctions
      </label>
      <input type="submit" value="Apply Filter">
  </form>

  <!-- ====== LIST AUCTIONS ====== -->
  <h2>Auctions</h2>

  <style>
    table.auctions {
        border-collapse: collapse;
        width: 100%;
        max-width: 1000px;
    }
    table.auctions th, table.auctions td {
        border: 1px solid #ccc;
        padding: 6px 8px;
        font-size: 14px;
    }
    table.auctions th {
        background-color: #f4f4f4;
    }
    tr.closed-row {
        background-color: #ffeeee;
    }
    .small-btn {
        font-size: 12px;
        padding: 3px 8px;
        margin: 0;
    }
  </style>

  <table class="auctions">
    <tr>
      <th>A_ID</th>
      <th>Name</th>
      <th>Price</th>
      <th>Close Date</th>
      <th>Close Time</th>
      <th>Closed?</th>
      <th>Subcategory</th>
      <th>SubAttribute</th>
      <th>Actions</th>
    </tr>

    <%
        Connection connList = null;
        PreparedStatement psList = null;
        ResultSet rsList = null;

        try {
            connList = DBConnection.getConnection();

            StringBuilder sqlList = new StringBuilder(
                "SELECT A_ID, Name, Price, CloseDate, CloseTime, Closed, Subcategory, SubAttribute " +
                "FROM auction WHERE 1=1 "
            );
            if (closedOnly) {
                sqlList.append("AND Closed = 1 ");
            }
            sqlList.append("ORDER BY Closed DESC, CloseDate DESC, CloseTime DESC");

            psList = connList.prepareStatement(sqlList.toString());
            rsList = psList.executeQuery();

            boolean anyAuctions = false;
            while (rsList.next()) {
                anyAuctions = true;
                int    aid        = rsList.getInt("A_ID");
                String name       = rsList.getString("Name");
                double price      = rsList.getDouble("Price");
                java.sql.Date cDate = rsList.getDate("CloseDate");
                java.sql.Time cTime = rsList.getTime("CloseTime");
                boolean closedFlag  = rsList.getBoolean("Closed");
                String subcat     = rsList.getString("Subcategory");
                String subAttr    = rsList.getString("SubAttribute");

                String rowClass = closedFlag ? "closed-row" : "";
    %>
    <tr class="<%= rowClass %>">
      <td><%= aid %></td>
      <td><%= name %></td>
      <td><%= String.format("%.2f", price) %></td>
      <td><%= (cDate != null ? cDate.toString() : "") %></td>
      <td><%= (cTime != null ? cTime.toString() : "") %></td>
      <td><%= closedFlag ? "Yes" : "No" %></td>
      <td><%= (subcat != null ? subcat : "") %></td>
      <td><%= (subAttr != null ? subAttr : "") %></td>
      <td>
        <!-- View bids (GET) -->
        <form method="get" action="adminManageAuctions.jsp" style="display:inline;">
            <input type="hidden" name="viewBidsFor" value="<%= aid %>">
            <% if (closedOnly) { %>
                <input type="hidden" name="closedOnly" value="on">
            <% } %>
            <input type="submit" value="View Bids" class="small-btn">
        </form>

        <!-- Delete auction (POST) -->
        <form method="post" action="adminManageAuctions.jsp" style="display:inline;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="A_ID" value="<%= aid %>">
            <% if (closedOnly) { %>
                <!-- preserve filter on reload by using a query string in URL if you want -->
            <% } %>
            <input type="submit" value="Delete" class="small-btn"
                   onclick="return confirm('Delete auction A_ID=<%= aid %>? This cannot be undone.');">
        </form>
      </td>
    </tr>
    <%
            }
            if (!anyAuctions) {
    %>
    <tr>
      <td colspan="9">No auctions found for the current filter.</td>
    </tr>
    <%
            }
        } catch (Exception e) {
    %>
    <tr>
      <td colspan="9">Error loading auctions: <%= e.getMessage() %></td>
    </tr>
    <%
        } finally {
            try { if (rsList  != null) rsList.close(); } catch (Exception ignored) {}
            try { if (psList  != null) psList.close(); } catch (Exception ignored) {}
            try { if (connList!= null) connList.close(); } catch (Exception ignored) {}
        }
    %>
  </table>

  <!-- ====== OPTIONAL: SHOW BIDS FOR SELECTED AUCTION ====== -->
  <%
    if (viewBidsFor != null && !viewBidsFor.trim().isEmpty()) {
        Connection connBids = null;
        PreparedStatement psBids = null;
        ResultSet rsBids = null;

        try {
            int aidForBids = Integer.parseInt(viewBidsFor.trim());
            connBids = DBConnection.getConnection();

            String sqlBids =
                "SELECT b.BID_ID, b.Price, b.Time " +
                "FROM bids_on bo " +
                "JOIN bids b ON bo.BID_ID = b.BID_ID " +
                "WHERE bo.A_ID = ? " +
                "ORDER BY b.Price DESC";

            psBids = connBids.prepareStatement(sqlBids);
            psBids.setInt(1, aidForBids);
            rsBids = psBids.executeQuery();
  %>
      <h2>Bids for Auction A_ID = <%= aidForBids %></h2>
      <table border="1" cellpadding="5" cellspacing="0">
        <tr>
          <th>BID_ID</th>
          <th>Price</th>
          <th>Time</th>
        </tr>
        <%
          boolean anyBids = false;
          while (rsBids.next()) {
              anyBids = true;
              int    bidId = rsBids.getInt("BID_ID");
              double price = rsBids.getDouble("Price");
              java.sql.Time t = rsBids.getTime("Time");
        %>
        <tr>
          <td><%= bidId %></td>
          <td><%= String.format("%.2f", price) %></td>
          <td><%= (t != null ? t.toString() : "") %></td>
        </tr>
        <%
          }
          if (!anyBids) {
        %>
        <tr>
          <td colspan="3">No bids found for this auction.</td>
        </tr>
        <% } %>
      </table>
  <%
        } catch (NumberFormatException nfe) {
  %>
      <p style="color:red;">Invalid A_ID provided for viewing bids.</p>
  <%
        } catch (Exception e) {
  %>
      <p style="color:red;">Error loading bids: <%= e.getMessage() %></p>
  <%
        } finally {
            try { if (rsBids  != null) rsBids.close(); } catch (Exception ignored) {}
            try { if (psBids  != null) psBids.close(); } catch (Exception ignored) {}
            try { if (connBids!= null) connBids.close(); } catch (Exception ignored) {}
        }
    }
  %>

</div>
