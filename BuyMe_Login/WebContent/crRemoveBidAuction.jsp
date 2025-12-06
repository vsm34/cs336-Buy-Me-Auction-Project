<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    String crRole = role;
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(crRole) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=" + java.net.URLEncoder.encode("Please log in as Customer Rep", "UTF-8"));
        return;
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe – Remove Suspicious Bids/Auctions</title>
    <style>
        .page { margin: 24px; font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; margin-top: 12px; }
        th, td { border: 1px solid #444; padding: 6px 8px; text-align: left; }
        th { background-color: #eee; }
        .btnRemove { background:#cc0000; color:#fff; border:none; padding:4px 8px; cursor:pointer; }
        .msg { color: green; margin-top: 8px; }
        .sectionTitle { margin-top: 24px; }
    </style>
</head>
<body>
<div class="page">
    <h2>Remove Suspicious Bids</h2>

    <%
        if (msg != null && msg.length() > 0) {
    %>
        <div class="msg"><%= msg %></div>
    <%
        }
    %>

    <table>
        <tr>
            <th>BID ID</th>
            <th>Bid Price</th>
            <th>Auction ID</th>
            <th>Auction Name</th>
            <th>Action</th>
        </tr>
        <%
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT b.BID_ID, b.Price, bo.A_ID, a.Name " +
                     "FROM bids b " +
                     "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
                     "JOIN auction a ON bo.A_ID = a.A_ID " +
                     "ORDER BY b.BID_ID")) {

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int bidId = rs.getInt("BID_ID");
                        float price = rs.getFloat("Price");
                        int aId = rs.getInt("A_ID");
                        String aName = rs.getString("Name");
        %>
                        <tr>
                            <td><%= bidId %></td>
                            <td><%= price %></td>
                            <td><%= aId %></td>
                            <td><%= aName %></td>
                            <td>
                                <form action="crRemoveBidHandler.jsp" method="post">
                                    <input type="hidden" name="bidId" value="<%= bidId %>">
                                    <button type="submit" class="btnRemove"
                                        onclick="return confirm('Remove bid <%= bidId %>?');">
                                        Remove Bid
                                    </button>
                                </form>
                            </td>
                        </tr>
        <%
                    }
                }
            } catch (Exception e) {
        %>
                <tr>
                    <td colspan="5">Error loading bids.</td>
                </tr>
        <%
            }
        %>
    </table>

    <h2 class="sectionTitle">Remove Suspicious Auctions</h2>

    <table>
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Price</th>
            <th>Close Date</th>
            <th>Close Time</th>
            <th>Closed?</th>
            <th>Action</th>
        </tr>
        <%
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT A_ID, Name, Price, CloseDate, CloseTime, Closed " +
                     "FROM auction ORDER BY A_ID")) {

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int aId = rs.getInt("A_ID");
                        String aName = rs.getString("Name");
                        float price = rs.getFloat("Price");
                        java.sql.Date cDate = rs.getDate("CloseDate");
                        java.sql.Time cTime = rs.getTime("CloseTime");
                        boolean closed = rs.getBoolean("Closed");
        %>
                        <tr>
                            <td><%= aId %></td>
                            <td><%= aName %></td>
                            <td><%= price %></td>
                            <td><%= cDate %></td>
                            <td><%= cTime %></td>
                            <td><%= closed ? "Yes" : "No" %></td>
                            <td>
                                <form action="crRemoveAuctionHandler.jsp" method="post">
                                    <input type="hidden" name="auctionId" value="<%= aId %>">
                                    <button type="submit" class="btnRemove"
                                        onclick="return confirm('Remove auction <%= aId %> and all related data?');">
                                        Remove Auction
                                    </button>
                                </form>
                            </td>
                        </tr>
        <%
                    }
                }
            } catch (Exception e) {
        %>
                <tr>
                    <td colspan="7">Error loading auctions.</td>
                </tr>
        <%
            }
        %>
    </table>
</div>
</body>
</html>
