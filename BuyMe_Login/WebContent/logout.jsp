<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Kill the session so all roles & username are cleared
    if (session != null) {
        session.invalidate();
    }

    // Optional: you could also add a flash message here if you want
    // session.setAttribute("flash", "You have been logged out.");

    // Send user to the home page where they can choose login type
    response.sendRedirect("index.jsp");
%>
