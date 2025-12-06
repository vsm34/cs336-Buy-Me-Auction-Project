<%@ page language="java" %>

<%
    // Make these available to every JSP that includes header.jsp
    String currentUser = (String) session.getAttribute("username");
    String role        = (String) session.getAttribute("role");   // "user", "admin", "cr" or null
%>

<style>
  .topbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 16px;
    background-color: #f4f4f4;
    border-bottom: 1px solid #ccc;
    font-family: Arial, sans-serif;
    font-size: 14px;
  }
  .topbar a {
    margin-right: 12px;
    text-decoration: none;
    color: #000;
  }
  .topbar a:hover {
    text-decoration: underline;
  }
  .page {
    margin: 24px;
    font-family: Arial, sans-serif;
  }
</style>

<div class="topbar">
  <!-- Left Side (Brand / Home) -->
  <div class="brand">
    <strong><a href="index.jsp">BuyMe</a></strong>
  </div>

  <!-- Middle Navigation (Dynamic based on role) -->
  <div class="nav">
    <% if (role == null) { %>
        <!-- Not logged in -->
        <a href="index.jsp">Home</a>
        <a href="login.jsp">Buyer/Seller Login</a>
        <a href="adminLogin.jsp">Admin Login</a>
        <a href="crLogin.jsp">Customer Rep Login</a>

    <% } else if ("user".equals(role)) { %>
        <!-- Buyer/Seller -->
        <a href="index.jsp">Home</a>
        <a href="buyerSellerDashboard.jsp">Dashboard</a>
        <a href="browseAuctions.jsp">Browse</a>
        <a href="myBids.jsp">My Bids</a>
        <a href="myAuctions.jsp">My Auctions</a>
        <a href="watchList.jsp">My Watchlist</a>
        <a href="viewsPrevious.jsp">Recently Viewed</a>
        <a href="myNotifications.jsp">Notifications</a>
        <a href="faqSearch.jsp">FAQ</a>
        <a href="myAccount.jsp">My Account</a>
        <a href="logout.jsp">Logout</a>

    <% } else if ("admin".equals(role)) { %>
        <!-- Admin -->
        <a href="index.jsp">Home</a>
        <a href="adminDashboard.jsp">Admin Dashboard</a>
        <a href="adminManageReps.jsp">Manage Customer Reps</a>
        <a href="adminManageAuctions.jsp">Manage Auctions</a>
        <a href="adminSalesReport.jsp">Sales Reports</a>
        <a href="userHistory.jsp">User History</a>
        <a href="faqSearch.jsp">FAQ</a>
        <a href="logout.jsp">Logout</a>

    <% } else if ("cr".equals(role)) { %>
        <!-- Customer Rep -->
        <a href="index.jsp">Home</a>
        <a href="crDashboard.jsp">Customer Rep Dashboard</a>
        <a href="userHistory.jsp">User History</a>
        <a href="faqSearch.jsp">FAQ / Questions</a>
        <a href="logout.jsp">Logout</a>
    <% } %>
  </div>

  <!-- Right Side (User indicator) -->
  <div class="user">
    <% if (currentUser != null) { %>
        Logged in as: <strong><%= currentUser %></strong> (<%= role %>)
    <% } else { %>
        Not logged in
    <% } %>
  </div>
</div>
