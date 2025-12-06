<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String role = (String) session.getAttribute("role");
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(role) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    String mode = request.getParameter("mode");
    String msg;

    try (Connection conn = DBConnection.getConnection()) {
        if ("bid".equals(mode)) {
            String bidParam = request.getParameter("bidId");
            int bidId = Integer.parseInt(bidParam);

            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM bids WHERE BID_ID = ?")) {
                ps.setInt(1, bidId);
                int rows = ps.executeUpdate();
                msg = rows > 0 ? "Bid " + bidId + " removed."
                               : "Bid " + bidId + " not found.";
            }

        } else if ("auction".equals(mode)) {
            String aParam = request.getParameter("auctionId");
            int aId = Integer.parseInt(aParam);

            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM auction WHERE A_ID = ?")) {
                ps.setInt(1, aId);
                int rows = ps.executeUpdate();
                msg = rows > 0 ? "Auction " + aId + " removed."
                               : "Auction " + aId + " not found.";
            }

        } else {
            msg = "Unknown action.";
        }

    } catch (Exception e) {
        e.printStackTrace();
        msg = "Database error while removing.";
    }

    response.sendRedirect("crRemoveBidAuction.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));

%>
