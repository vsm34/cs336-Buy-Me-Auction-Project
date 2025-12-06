<%@ page import="java.sql.*, java.util.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Must be logged in as a normal user
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;

    request.setCharacterEncoding("UTF-8");

    String subcatParam      = request.getParameter("subcategory");
    String minPriceStr      = request.getParameter("minPrice");
    String maxPriceStr      = request.getParameter("maxPrice");
    String statusFilterParam= request.getParameter("statusFilter"); // "", "open", "closed"

    Float minPrice = null;
    Float maxPrice = null;

    try {
        if (minPriceStr != null && !minPriceStr.isEmpty()) {
            minPrice = Float.parseFloat(minPriceStr);
        }
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            maxPrice = Float.parseFloat(maxPriceStr);
        }
    } catch (NumberFormatException e) {
        // Invalid price inputs -> ignore and show everything
        minPrice = null;
        maxPrice = null;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<div class="page">
    <h2>Browse Auctions</h2>

    <form method="get" action="browseAuctions.jsp" style="margin-bottom: 16px;">
        <label>Subcategory: </label>
        <select name="subcategory">
            <option value="">All</option>
            <option value="streetwear" <%= "streetwear".equals(subcatParam) ? "selected" : "" %>>Streetwear</option>
            <option value="basketball" <%= "basketball".equals(subcatParam) ? "selected" : "" %>>Basketball</option>
            <option value="tennis"     <%= "tennis".equals(subcatParam) ? "selected" : "" %>>Tennis</option>
            <option value="golf"       <%= "golf".equals(subcatParam) ? "selected" : "" %>>Golf</option>
        </select>

        &nbsp;&nbsp;

        <label>Status:</label>
        <select name="statusFilter">
            <option value="" <%= (statusFilterParam == null || statusFilterParam.isEmpty()) ? "selected" : "" %>>
                All
            </option>
            <option value="open" <%= "open".equals(statusFilterParam) ? "selected" : "" %>>
                Open
            </option>
            <option value="closed" <%= "closed".equals(statusFilterParam) ? "selected" : "" %>>
                Closed
            </option>
        </select>

        &nbsp;&nbsp;

        <label>Min Price:</label>
        <input type="text" name="minPrice" value="<%= (minPriceStr != null ? minPriceStr : "") %>" />

        <label>Max Price:</label>
        <input type="text" name="maxPrice" value="<%= (maxPriceStr != null ? maxPriceStr : "") %>" />

        <button type="submit">Search</button>
    </form>

<%
try {
    conn = DBConnection.getConnection();

    // Base query: show all auctions, compute current highest bid
    StringBuilder sql = new StringBuilder(
        "SELECT a.A_ID, a.Name, a.Price AS StartPrice, a.Subcategory, a.SubAttribute, " +
        "       a.CloseDate, a.CloseTime, a.Closed, " +
        "       COALESCE(MAX(b.Price), a.Price) AS CurrentPrice " +
        "FROM auction a " +
        "JOIN posts p ON a.A_ID = p.A_ID " +
        "LEFT JOIN bids_on bo ON a.A_ID = bo.A_ID " +
        "LEFT JOIN bids b ON bo.BID_ID = b.BID_ID " +
        "WHERE 1=1 "  // we'll add filters below
    );

    List<Object> params = new ArrayList<Object>();

    // Status filter: open / closed / (none = all)
    if ("open".equals(statusFilterParam)) {
        sql.append(" AND a.Closed = 0 ");
    } else if ("closed".equals(statusFilterParam)) {
        sql.append(" AND a.Closed = 1 ");
    }

    // Subcategory filter
    if (subcatParam != null && !subcatParam.isEmpty()) {
        sql.append(" AND a.Subcategory = ? ");
        params.add(subcatParam);
    }

    // Price filters (use starting price as base filter)
    if (minPrice != null) {
        sql.append(" AND a.Price >= ? ");
        params.add(minPrice);
    }
    if (maxPrice != null) {
        sql.append(" AND a.Price <= ? ");
        params.add(maxPrice);
    }

    sql.append(
        "GROUP BY a.A_ID, a.Name, a.Price, a.Subcategory, a.SubAttribute, " +
        "         a.CloseDate, a.CloseTime, a.Closed " +
        "ORDER BY a.CloseDate, a.CloseTime"
    );

    ps = conn.prepareStatement(sql.toString());

    int idx = 1;
    for (Object o : params) {
        if (o instanceof String) {
            ps.setString(idx++, (String) o);
        } else if (o instanceof Float) {
            ps.setFloat(idx++, (Float) o);
        }
    }

    rs = ps.executeQuery();

    boolean hasAny = false;

    // Only log into 'searches' if user actually set a price filter
    boolean shouldLogSearch = (minPrice != null || maxPrice != null);
%>
    <table border="1" cellspacing="0" cellpadding="5">
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
    while (rs.next()) {
        hasAny = true;
        int   aId          = rs.getInt("A_ID");
        String name        = rs.getString("Name");
        String subcat      = rs.getString("Subcategory");
        String subAttr     = rs.getString("SubAttribute");
        float startPrice   = rs.getFloat("StartPrice");
        float currentPrice = rs.getFloat("CurrentPrice");
        java.sql.Date cd   = rs.getDate("CloseDate");
        java.sql.Time ct   = rs.getTime("CloseTime");
        boolean closedFlag = rs.getBoolean("Closed");

        String statusLabel = closedFlag ? "Closed" : "Open";

        // Log this search into 'searches' table if user set a price filter
        if (shouldLogSearch) {
            PreparedStatement psSearch = null;
            try {
                psSearch = conn.prepareStatement(
                    "INSERT INTO searches (Min_Price, Max_Price, Username, A_ID) " +
                    "VALUES (?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE Min_Price = VALUES(Min_Price), Max_Price = VALUES(Max_Price)"
                );
                if (minPrice != null) {
                    psSearch.setFloat(1, minPrice);
                } else {
                    psSearch.setNull(1, java.sql.Types.FLOAT);
                }
                if (maxPrice != null) {
                    psSearch.setFloat(2, maxPrice);
                } else {
                    psSearch.setNull(2, java.sql.Types.FLOAT);
                }
                psSearch.setString(3, username);
                psSearch.setInt(4, aId);
                psSearch.executeUpdate();
            } catch (SQLException eIgnore) {
                // ignore logging errors
            } finally {
                if (psSearch != null) try { psSearch.close(); } catch (Exception e) {}
            }
        }
%>
        <tr>
            <td><%= aId %></td>
            <td><%= name %></td>
            <td><%= subcat %></td>
            <td><%= subAttr %></td>
            <td>$<%= String.format("%.2f", startPrice) %></td>
            <td>$<%= String.format("%.2f", currentPrice) %></td>
            <td><%= statusLabel %></td>
            <td><%= cd %> <%= ct %></td>
            <td>
                <a href="viewAuction.jsp?A_ID=<%= aId %>">View</a>
            </td>
        </tr>
<%
    } // end while

    if (!hasAny) {
%>
        <tr>
            <td colspan="9">No matching auctions found.</td>
        </tr>
<%
    }

} catch (SQLException e) {
%>
    <p style="color:red;">Error: <%= e.getMessage() %></p>
<%
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
    </table>
</div>
