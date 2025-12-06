<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Must be logged in as a normal user
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<div class="page">
  <h2>My Auctions</h2>

  <%
    String flash = (String) session.getAttribute("flash");
    if (flash != null) {
  %>
      <p style="color:green;"><%= flash %></p>
  <%
        session.removeAttribute("flash");
    }

    try {
        conn = DBConnection.getConnection();

        ps = conn.prepareStatement(
            "SELECT a.A_ID, a.Name, a.Price, a.CloseDate, a.CloseTime, " +
            "       a.Closed, a.Subcategory, a.SubAttribute, p.PostDate " +
            "FROM auction a " +
            "JOIN posts p ON a.A_ID = p.A_ID " +
            "WHERE p.Username = ? " +
            "ORDER BY p.PostDate DESC, a.CloseDate ASC, a.CloseTime ASC"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();

        boolean hasRows = false;
  %>

  <table border="1" cellspacing="0" cellpadding="5">
    <tr>
      <th>Auction ID</th>
      <th>Item</th>
      <th>Subcategory</th>
      <th>Attribute</th>
      <th>Starting Price</th>
      <th>Post Date</th>
      <th>Closes</th>
      <th>Status</th>
      <th>Actions</th>
    </tr>

    <%
        while (rs.next()) {
            hasRows = true;
            int    aId       = rs.getInt("A_ID");
            String name      = rs.getString("Name");
            String subcat    = rs.getString("Subcategory");
            String subattr   = rs.getString("SubAttribute");
            float  price     = rs.getFloat("Price");
            java.sql.Date postDate  = rs.getDate("PostDate");
            java.sql.Date closeDate = rs.getDate("CloseDate");
            java.sql.Time closeTime = rs.getTime("CloseTime");
            boolean closed   = rs.getBoolean("Closed");
    %>
      <tr>
        <td><%= aId %></td>
        <td><%= name %></td>
        <td><%= (subcat != null ? subcat : "") %></td>
        <td><%= (subattr != null ? subattr : "") %></td>
        <td>$<%= price %></td>
        <td><%= postDate %></td>
        <td><%= closeDate %> <%= closeTime %></td>
        <td><%= closed ? "Closed" : "Open" %></td>
        <td>
          <a href="viewAuction.jsp?A_ID=<%= aId %>">View</a>
        </td>
      </tr>
    <%
        } // end while

        if (!hasRows) {
    %>
      <tr>
        <td colspan="9">You have not created any auctions yet.</td>
      </tr>
    <%
        }

    } catch (SQLException e) {
    %>
      <p style="color:red;">Error loading your auctions: <%= e.getMessage() %></p>
    <%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    %>
  </table>
</div>
