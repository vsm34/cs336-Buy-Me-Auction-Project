<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String role = (String) session.getAttribute("role");
    Integer cridObj = (Integer) session.getAttribute("crid");
    if (!"cr".equals(role) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=Please+log+in+as+Customer+Rep");
        return;
    }
    int crid = cridObj;

    String qidParam = request.getParameter("qid");
    String msg;

    if (qidParam == null) {
        msg = "Missing question ID.";
    } else {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO answers (Q_ID, CRID) VALUES (?, ?)")) {

            ps.setInt(1, Integer.parseInt(qidParam));
            ps.setInt(2, crid);
            ps.executeUpdate();
            msg = "Question " + qidParam + " marked as answered by you.";
        } catch (SQLIntegrityConstraintViolationException ex) {
            // In case it was already answered
            msg = "Question " + qidParam + " is already answered.";
        } catch (Exception e) {
            msg = "Error updating answer for question " + qidParam + ".";
        }
    }

    response.sendRedirect("crQuestions.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>
