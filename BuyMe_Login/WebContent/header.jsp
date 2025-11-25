<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUser = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");   // "user", "admin", "cr" or null
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
  <div class="brand">
    <strong><a href="index.jsp">BuyMe</a></strong>
  </div>

  <div class="nav">
    <%
      if (role == null) {
        // Not logged in: show all login options
    %>
        <a href="index.jsp">Home</a>
        <a href="login.jsp">Buyer/Seller Login</a>
        <a href="adminLogin.jsp">Admin Login</a>
        <a href="crLogin.jsp">Customer Rep Login</a>
    <%
      } else if ("user".equals(role)) {
    %>
        <a href="index.jsp">Home</a>
        <a href="buyerSellerDashboard.jsp">Buyer/Seller Dashboard</a>
        <a href="logout.jsp">Logout</a>
    <%
      } else if ("admin".equals(role)) {
    %>
        <a href="index.jsp">Home</a>
        <a href="adminDashboard.jsp">Admin Dashboard</a>
        <a href="logout.jsp">Logout</a>
    <%
      } else if ("cr".equals(role)) {
    %>
        <a href="index.jsp">Home</a>
        <a href="crDashboard.jsp">Customer Rep Dashboard</a>
        <a href="logout.jsp">Logout</a>
    <%
      }
    %>
  </div>

  <div class="user">
    <%
      if (currentUser != null) {
    %>
        Logged in as: <strong><%= currentUser %></strong> (<%= role %>)
    <%
      } else {
    %>
        Not logged in
    <%
      }
    %>
  </div>
</div>
