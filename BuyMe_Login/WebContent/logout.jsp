<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
  // End the current session (removes user, etc.)
  if (session != null) {
    session.invalidate();
  }

  
  javax.servlet.http.HttpSession s = request.getSession(true);
  s.setAttribute("flash", "You have logged out");

 
  response.sendRedirect("login.jsp");
%>
