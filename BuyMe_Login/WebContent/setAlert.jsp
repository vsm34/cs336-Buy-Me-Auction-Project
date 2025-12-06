<%@ page import="java.sql.*,utils.DBConnection" %>
<%
request.setCharacterEncoding("UTF-8");


String role = (String) session.getAttribute("role");
String user = (String) session.getAttribute("username");
if (user == null || role == null || !"user".equals(role)) {
    response.sendRedirect("login.jsp?error=Please+log+in+to+set+alerts");
    return;
}

String aParam = request.getParameter("A_ID");
if (aParam == null) {
    response.sendRedirect("browseAuctions.jsp?error=Missing+auction+id");
    return;
}

int aid;
try {
    aid = Integer.parseInt(aParam);
} catch (NumberFormatException e) {
    response.sendRedirect("browseAuctions.jsp?error=Invalid+auction+id");
    return;
}

try (Connection conn = DBConnection.getConnection()) {


    Integer alertId = null;

    try (PreparedStatement ps = conn.prepareStatement(
            "SELECT Alert_ID FROM alertsets WHERE Username = ? AND isActive = 1 LIMIT 1")) {
        ps.setString(1, user);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                alertId = rs.getInt("Alert_ID");
            }
        }
    }

    if (alertId == null) {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO alertsets (isActive, DateCreated, Username) VALUES (1, CURDATE(), ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    alertId = rs.getInt(1);
                }
            }
        }
    }


    try (PreparedStatement ps = conn.prepareStatement(
            "SELECT 1 FROM watches WHERE Alert_ID = ? AND A_ID = ?")) {
        ps.setInt(1, alertId);
        ps.setInt(2, aid);
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                try (PreparedStatement ins = conn.prepareStatement(
                        "INSERT INTO watches (Alert_ID, A_ID) VALUES (?, ?)")) {
                    ins.setInt(1, alertId);
                    ins.setInt(2, aid);
                    ins.executeUpdate();
                }
            }
        }
    }

} catch (Exception e) {

}

response.sendRedirect("myAlerts.jsp?msg=Added+to+your+alerts");
%>

