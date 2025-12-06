<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ include file="header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    //have to be logged in as customer rep
    if (role == null || !"cr".equals(role)) {
        response.sendRedirect("crLogin.jsp?error=Please+log+in+as+Customer+Rep");
        return;
    }

    //
    int crid = -1;
    if (currentUser != null && currentUser.startsWith("CR-")) {
        try {
            crid = Integer.parseInt(currentUser.substring(3));
        } catch (NumberFormatException ignore) {}
    }

    //If opst with answer, save it
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String qidStr = request.getParameter("qid");
        String answerText = request.getParameter("answerText");

        if (qidStr != null && answerText != null &&
            !qidStr.trim().isEmpty() && !answerText.trim().isEmpty() &&
            crid > 0) {

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO answers (Q_ID, CRID, Answer_Text) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "  Answer_Text = VALUES(Answer_Text), " +
                     "  CRID = VALUES(CRID)"
                 )) {
                ps.setInt(1, Integer.parseInt(qidStr));
                ps.setInt(2, crid);
                ps.setString(3, answerText.trim());
                ps.executeUpdate();
                session.setAttribute("flash", "Answer saved for question #" + qidStr);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("flash", "Error saving answer: " + e.getMessage());
            }
        } else {
            session.setAttribute("flash", "Please enter an answer.");
        }

        response.sendRedirect("crAnswerQuestion.jsp");
        return;
    }

    String flash = (String) session.getAttribute("flash");
    if (flash != null) {
        session.removeAttribute("flash");
    }
%>

<div class="page">
    <h2>Answer User Questions</h2>

    <% if (flash != null) { %>
        <p style="color:blue;"><%= flash %></p>
    <% } %>

    <p>
        Below are all questions users have asked. You can add or edit an answer.
    </p>

    <table border="1" cellpadding="6">
        <tr>
            <th>Q_ID</th>
            <th>Question</th>
            <th>Asked By</th>
            <th>Current Answer</th>
            <th>Update Answer</th>
        </tr>

        <%
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT qa.Q_ID, qa.Q_Text, qa.Username, an.Answer_Text " +
                     "FROM questionasks qa " +
                     "LEFT JOIN answers an ON qa.Q_ID = an.Q_ID " +
                     "ORDER BY qa.Q_ID"
                 );
                 ResultSet rs = ps.executeQuery()) {

                boolean any = false;
                while (rs.next()) {
                    any = true;
                    int qid = rs.getInt("Q_ID");
                    String qText = rs.getString("Q_Text");
                    String askedBy = rs.getString("Username");
                    String ansText = rs.getString("Answer_Text");
                    if (ansText == null || ansText.trim().isEmpty()) {
                        ansText = "(Not answered yet)";
                    }
        %>
        <tr>
            <td><%= qid %></td>
            <td><%= qText %></td>
            <td><%= askedBy %></td>
            <td><%= ansText %></td>
            <td>
                <form method="post" action="crAnswerQuestion.jsp">
                    <input type="hidden" name="qid" value="<%= qid %>">
                    <textarea name="answerText" rows="3" cols="40"
                              placeholder="Type your answer here..."></textarea><br>
                    <button type="submit">Save Answer</button>
                </form>
            </td>
        </tr>
        <%
                }
                if (!any) {
        %>
        <tr>
            <td colspan="5">No questions have been asked yet.</td>
        </tr>
        <%
                }
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="5" style="color:red;">Error loading questions: <%= e.getMessage() %></td>
        </tr>
        <%
            }
        %>
    </table>
</div>
