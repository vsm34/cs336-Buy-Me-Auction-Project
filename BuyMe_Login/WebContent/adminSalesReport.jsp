<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    //admin only view
    if (role == null || !"admin".equals(role)) {
        response.sendRedirect("adminLogin.jsp?error=Admin+login+required");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    double totalEarnings = 0.0;
%>

<div class="page">
    <h2>Sales Reports</h2>

<%
    try {
        conn = DBConnection.getConnection();

        /* ---------------------------------------------------
         * 1. TOTAL EARNINGS (sum over all sales)
         * --------------------------------------------------- */
        ps = conn.prepareStatement(
            "SELECT COALESCE(SUM(Amount),0) AS total " +
            "FROM sale"
        );
        rs = ps.executeQuery();
        if (rs.next()) {
            totalEarnings = rs.getDouble("total");
        }
        rs.close();
        ps.close();
%>
        <h3>Total Earnings</h3>
        <p><strong>$<%= String.format("%.2f", totalEarnings) %></strong></p>

        <hr>

        <!-- ------------------------------------------------
             2. Earnings per item (auction)
             ------------------------------------------------ -->
        <h3>Earnings per Item</h3>
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>Auction ID</th>
                <th>Item Name</th>
                <th>Number of Sales</th>
                <th>Total Earned</th>
            </tr>
<%
        ps = conn.prepareStatement(
            "SELECT s.A_ID, a.Name, COUNT(*) AS numSales, SUM(s.Amount) AS totalEarned " +
            "FROM sale s " +
            "JOIN auction a ON s.A_ID = a.A_ID " +
            "GROUP BY s.A_ID, a.Name " +
            "ORDER BY totalEarned DESC"
        );
        rs = ps.executeQuery();
        boolean anyItem = false;
        while (rs.next()) {
            anyItem = true;
%>
            <tr>
                <td><%= rs.getInt("A_ID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td><%= rs.getInt("numSales") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("totalEarned")) %></td>
            </tr>
<%
        }
        if (!anyItem) {
%>
            <tr><td colspan="4">No sales have been recorded yet.</td></tr>
<%
        }
        rs.close();
        ps.close();
%>
        </table>

        <hr>

        <!-- ------------------------------------------------
             3. Earnings per item type (subcategory)
             ------------------------------------------------ -->
        <h3>Earnings per Item Type (Subcategory)</h3>
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>Subcategory</th>
                <th>Number of Sales</th>
                <th>Total Earned</th>
            </tr>
<%
        ps = conn.prepareStatement(
            "SELECT a.Subcategory, COUNT(*) AS numSales, SUM(s.Amount) AS totalEarned " +
            "FROM sale s " +
            "JOIN auction a ON s.A_ID = a.A_ID " +
            "GROUP BY a.Subcategory " +
            "ORDER BY totalEarned DESC"
        );
        rs = ps.executeQuery();
        boolean anyType = false;
        while (rs.next()) {
            anyType = true;
            String sub = rs.getString("Subcategory");
            if (sub == null) sub = "(none)";
%>
            <tr>
                <td><%= sub %></td>
                <td><%= rs.getInt("numSales") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("totalEarned")) %></td>
            </tr>
<%
        }
        if (!anyType) {
%>
            <tr><td colspan="3">No sales grouped by subcategory.</td></tr>
<%
        }
        rs.close();
        ps.close();
%>
        </table>

        <hr>

        <!-- ------------------------------------------------
             4. Earnings per end-user (seller)
             We treat the seller as the user who posted the auction.
             ------------------------------------------------ -->
        <h3>Earnings per Seller (End-User)</h3>
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>Seller Username</th>
                <th>Number of Sales</th>
                <th>Total Earned</th>
            </tr>
<%
        ps = conn.prepareStatement(
            "SELECT p.Username AS Seller, COUNT(*) AS numSales, SUM(s.Amount) AS totalEarned " +
            "FROM sale s " +
            "JOIN auction a ON s.A_ID = a.A_ID " +
            "JOIN posts p ON a.A_ID = p.A_ID " +
            "GROUP BY p.Username " +
            "ORDER BY totalEarned DESC"
        );
        rs = ps.executeQuery();
        boolean anySeller = false;
        while (rs.next()) {
            anySeller = true;
%>
            <tr>
                <td><%= rs.getString("Seller") %></td>
                <td><%= rs.getInt("numSales") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("totalEarned")) %></td>
            </tr>
<%
        }
        if (!anySeller) {
%>
            <tr><td colspan="3">No seller earnings to report.</td></tr>
<%
        }
        rs.close();
        ps.close();
%>
        </table>

        <hr>

        <!-- ------------------------------------------------
             5. Best-selling items (top 5 by revenue)
             ------------------------------------------------ -->
        <h3>Best-Selling Items (Top 5 by Revenue)</h3>
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>Rank</th>
                <th>Auction ID</th>
                <th>Item Name</th>
                <th>Total Earned</th>
            </tr>
<%
        ps = conn.prepareStatement(
            "SELECT s.A_ID, a.Name, SUM(s.Amount) AS totalEarned " +
            "FROM sale s " +
            "JOIN auction a ON s.A_ID = a.A_ID " +
            "GROUP BY s.A_ID, a.Name " +
            "ORDER BY totalEarned DESC " +
            "LIMIT 5"
        );
        rs = ps.executeQuery();
        int rank = 1;
        boolean anyBestItems = false;
        while (rs.next()) {
            anyBestItems = true;
%>
            <tr>
                <td><%= rank++ %></td>
                <td><%= rs.getInt("A_ID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("totalEarned")) %></td>
            </tr>
<%
        }
        if (!anyBestItems) {
%>
            <tr><td colspan="4">No best-selling items to show.</td></tr>
<%
        }
        rs.close();
        ps.close();
%>
        </table>

        <hr>

        <!-- ------------------------------------------------
             6. Best buyers
             We approximate the buyer as the user whose bid price
             exactly matches the recorded sale Amount for that auction.
             ------------------------------------------------ -->
        <h3>Best Buyers (by Total Amount Spent)</h3>
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>Rank</th>
                <th>Buyer Username</th>
                <th>Number of Purchases</th>
                <th>Total Spent</th>
            </tr>
<%
        ps = conn.prepareStatement(
            "SELECT p.Username AS Buyer, " +
            "       COUNT(*) AS numPurchases, " +
            "       SUM(s.Amount) AS totalSpent " +
            "FROM sale s " +
            "JOIN auction a ON s.A_ID = a.A_ID " +
            "JOIN bids_on bo ON s.A_ID = bo.A_ID " +
            "JOIN bids b ON bo.BID_ID = b.BID_ID " +
            "JOIN places p ON b.BID_ID = p.BID_ID " +
            "WHERE b.Price = s.Amount " +   // treat this bid as the winning bid
            "GROUP BY p.Username " +
            "ORDER BY totalSpent DESC"
        );
        rs = ps.executeQuery();
        rank = 1;
        boolean anyBuyers = false;
        while (rs.next()) {
            anyBuyers = true;
%>
            <tr>
                <td><%= rank++ %></td>
                <td><%= rs.getString("Buyer") %></td>
                <td><%= rs.getInt("numPurchases") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("totalSpent")) %></td>
            </tr>
<%
        }
        if (!anyBuyers) {
%>
            <tr><td colspan="4">No buyer statistics available yet.</td></tr>
<%
        }
        rs.close();
        ps.close();

    } catch (Exception e) {
%>
        <p style="color:red;">Error generating sales report: <%= e.getMessage() %></p>
<%
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>

</div>
