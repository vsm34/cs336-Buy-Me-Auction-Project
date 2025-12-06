<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ include file="header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String q = request.getParameter("q");
    if (q == null) q = "";
    String like = "%" + q + "%";
%>

<div class="page">
    <h2>FAQ / Questions</h2>

    <form method="get" action="faq.jsp" style="margin-bottom: 12px;">
        <label>Search questions or keywords:
            <input type="text" name="q" value="<%= q %>">
        </label>
        <button type="submit">Search</button>

        <% if ("user".equals(role)) { %>
            &nbsp;&nbsp;
            <a href="askQuestion.jsp">Ask a Question</a>
        <% } %>
    </form>

    <table border="1" cellpadding="6">
        <tr>
            <th>Question ID</th>
            <th>Question</th>
            <th>Asked By</th>
            <th>Answer</th>
        </tr>

        <%
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT qa.Q_ID, qa.Q_Text, qa.Username, an.Answer_Text " +
                     "FROM questionasks qa " +
                     "LEFT JOIN answers an ON qa.Q_ID = an.Q_ID " +
                     "WHERE (? = '' OR qa.Q_Text LIKE ?) " +
                     "ORDER BY qa.Q_ID"
                 )) {

                ps.setString(1, q);
                ps.setString(2, like);

                try (ResultSet rs = ps.executeQuery()) {
                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        String ans = rs.getString("Answer_Text");
                        if (ans == null || ans.trim().isEmpty()) {
                            ans = "Not answered yet.";
                        }
        %>
        <tr>
            <td><%= rs.getInt("Q_ID") %></td>
            <td><%= rs.getString("Q_Text") %></td>
            <td><%= rs.getString("Username") %></td>
            <td><%= ans %></td>
        </tr>
        <%
                    }
                    if (!any) {
        %>
        <tr><td colspan="4">No questions match that search.</td></tr>
        <%
                    }
                }
            } catch (Exception e) {
        %>
        <tr>
            <td colspan="4" style="color:red;">Error loading questions: <%= e.getMessage() %></td>
        </tr>
        <%
            }
        %>
    </table>
</div>
