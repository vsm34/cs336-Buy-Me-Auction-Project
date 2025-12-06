<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, utils.DBConnection" %>

<%@ include file="header.jsp" %>

<%
    // Only logged-in end users (buyers/sellers) can ask questions
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp?error=Please+log+in+to+ask+questions");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String qText = request.getParameter("question");
        if (qText == null || qText.trim().isEmpty()) {
            message = "Please enter a question before submitting.";
        } else {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO questionasks (Q_Text, Username) VALUES (?, ?)"
                 )) {
                ps.setString(1, qText.trim());
                ps.setString(2, currentUser);
                ps.executeUpdate();
                message = "Your question has been submitted! A customer representative will respond via the FAQ page.";
            } catch (Exception e) {
                e.printStackTrace();
                message = "Error saving your question. Please try again.";
            }
        }
    }
%>

<div class="page">
    <h2>Ask a Question</h2>

    <p>
        Submit any question about using BuyMe or a particular auction.
        Customer reps will see it and mark it answered in the FAQ system.
    </p>

    <% if (message != null) { %>
        <p style="color:blue;"><%= message %></p>
    <% } %>

    <form method="post" action="askQuestion.jsp">
        <p>
            <label for="question">Your question:</label><br>
            <textarea id="question" name="question"
                      rows="5" cols="60"
                      maxlength="500"
                      required></textarea>
        </p>

        <p>
            <button type="submit">Submit Question</button>
            &nbsp;
            <a href="faqSearch.jsp">Back to FAQ</a>
        </p>
    </form>
</div>
