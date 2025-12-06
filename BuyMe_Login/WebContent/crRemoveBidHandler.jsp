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

    String bidParam = request.getParameter("bidId");
    String msg;

    try {
        int bidId = Integer.parseInt(bidParam);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM bids WHERE BID_ID = ?")) {
            ps.setInt(1, bidId);
            int n = ps.executeUpdate();
            if (n > 0) {
                msg = "Bid " + bidId + " removed.";
            } else {
                msg = "Bid " + bidId + " not found.";
            }
        }
    } catch (Exception e) {
        msg = "Error removing bid.";
    }

    response.sendRedirect("crRemoveBidAuction.jsp?msg=" +
            java.net.URLEncoder.encode(msg, "UTF-8"));
%>
