<%@ page import="java.sql.*,utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe - Customer Rep Questions</title>
</head>
<body>

<%@ include file="header.jsp" %>

<%
    Integer cridObj = (Integer) session.getAttribute("crid");

    if (!"cr".equals(role) || cridObj == null) {
        response.sendRedirect("crLogin.jsp?msg=" + java.net.URLEncoder.encode("Please log in as Customer Rep", "UTF-8"));
        return;
    }

    int crid = cridObj.intValue();
%>

<div class="page">
    <h2>Answer User Questions</h2>

    <table border="1" cellpadding="6" cellspacing="0">
        <tr>
            <th>Q ID</th>
            <th>Question</th>
            <th>Asked By</th>
            <th>Status</th>
            <th>Action</th>
        </tr>

        <%
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT q.Q_ID, q.Q_Text, q.Username, a.CRID " +
                     "FROM questionasks q " +
                     "LEFT JOIN answers a ON q.Q_ID = a.Q_ID " +
                     "ORDER BY q.Q_ID")) {

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int qid = rs.getInt("Q_ID");
                        String qtext = rs.getString("Q_Text");
                        String uname = rs.getString("Username");
                        Integer answeredBy = (Integer) rs.getObject("CRID");
        %>
                        <tr>
                            <td><%= qid %></td>
                            <td><%= qtext %></td>
                            <td><%= uname %></td>
                            <td>
                                <%
                                    if (answeredBy == null) {
                                %>
                                    Not answered
                                <%
                                    } else if (answeredBy.intValue() == crid) {
                                %>
                                    Answered by you (CRID <%= answeredBy %>)
                                <%
                                    } else {
                                %>
                                    Answered by CRID <%= answeredBy %>
                                <%
                                    }
                                %>
                            </td>
                            <td>
                                <%
                                    if (answeredBy == null) {
                                %>
                                    <a href="crAnswerQuestion.jsp?qid=<%= qid %>">Mark answered by me</a>
                                <%
                                    } else {
                                %>
                                    —
                                <%
                                    }
                                %>
                            </td>
                        </tr>
        <%
                    }
                }
            } catch (Exception e) {
        %>
                <tr>
                    <td colspan="5">Error loading questions.</td>
                </tr>
        <%
            }
        %>
    </table>

    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
    %>
        <p><strong><%= msg %></strong></p>
    <%
        }
    %>
</div>

</body>
</html>
