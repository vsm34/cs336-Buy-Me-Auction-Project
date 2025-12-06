<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, utils.DBConnection" %>

<%@ include file="header.jsp" %>

<%

    request.setCharacterEncoding("UTF-8");

    String subcategory = request.getParameter("subcategory");
    String status      = request.getParameter("status");     // "all", "open", "closed"
    String keyword     = request.getParameter("keyword");
    String minStr      = request.getParameter("minPrice");
    String maxStr      = request.getParameter("maxPrice");
    String sortBy      = request.getParameter("sortBy");     // "closeDate", "currentBid"
    String sortDir     = request.getParameter("sortDir");    // "asc", "desc"

    if (subcategory == null) subcategory = "All";
    if (status == null)      status      = "all";
    if (sortBy == null)      sortBy      = "closeDate";
    if (sortDir == null)     sortDir     = "asc";

    Float minPrice = null;
    Float maxPrice = null;
    try { if (minStr != null && !minStr.isEmpty()) minPrice = Float.parseFloat(minStr); } catch (Exception ignore) {}
    try { if (maxStr != null && !maxStr.isEmpty()) maxPrice = Float.parseFloat(maxStr); } catch (Exception ignore) {}
%>

<div class="page">
    <h2>Browse Auctions</h2>

    <form method="get" action="browseAuctions.jsp" style="margin-bottom: 12px;">
        Subcategory:
        <select name="subcategory">
            <option value="All"   <%= "All".equals(subcategory) ? "selected" : "" %>>All</option>
            <option value="golf"  <%= "golf".equals(subcategory) ? "selected" : "" %>>golf</option>
            <option value="basketball" <%= "basketball".equals(subcategory) ? "selected" : "" %>>basketball</option>
            <option value="tennis" <%= "tennis".equals(subcategory) ? "selected" : "" %>>tennis</option>
            <option value="streetwear" <%= "streetwear".equals(subcategory) ? "selected" : "" %>>streetwear</option>
        </select>

        &nbsp; Status:
        <select name="status">
            <option value="all"    <%= "all".equals(status) ? "selected" : "" %>>All</option>
            <option value="open"   <%= "open".equals(status) ? "selected" : "" %>>Open</option>
            <option value="closed" <%= "closed".equals(status) ? "selected" : "" %>>Closed</option>
        </select>

        &nbsp; Keyword:
        <input type="text" name="keyword" value="<%= (keyword == null ? "" : keyword) %>"
               placeholder="Search by name / type">

        &nbsp; Min Price:
        <input type="text" name="minPrice" size="6" value="<%= (minStr == null ? "" : minStr) %>">
        &nbsp; Max Price:
        <input type="text" name="maxPrice" size="6" value="<%= (maxStr == null ? "" : maxStr) %>">

        &nbsp; Sort by:
        <select name="sortBy">
            <option value="closeDate"  <%= "closeDate".equals(sortBy) ? "selected" : "" %>>Close Date</option>
            <option value="currentBid" <%= "currentBid".equals(sortBy) ? "selected" : "" %>>Current Highest Bid</option>
        </select>

        <select name="sortDir">
            <option value="asc"  <%= "asc".equalsIgnoreCase(sortDir) ? "selected" : "" %>>Ascending</option>
            <option value="desc" <%= "desc".equalsIgnoreCase(sortDir) ? "selected" : "" %>>Descending</option>
        </select>

        &nbsp; <button type="submit">Search</button>
    </form>

    <table border="1" cellpadding="4" cellspacing="0">
        <tr>
            <th>Auction ID</th>
            <th>Item</th>
            <th>Subcategory</th>
            <th>Attribute</th>
            <th>Starting Price</th>
            <th>Current Highest Bid</th>
            <th>Status</th>
            <th>Closes</th>
            <th>Actions</th>
        </tr>

<%
    StringBuilder sql = new StringBuilder(
        "SELECT a.A_ID, a.Name, a.Subcategory, a.SubAttribute, a.Price AS startPrice, " +
        "       a.CloseDate, a.CloseTime, a.Closed, " +
        "       COALESCE(MAX(b.Price), a.Price) AS currentBid " +
        "FROM auction a " +
        "LEFT JOIN bids_on bo ON a.A_ID = bo.A_ID " +
        "LEFT JOIN bids b     ON bo.BID_ID = b.BID_ID " +
        "WHERE 1=1 "
    );

    List<Object> params = new ArrayList<>();

    //Subcategory filter
    if (subcategory != null && !"All".equals(subcategory)) {
        sql.append(" AND a.Subcategory = ? ");
        params.add(subcategory);
    }

    if ("open".equalsIgnoreCase(status)) {
        sql.append(" AND a.Closed = 0 AND TIMESTAMP(a.CloseDate, a.CloseTime) > NOW() ");
    } else if ("closed".equalsIgnoreCase(status)) {
        sql.append(" AND (a.Closed = 1 OR TIMESTAMP(a.CloseDate, a.CloseTime) <= NOW()) ");
    }

    if (keyword != null && !keyword.trim().isEmpty()) {
        String like = "%" + keyword.trim() + "%";
        sql.append(" AND (a.Name LIKE ? OR a.Subcategory LIKE ? OR a.SubAttribute LIKE ?) ");
        params.add(like);
        params.add(like);
        params.add(like);
    }

    // Price range on starting price
    if (minPrice != null) {
        sql.append(" AND a.Price >= ? ");
        params.add(minPrice);
    }
    if (maxPrice != null) {
        sql.append(" AND a.Price <= ? ");
        params.add(maxPrice);
    }

    sql.append(
        " GROUP BY a.A_ID, a.Name, a.Subcategory, a.SubAttribute, " +
        "          a.Price, a.CloseDate, a.CloseTime, a.Closed "
    );

   
    String orderClause;
    if ("currentBid".equals(sortBy)) {
        orderClause = "currentBid";
    } else {
        //default: close date/time
        orderClause = "a.CloseDate, a.CloseTime";
    }

    String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
    sql.append(" ORDER BY " + orderClause + " " + dir);

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {

        int idx = 1;
        for (Object p : params) {
            if (p instanceof String)  ps.setString(idx++, (String)p);
            else if (p instanceof Float) ps.setFloat(idx++, (Float)p);
            else                       ps.setObject(idx++, p);
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int    aId     = rs.getInt("A_ID");
                String name    = rs.getString("Name");
                String subcat  = rs.getString("Subcategory");
                String attr    = rs.getString("SubAttribute");
                float  start   = rs.getFloat("startPrice");
                float  currBid = rs.getFloat("currentBid");
                java.sql.Date cDate = rs.getDate("CloseDate");
                java.sql.Time cTime = rs.getTime("CloseTime");
                boolean closedFlag  = rs.getBoolean("Closed");

                boolean isClosed = closedFlag ||
                                   (cDate != null && cTime != null &&
                                    (new java.sql.Timestamp(
                                         cDate.getTime() + cTime.getTime()
                                     ).before(new java.sql.Timestamp(System.currentTimeMillis()))));

                String statusLabel = isClosed ? "Closed" : "Open";
%>
        <tr>
            <td><%= aId %></td>
            <td><%= name %></td>
            <td><%= (subcat == null ? "-" : subcat) %></td>
            <td><%= (attr == null ? "-" : attr) %></td>
            <td>$<%= String.format("%.2f", start) %></td>
            <td>$<%= String.format("%.2f", currBid) %></td>
            <td><%= statusLabel %></td>
            <td><%= cDate %> <%= cTime %></td>
            <td><a href="viewAuction.jsp?A_ID=<%= aId %>">View</a></td>
        </tr>
<%
            }
        }
    } catch (Exception e) {
%>
        <tr><td colspan="9" style="color:red;">Error loading auctions: <%= e.getMessage() %></td></tr>
<%
    }
%>
    </table>
</div>
