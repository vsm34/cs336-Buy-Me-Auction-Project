<%
  // End the current session (removes user, etc.)
  if (session != null) {
    session.invalidate();
  }

  // Create a fresh session only to carry a one-time flash message
  javax.servlet.http.HttpSession s = request.getSession(true);
  s.setAttribute("flash", "You have logged out");

  // Redirect back to login without query params; message is stored in session
  response.sendRedirect("login.jsp");
%>
