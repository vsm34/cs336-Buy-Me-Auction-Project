<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>BuyMe - Admin Dashboard</title>
</head>
<body>
<%@ include file="header.jsp" %>

<div class="page">
  <h2>Admin Dashboard</h2>
  <ul>
    <li><a href="adminManageReps.jsp?view=create">Create Customer Rep</a></li>
    <li><a href="adminManageReps.jsp?view=delete">Delete Customer Rep</a></li>
    <li><a href="adminSalesReport.jsp">View Sales / System Reports</a></li>
    <li><a href="adminManageAuctions.jsp">Manage Auctions &amp; Bids</a></li>
  </ul>
</div>
</body>
</html>
