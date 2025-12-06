<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Only allow logged in customer reps
    if (role == null || !"cr".equals(role) || currentUser == null) {
        response.sendRedirect("crLogin.jsp?error=Please+log+in+as+Customer+Rep");
        return;
    }
%>

<div class="page">
    <h2>Customer Rep Dashboard</h2>

    <ul>
        <!-- 1) Reset user passwords -->
        <li>
            <a href="crResetPassword.jsp">Reset User Passwords</a>
        </li>

        <!-- 2) See / answer user questions -->
        <li>
            <a href="crQuestions.jsp">Answer User Questions</a>
        </li>

        <!-- 3) Remove suspicious bids / auctions -->
        <li>
            <a href="crRemoveBidAuction.jsp">Remove Suspicious Bids / Auctions</a>
        </li>
    </ul>

    <p style="margin-top: 12px; color: #555;">
        Use the links above to manage users, questions, and suspicious activity.
    </p>
</div>

