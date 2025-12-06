<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe - Buyer/Seller Dashboard</title>
</head>
<body>

<%@ include file="header.jsp" %>

<%
    // Only end-users should see this dashboard
    if (currentUser == null || !"user".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<div class="page">
    <h2>Buyer / Seller Dashboard</h2>
    <ul>
        <li><a href="browseAuctions.jsp">Browse / Search Auctions</a></li>
        <li><a href="myBids.jsp">My Bids</a></li>
        <li><a href="myAuctions.jsp">My Auctions</a></li>
        <li><a href="createAuction.jsp">Create New Auction</a></li>
        <li><a href="watchList.jsp">My Watchlist</a></li>
        <li><a href="viewsPrevious.jsp">Recently Viewed Auctions</a></li>
        <li><a href="faqSearch.jsp">FAQ / Search Questions</a></li>
        <li><a href="askQuestion.jsp">Ask a Question</a></li>

        <!-- Participation history requirement -->
        <li>
            <a href="userHistory.jsp?username=<%= currentUser %>">
                My Auction Participation History
            </a>
        </li>

        <!-- New: Alerts and notifications for "item becomes available" requirement -->
        <li><a href="myAlerts.jsp">My Item Alerts</a></li>
        <li><a href="myNotifications.jsp">My Notifications</a></li>
    </ul>
</div>

</body>
</html>

