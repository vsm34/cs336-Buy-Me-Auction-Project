<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<div class="page">
  <h2>Create New Auction</h2>

  <form action="createAuctionHandler.jsp" method="post">
    <p>
      <label>Item Name:</label><br>
      <input type="text" name="name" required>
    </p>

    <p>
      <label>Starting Price ($):</label><br>
      <input type="number" name="price" step="0.01" min="0" required>
    </p>

    <p>
      <label>Hidden Reserve Price ($):</label><br>
      <input type="number" name="reserve" step="0.01" min="0" required>
      <br><small>This will not be shown to bidders; auction only sells if highest bid ≥ this amount.</small>
    </p>

    <p>
      <label>Subcategory:</label><br>
      <select name="subcategory" required>
        <option value="">-- Select --</option>
        <option value="streetwear">Streetwear</option>
        <option value="basketball">Basketball</option>
        <option value="tennis">Tennis</option>
        <option value="golf">Golf</option>
      </select>
    </p>

    <p>
      <label>Size / Attribute:</label><br>
      <input type="text" name="subattr" placeholder="e.g. Size 10, Color Red">
    </p>

    <p>
      <label>Closing Date:</label><br>
      <input type="date" name="closeDate" required>
    </p>

    <p>
      <label>Closing Time:</label><br>
      <input type="time" name="closeTime" required>
    </p>

    <p>
      <button type="submit">Create Auction</button>
    </p>
  </form>
</div>
