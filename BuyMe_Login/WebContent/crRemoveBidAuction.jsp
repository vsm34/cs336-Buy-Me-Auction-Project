<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe - Remove Suspicious Bids/Auctions</title>
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
        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 32px;
            background-color: #fff;
        }
        th, td {
            border: 1px solid #333;
            padding: 8px 10px;
            text-align: left;
        }
        th {
            background-color: #ddd;
        }
        form {
            margin: 0;
        }
        button {
            padding: 5px 10px;
            border: none;
            background-color: #c0392b;
            color: #fff;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
        }
        button[disabled] {
            background-color: #aaa;
            cursor: default;
        }
        .msg {
            padding: 10px 14px;
            margin-bottom: 16px;
            border-radius: 4px;
            background-color: #e8f5e9;
            border: 1px solid #2e7d32;
            color: #2e7d32;
            display: inline-block;
        }
        .error {
            background-color: #ffebee;
            border-color: #c62828;
            color: #c62828;
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
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>

<div class="page">
    <h2>Remove Suspicious Bids</h2>

    <%
        if (msg != null && !msg.isEmpty()) {
    %>
        <div class="msg"><%= msg %></div>
    <%
        } else if (err != null && !err.isEmpty()) {
    %>
        <div class="msg error"><%= err %></div>
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
            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement psRemoved = conn.prepareStatement(
                    "select CRID from removes where BID_ID = ?"
                );
                PreparedStatement ps = conn.prepareStatement(
                    "select b.BID_ID, b.Price, a.A_ID, a.Name " +
                    "from bids b " +
                    "join bids_on bo on b.BID_ID = bo.BID_ID " +
                    "join auction a on bo.A_ID = a.A_ID " +
                    "order by b.BID_ID"
                );
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int bidId = rs.getInt("BID_ID");
                    float bidPrice = rs.getFloat("Price");
                    int aId = rs.getInt("A_ID");
                    String aName = rs.getString("Name");
                    psRemoved.setInt(1, bidId);
                    ResultSet rsRem = psRemoved.executeQuery();
                    boolean alreadyRemoved = rsRem.next();
                    Integer removedBy = null;
                    if (alreadyRemoved) {
                        removedBy = rsRem.getInt("CRID");
                    }
        %>
        <tr>
            <td><%= bidId %></td>
            <td><%= bidPrice %></td>
            <td><%= aId %></td>
            <td><%= aName %></td>
            <td>
                <%
                    if (alreadyRemoved) {
                %>
                    Marked removed by CRID <%= removedBy %>
                <%
                    } else {
                %>
                    <form action="crRemoveBidAction.jsp" method="post">
                        <input type="hidden" name="bidId" value="<%= bidId %>">
                        <button type="submit">Remove Bid</button>
                    </form>
                <%
                    }
                %>
            </td>
        </tr>
        <%
                    rsRem.close();
                }
                rs.close();
                ps.close();
                psRemoved.close();
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="5">Error loading bids.</td>
        </tr>
        <%
            }
        %>
    </table>

    <h2>Remove Suspicious Auctions</h2>

    <table>
        <tr>
            <th>Auction ID</th>
            <th>Name</th>
            <th>Start Price</th>
            <th>Closed</th>
            <th>Action</th>
        </tr>
        <%
            try (Connection conn2 = DBConnection.getConnection()) {
                PreparedStatement psDel = conn2.prepareStatement(
                    "select CRID from deletes where A_ID = ?"
                );
                PreparedStatement ps2 = conn2.prepareStatement(
                    "select A_ID, Name, Price, Closed from auction order by A_ID"
                );
                ResultSet rs2 = ps2.executeQuery();
                while (rs2.next()) {
                    int aId2 = rs2.getInt("A_ID");
                    String name2 = rs2.getString("Name");
                    float price2 = rs2.getFloat("Price");
                    boolean closed2 = rs2.getBoolean("Closed");
                    psDel.setInt(1, aId2);
                    ResultSet rsDel = psDel.executeQuery();
                    boolean alreadyDeleted = rsDel.next();
                    Integer deletedBy = null;
                    if (alreadyDeleted) {
                        deletedBy = rsDel.getInt("CRID");
                    }
        %>
        <tr>
            <td><%= aId2 %></td>
            <td><%= name2 %></td>
            <td><%= price2 %></td>
            <td><%= closed2 ? "Yes" : "No" %></td>
            <td>
                <%
                    if (alreadyDeleted) {
                %>
                    Marked removed by CRID <%= deletedBy %>
                <%
                    } else {
                %>
                    <form action="crRemoveAuctionAction.jsp" method="post">
                        <input type="hidden" name="auctionId" value="<%= aId2 %>">
                        <button type="submit">Remove Auction</button>
                    </form>
                <%
                    }
                %>
            </td>
        </tr>
        <%
                    rsDel.close();
                }
                rs2.close();
                ps2.close();
                psDel.close();
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="5">Error loading auctions.</td>
        </tr>
        <%
            }
        %>
    </table>
</div>

</body>
</html>