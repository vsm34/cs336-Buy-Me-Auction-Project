<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BuyMe Customer Rep Login</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            width: 350px;
            text-align: center;
        }

        h1 {
            font-size: 26px;
            margin-bottom: 20px;
        }

        input[type="text"],
        input[type="password"] {
            width: 90%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #bbb;
            border-radius: 5px;
            font-size: 14px;
        }

        button {
            width: 95%;
            padding: 10px;
            background-color: #0073e6;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
        }

        button:hover {
            background-color: #005bb5;
        }

        .msg {
            margin-bottom: 15px;
            font-size: 14px;
        }
        .error {
            color: red;
        }
        .info {
            color: #333;
        }
    </style>
</head>

<body>
    <div class="login-container">

        <h1>BuyMe Customer Rep Login</h1>

        <%
            // Show either ?error=... or ?msg=...
            String err  = request.getParameter("error");
            String msg  = request.getParameter("msg");
            String text = (err != null) ? err : msg;

            if (text != null) {
        %>
            <p id="loginMessage" class="msg <%= (err != null ? "error" : "info") %>">
                <%= text %>
            </p>
        <%
            }
        %>

        <form action="crCheckLogin.jsp" method="post">
            <input type="text" name="crid" placeholder="CRID (Rep ID)" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>

    </div>

    <script>
        const msg = document.getElementById("loginMessage");
        if (msg) {
            setTimeout(() => { msg.style.display = "none"; }, 3000);
        }
    </script>

</body>
</html>
