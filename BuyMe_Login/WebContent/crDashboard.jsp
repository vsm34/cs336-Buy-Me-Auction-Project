<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe - Customer Rep Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f4f4f4;
        }
        .page {
            margin: 24px;
        }
        h2 {
            margin-bottom: 16px;
        }
        ul {
            list-style-type: disc;
            padding-left: 24px;
        }
        a {
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
    String role2 = (String) session.getAttribute("role");
    Integer crid2 = (Integer) session.getAttribute("crid");
    if (!"cr".equals(role2) || crid2 == null) {
        response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
        return;
    }
%>

<div class="page">
    <h2>Customer Rep Dashboard</h2>
    <ul>
        <li><a href="crResetPassword.jsp">Reset User Passwords</a></li>
        <li><a href="crQuestions.jsp">Answer User Questions</a></li>
        <li><a href="crRemoveBidAuction.jsp">Remove Suspicious Bids/Auctions</a></li>
    </ul>
</div>

</body>
</html>
