<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");

String role = (String) session.getAttribute("role");
Integer cridObj = (Integer) session.getAttribute("crid");
if (!"cr".equals(role) || cridObj == null) {
    response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
    return;
}
int crid = cridObj;

String bidParam = request.getParameter("bidId");
String msgText;
String errText = null;

if (bidParam == null || bidParam.isEmpty()) {
    errText = "Missing bid id.";
} else {
    try {
        int bidId = Integer.parseInt(bidParam);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "insert into removes(CRID, BID_ID) values(?, ?)"
             )) {
            ps.setInt(1, crid);
            ps.setInt(2, bidId);
            ps.executeUpdate();
            msgText = "Bid " + bidId + " marked removed.";
        }
    } catch (SQLIntegrityConstraintViolationException ex) {
        msgText = "Bid " + bidParam + " is already marked removed.";
    } catch (Exception e) {
        errText = "Error removing bid " + bidParam + ".";
    }
}

if (errText != null) {
    response.sendRedirect(
        "crRemoveBidAuction.jsp?err=" + java.net.URLEncoder.encode(errText, "UTF-8")
    );
} else {
    response.sendRedirect(
        "crRemoveBidAuction.jsp?msg=" + java.net.URLEncoder.encode(msgText, "UTF-8")
    );
}
%>
