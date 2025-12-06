<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;
    String message = null;
    String messageColor = "green";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String currentPw = request.getParameter("currentPassword");
        String newPw     = request.getParameter("newPassword");
        String confirmPw = request.getParameter("confirmPassword");

        if (currentPw == null || newPw == null || confirmPw == null ||
            currentPw.trim().isEmpty() || newPw.trim().isEmpty() || confirmPw.trim().isEmpty()) {
            message = "All password fields are required.";
            messageColor = "red";
        } else if (!newPw.equals(confirmPw)) {
            message = "New password and confirmation do not match.";
            messageColor = "red";
        } else {
            Connection conn = null;
            PreparedStatement psSel = null;
            PreparedStatement psUpd = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                psSel = conn.prepareStatement(
                    "SELECT Password FROM end_user WHERE Username = ?"
                );
                psSel.setString(1, username);
                rs = psSel.executeQuery();

                boolean ok = false;
                if (rs.next()) {
                    String dbPass = rs.getString("Password");
                    ok = currentPw.equals(dbPass);
                }

                if (!ok) {
                    message = "Current password is incorrect.";
                    messageColor = "red";
                } else {
                    psUpd = conn.prepareStatement(
                        "UPDATE end_user SET Password = ? WHERE Username = ?"
                    );
                    psUpd.setString(1, newPw);
                    psUpd.setString(2, username);
                    psUpd.executeUpdate();
                    message = "Password updated successfully.";
                    messageColor = "green";
                }

            } catch (Exception e) {
                message = "Error updating password: " + e.getMessage();
                messageColor = "red";
            } finally {
                if (rs != null)  try { rs.close(); }  catch (Exception e) {}
                if (psSel != null) try { psSel.close(); } catch (Exception e) {}
                if (psUpd != null) try { psUpd.close(); } catch (Exception e) {}
                if (conn != null)  try { conn.close(); }  catch (Exception e) {}
            }
        }
    }
%>

<div class="page">
  <h2>My Account</h2>
  <p>You are logged in as <strong><%= username %></strong>.</p>

  <h3>Change Password</h3>
  <form method="post" action="myAccount.jsp">
    <p>
      <label>Current Password:</label><br/>
      <input type="password" name="currentPassword" required />
    </p>
    <p>
      <label>New Password:</label><br/>
      <input type="password" name="newPassword" required />
    </p>
    <p>
      <label>Confirm New Password:</label><br/>
      <input type="password" name="confirmPassword" required />
    </p>
    <p>
      <button type="submit">Update Password</button>
    </p>
  </form>

  <% if (message != null) { %>
    <p style="color:<%= messageColor %>;"><%= message %></p>
  <% } %>

</div>
