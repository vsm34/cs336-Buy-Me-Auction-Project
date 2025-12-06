<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>BuyMe | Login</title>
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

    .login-container {
      background: white;
      padding: 40px 60px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      text-align: center;
      width: 350px;
    }

    h2 {
      color: #222;
      margin-bottom: 30px;
      font-size: 28px;
      letter-spacing: 0.5px;
    }

    label {
      display: block;
      text-align: left;
      font-size: 16px;
      margin-bottom: 6px;
      color: #444;
    }

    input[type="text"],
    input[type="password"] {
      width: 100%;
      padding: 10px;
      margin-bottom: 20px;
      border: 1px solid #ccc;
      border-radius: 6px;
      font-size: 15px;
    }

    button {
      background-color: #0073e6;
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
      width: 100%;
    }

    button:hover {
      background-color: #005bb5;
    }

    .msg {
      margin-top: 12px;
      font-size: 14px;
      color: #b00020;
      min-height: 18px;
    }

    .hidden { display: none; }

    .subtext {
      margin-top: 16px;
      font-size: 13px;
    }
    .subtext a {
      color: #0073e6;
      text-decoration: none;
    }
    .subtext a:hover {
      text-decoration: underline;
    }
  </style>
</head>

<body>
  <div class="login-container">
    <h2>BuyMe Login</h2>

    <form action="checkLogin.jsp" method="post">
      <label>Username:</label>
      <input type="text" name="username" required>
      <label>Password:</label>
      <input type="password" name="password" required>
      <button type="submit">Log In</button>
    </form>

    <%
      String msg = request.getParameter("error");
      String flash = (String) session.getAttribute("flash");
      if (flash != null && !flash.isEmpty()) {
          msg = flash;
          session.removeAttribute("flash");
      }
    %>

    <p id="message" class="msg <%= (msg == null) ? "hidden" : "" %>">
      <%= (msg == null) ? "" : msg %>
    </p>

    <div class="subtext">
        Don’t have an account? <a href="signup.jsp">Sign up here</a>
    </div>
  </div>

  <script>
    (function () {
      var el = document.getElementById('message');
      if (el && !el.classList.contains('hidden')) {
        setTimeout(function () { el.classList.add('hidden'); }, 3000);
      }
      if (window.location.search) {
        try {
          var url = new URL(window.location.href);
          url.search = '';
          window.history.replaceState({}, document.title, url.toString());
        } catch (e) {}
      }
    })();
  </script>
</body>
</html>

