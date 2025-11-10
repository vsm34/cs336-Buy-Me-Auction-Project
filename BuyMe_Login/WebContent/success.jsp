<%@ page contentType="text/html; charset=UTF-8" %>
<%
    Object u = session.getAttribute("user");
    if (u == null) {
       
        session.setAttribute("flash", "Please login");
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>BuyMe | Welcome</title>
  <style>
    body {
      font-family: Arial, Helvetica, sans-serif;
      background-color: #f7f7f7;
      margin: 0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .card {
      background: #fff;
      padding: 40px 50px;
      border-radius: 12px;
      box-shadow: 0 6px 16px rgba(0,0,0,0.12);
      text-align: center;
      width: 420px;
    }
    h2 {
      margin: 0 0 10px;
      font-size: 28px;
      color: #222;
    }
    p {
      color: #555;
      margin: 12px 0 22px;
      font-size: 16px;
    }
    .user {
      font-weight: bold;
    }
    .btn {
      display: inline-block;
      background-color: #0073e6;
      color: #fff;
      text-decoration: none;
      padding: 12px 18px;
      border-radius: 6px;
      font-size: 16px;
    }
    .btn:hover {
      background-color: #005bb5;
    }
  </style>
</head>
<body>
  <div class="card">
    <h2>Welcome to BuyMe</h2>
    <p>Signed in as <span class="user"><%= u %></span>.</p>
    <a class="btn" href="logout.jsp">Log out</a>
  </div>
</body>
</html>
