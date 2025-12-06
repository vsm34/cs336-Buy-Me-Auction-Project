<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String crRole = (String) session.getAttribute("role");
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(crRole) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=" + java.net.URLEncoder.encode("Please log in as Customer Rep", "UTF-8"));
        return;
    }

    String auctionParam = request.getParameter("auctionId");
    String msg;

    try {
        int aId = Integer.parseInt(auctionParam);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM auction WHERE A_ID = ?")) {
            ps.setInt(1, aId);
            int n = ps.executeUpdate();
            if (n > 0) {
                msg = "Auction " + aId + " removed.";
            } else {
                msg = "Auction " + aId + " not found.";
            }
        }
    } catch (Exception e) {
        msg = "Error removing auction.";
    }

    response.sendRedirect("crRemoveBidAuction.jsp?msg=" +
            java.net.URLEncoder.encode(msg, "UTF-8"));
%>
