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

String aParam = request.getParameter("auctionId");
String msgText;
String errText = null;

if (aParam == null || aParam.isEmpty()) {
    errText = "Missing auction id.";
} else {
    try {
        int aId = Integer.parseInt(aParam);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "insert into deletes(CRID, A_ID) values(?, ?)"
             )) {
            ps.setInt(1, crid);
            ps.setInt(2, aId);
            ps.executeUpdate();
            msgText = "Auction " + aId + " marked removed.";
        }
    } catch (SQLIntegrityConstraintViolationException ex) {
        msgText = "Auction " + aParam + " is already marked removed.";
    } catch (Exception e) {
        errText = "Error removing auction " + aParam + ".";
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
