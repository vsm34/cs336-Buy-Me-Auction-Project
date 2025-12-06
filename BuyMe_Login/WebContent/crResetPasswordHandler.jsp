<%@ page import="java.sql.*, utils.DBConnection" %>
<%
    String crRole = (String) session.getAttribute("role");
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(crRole) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=" + java.net.URLEncoder.encode("Please log in as Customer Rep", "UTF-8"));
        return;
    }

    request.setCharacterEncoding("UTF-8");

    String currentUsername = request.getParameter("currentUsername");
    String newUsername = request.getParameter("newUsername");
    String newPassword = request.getParameter("newPassword");
    String action = request.getParameter("action");

    String msg;

    if (currentUsername == null || currentUsername.trim().isEmpty()) {
        msg = "Missing username.";
    } else {
        currentUsername = currentUsername.trim();
        if (newUsername != null) newUsername = newUsername.trim();
        if (newPassword != null) newPassword = newPassword.trim();

        try (Connection conn = DBConnection.getConnection()) {

            if ("delete".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM End_User WHERE Username = ?")) {
                    ps.setString(1, currentUsername);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        msg = "User " + currentUsername + " deleted.";
                    } else {
                        msg = "User " + currentUsername + " not found.";
                    }
                }

            } else { 
                boolean changeUsername = newUsername != null && !newUsername.isEmpty();
                boolean changePassword = newPassword != null && !newPassword.isEmpty();

                if (!changeUsername && !changePassword) {
                    msg = "Nothing to update.";
                } else {
                    StringBuilder sql = new StringBuilder("UPDATE End_User SET ");
                    if (changeUsername) sql.append("Username = ?");
                    if (changePassword) {
                        if (changeUsername) sql.append(", ");
                        sql.append("Password = ?");
                    }
                    sql.append(" WHERE Username = ?");

                    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                        int idx = 1;
                        if (changeUsername) {
                            ps.setString(idx++, newUsername);
                        }
                        if (changePassword) {
                            ps.setString(idx++, newPassword);
                        }
                        ps.setString(idx, currentUsername);

                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            if (changeUsername && changePassword) {
                                msg = "Username and password updated.";
                            } else if (changeUsername) {
                                msg = "Username updated.";
                            } else {
                                msg = "Password updated.";
                            }
                        } else {
                            msg = "User " + currentUsername + " not found.";
                        }
                    }
                }
            }

        } catch (Exception e) {
            msg = "Database error: " + e.getMessage();
        }
    }

    response.sendRedirect("crResetPassword.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>
