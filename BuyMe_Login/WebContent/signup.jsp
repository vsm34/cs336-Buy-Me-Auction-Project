<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Sign Up</title>
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

        .signup-container {
            background: white;
            padding: 40px 60px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
            width: 420px;
        }

        h2 {
            color: #222;
            margin-bottom: 30px;
            font-size: 26px;
            letter-spacing: 0.5px;
        }

        label {
            display: block;
            text-align: left;
            font-size: 14px;
            margin-bottom: 4px;
            color: #444;
        }

        input[type="text"],
        input[type="password"],
        input[type="email"] {
            width: 100%;
            padding: 9px;
            margin-bottom: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
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
            margin-top: 10px;
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

<div class="signup-container">
    <h2>Create a BuyMe Account</h2>

    <form action="signupHandler.jsp" method="post">
        <label>Username *</label>
        <input type="text" name="username" required>

        <label>Password *</label>
        <input type="password" name="password" required>

        <label>Confirm Password *</label>
        <!-- IMPORTANT: name MUST be confirmPassword -->
        <input type="password" name="confirmPassword" required>

        <label>First Name (optional)</label>
        <input type="text" name="firstName">

        <label>Last Name (optional)</label>
        <input type="text" name="lastName">

        <label>Email (optional)</label>
        <input type="email" name="email">

        <button type="submit">Sign Up</button>
    </form>

    <%
        String error = request.getParameter("error");
    %>
    <p class="msg <%= (error == null ? "hidden" : "") %>">
        <%= (error == null ? "" : error) %>
    </p>

    <div class="subtext">
        Already have an account?
        <a href="login.jsp">Log in here</a>
    </div>
</div>

</body>
</html>

