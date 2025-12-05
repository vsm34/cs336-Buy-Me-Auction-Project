<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, utils.DBConnection" %>

<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<%
    // ===== READ FILTER PARAMETERS =====
    String startDate = request.getParameter("startDate");  // expected format: YYYY-MM-DD
    String endDate   = request.getParameter("endDate");    // expected format: YYYY-MM-DD

    boolean hasDateFilter  = (startDate != null && !startDate.trim().isEmpty()
                              && endDate   != null && !endDate.trim().isEmpty());

    String error = null;
%>

<%@ include file="header.jsp" %>

<div class="page">
  <h1>Sales Reports</h1>

  <!-- Filter Form -->
  <form method="get" action="adminSalesReport.jsp">
    <fieldset style="max-width: 500px;">
      <legend>Filter Options</legend>

      <label>
        Start Date (YYYY-MM-DD):
        <input type="text" name="startDate" value="<%= (startDate != null ? startDate : "") %>">
      </label>
      <br><br>

      <label>
        End Date (YYYY-MM-DD):
        <input type="text" name="endDate" value="<%= (endDate != null ? endDate : "") %>">
      </label>
      <br><br>

      <input type="submit" value="Run Report">
    </fieldset>
  </form>

  <br>

  <%
    // ========== RUN QUERIES IF ANY FILTER SUBMITTED ==========
    if (request.getParameter("startDate") != null || request.getParameter("endDate") != null) {
    	Connection conn = null;
    	PreparedStatement psSubcat = null;
    	PreparedStatement psDate   = null;
    	PreparedStatement psItem   = null;
    	PreparedStatement psBuyers = null;
    	ResultSet rsSubcat = null;
    	ResultSet rsDate   = null;
    	ResultSet rsItem   = null;
    	ResultSet rsBuyers = null;

        try {
            conn = DBConnection.getConnection();

            // ====== 1. TOTAL SALES BY SUBCATEGORY ======
            StringBuilder sqlSubcat = new StringBuilder();
            sqlSubcat.append(
                "SELECT a.Subcategory, SUM(s.Amount) AS totalAmount, COUNT(*) AS numSales " +
                "FROM sale s " +
                "JOIN auction a ON s.A_ID = a.A_ID " +
                "JOIN generates_sales_report g ON g.Sale_ID = s.Sale_ID " +
                "WHERE a.Closed=1 "
            );

            if (hasDateFilter) {
                sqlSubcat.append("AND s.Date BETWEEN ? AND ? ");
            }
            sqlSubcat.append("GROUP BY a.Subcategory ORDER BY totalAmount DESC");

            psSubcat = conn.prepareStatement(sqlSubcat.toString());

            int paramIndex = 1;
            if (hasDateFilter) {
                psSubcat.setString(paramIndex++, startDate.trim());
                psSubcat.setString(paramIndex++, endDate.trim());
            }

            rsSubcat = psSubcat.executeQuery();

         // ====== 2. SALES BY ITEM (EARNINGS PER AUCTION) ======
            StringBuilder sqlItem = new StringBuilder();
            sqlItem.append(
                "SELECT a.A_ID, a.Name, SUM(s.Amount) AS totalAmount " +
                "FROM sale s " +
                "JOIN auction a ON s.A_ID = a.A_ID " +
                "JOIN generates_sales_report g ON g.Sale_ID = s.Sale_ID " +
                "WHERE a.Closed=1 "
            );

            if (hasDateFilter) {
                sqlItem.append("AND s.Date BETWEEN ? AND ? ");
            }

            sqlItem.append("GROUP BY a.A_ID, a.Name ORDER BY totalAmount DESC");

            psItem = conn.prepareStatement(sqlItem.toString());

            paramIndex = 1;
            if (hasDateFilter) {
                psItem.setString(paramIndex++, startDate.trim());
                psItem.setString(paramIndex++, endDate.trim());
            }

            rsItem = psItem.executeQuery();

            // ====== 3. TOTAL SALES BY DATE (WITHIN RANGE) ======
            StringBuilder sqlDate = new StringBuilder();
            sqlDate.append(
                "SELECT s.Date, SUM(s.Amount) AS totalAmount, COUNT(*) AS numSales " +
                "FROM sale s " +
                "JOIN auction a ON s.A_ID = a.A_ID " +
                "JOIN generates_sales_report g ON g.Sale_ID = s.Sale_ID " +
                "WHERE a.Closed=1 "
            );

            if (hasDateFilter) {
                sqlDate.append("AND s.Date BETWEEN ? AND ? ");
            }

            sqlDate.append("GROUP BY s.Date ORDER BY s.Date ASC");

            psDate = conn.prepareStatement(sqlDate.toString());

            paramIndex = 1;
            if (hasDateFilter) {
                psDate.setString(paramIndex++, startDate.trim());
                psDate.setString(paramIndex++, endDate.trim());
            }

            rsDate = psDate.executeQuery();

            // ====== 3. BEST BUYERS (TOP SPENDERS) ======
            StringBuilder sqlBuyers = new StringBuilder();
            sqlBuyers.append(
                "SELECT p.Username, " +
                "       SUM(s.Amount) AS totalSpent, " +
                "       COUNT(*)      AS numSales " +
                "FROM sale s " +
                "JOIN auction a   ON s.A_ID = a.A_ID " +
                "JOIN bids_on bo  ON bo.A_ID = a.A_ID " +
                "JOIN bids b      ON b.BID_ID = bo.BID_ID " +
                "JOIN places p    ON p.BID_ID = b.BID_ID " +
                "JOIN generates_sales_report g ON g.Sale_ID = s.Sale_ID " +
                "WHERE b.Price = s.Amount " + 
                "	AND a.Closed = 1 "
            );

            if (hasDateFilter) {
                sqlBuyers.append("AND s.Date BETWEEN ? AND ? ");
            }

            sqlBuyers.append("GROUP BY p.Username ORDER BY totalSpent DESC");

            psBuyers = conn.prepareStatement(sqlBuyers.toString());

            paramIndex = 1;
            if (hasDateFilter) {
                psBuyers.setString(paramIndex++, startDate.trim());
                psBuyers.setString(paramIndex++, endDate.trim());
            }

            rsBuyers = psBuyers.executeQuery();
  %>

  <!-- ====== RESULTS: SALES BY SUBCATEGORY ====== -->
  <h2>Sales Summary by Subcategory</h2>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Subcategory</th>
      <th>Total Sales Amount</th>
      <th>Number of Sales</th>
    </tr>
    <%
      boolean anySubcat = false;
      while (rsSubcat.next()) {
          anySubcat = true;
          String subcat = rsSubcat.getString("Subcategory");
          if (subcat == null || subcat.trim().isEmpty()) {
              subcat = "(Uncategorized)";
          }
          double totalAmount = rsSubcat.getDouble("totalAmount");
          int numSales = rsSubcat.getInt("numSales");
    %>
    <tr>
      <td><%= subcat %></td>
      <td><%= String.format("%.2f", totalAmount) %></td>
      <td><%= numSales %></td>
    </tr>
    <%
      }
      if (!anySubcat) {
    %>
    <tr>
      <td colspan="3">No sales found for the given filters.</td>
    </tr>
    <% } %>
  </table>

  <br>
  
  <!-- ====== RESULTS: SALES BY ITEM (EARNINGS PER AUCTION) ====== -->
<h2>Sales Summary by Item (Auction)</h2>
<table border="1" cellpadding="5" cellspacing="0">
  <tr>
    <th>A_ID</th>
    <th>Item Name</th>
    <th>Total Sales Amount</th>
  </tr>
  <%
    boolean anyItem = false;
    while (rsItem.next()) {
        anyItem = true;
        int aidItem        = rsItem.getInt("A_ID");
        String itemName    = rsItem.getString("Name");
        double totalAmountItem = rsItem.getDouble("totalAmount");
  %>
  <tr>
    <td><%= aidItem %></td>
    <td><%= itemName %></td>
    <td><%= String.format("%.2f", totalAmountItem) %></td>
  </tr>
  <%
    }
    if (!anyItem) {
  %>
  <tr>
    <td colspan="3">No item-level sales found for the given filters.</td>
  </tr>
  <% } %>
</table>

<br>

  <!-- ====== RESULTS: SALES BY DATE ====== -->
  <h2>Sales Summary by Date</h2>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Date</th>
      <th>Total Sales Amount</th>
      <th>Number of Sales</th>
    </tr>
    <%
      boolean anyDate = false;
      while (rsDate.next()) {
          anyDate = true;
          java.sql.Date d = rsDate.getDate("Date");
          double totalAmount = rsDate.getDouble("totalAmount");
          int numSales = rsDate.getInt("numSales");
    %>
    <tr>
      <td><%= d.toString() %></td>
      <td><%= String.format("%.2f", totalAmount) %></td>
      <td><%= numSales %></td>
    </tr>
    <%
      }
      if (!anyDate) {
    %>
    <tr>
      <td colspan="3">No sales found for the given filters.</td>
    </tr>
    <% } %>
  </table>

  <br>

  <!-- ====== RESULTS: BEST BUYERS (TOP SPENDERS) ====== -->
  <h2>Top Spenders</h2>
  <table border="1" cellpadding="5" cellspacing="0">
    <tr>
      <th>Username</th>
      <th>Total Spent</th>
      <th>Number of Purchases</th>
    </tr>
    <%
      boolean anyBuyers = false;
      while (rsBuyers.next()) {
          anyBuyers = true;
          String username  = rsBuyers.getString("Username");
          double totalSpent = rsBuyers.getDouble("totalSpent");
          int numSalesBuyer = rsBuyers.getInt("numSales");
    %>
    <tr>
      <td><%= username %></td>
      <td><%= String.format("%.2f", totalSpent) %></td>
      <td><%= numSalesBuyer %></td>
    </tr>
    <%
      }
      if (!anyBuyers) {
    %>
    <tr>
      <td colspan="3">No buyers found for the given filters.</td>
    </tr>
    <% } %>
  </table>

  <%
        } catch (Exception e) {
            error = "Error while generating report: " + e.getMessage();
        } finally {
            try { if (rsSubcat != null) rsSubcat.close(); } catch (Exception ignored) {}
            try { if (rsDate   != null) rsDate.close(); } catch (Exception ignored) {}
            try { if (rsItem   != null) rsItem.close(); } catch (Exception ignored) {}
            try { if (rsBuyers != null) rsBuyers.close(); } catch (Exception ignored) {}

            try { if (psSubcat != null) psSubcat.close(); } catch (Exception ignored) {}
            try { if (psDate   != null) psDate.close(); } catch (Exception ignored) {}
            try { if (rsItem   != null) rsItem.close(); } catch (Exception ignored) {}
            try { if (psBuyers != null) psBuyers.close(); } catch (Exception ignored) {}

            try { if (conn     != null) conn.close(); } catch (Exception ignored) {}
        }
    } // end if filters submitted
  %>

  <% if (error != null) { %>
    <p style="color: red;"><strong><%= error %></strong></p>
  <% } %>

</div>