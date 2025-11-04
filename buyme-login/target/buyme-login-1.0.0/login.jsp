<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>BuyMe Login</title>
  <style>
    html, body { height: 100%; margin: 0; font-family: Arial, Helvetica, sans-serif; background:#f7f7f9; }
    .wrap { height: 100%; display: grid; place-items: center; padding: 16px; }
    .card { background:#fff; width: 420px; max-width: 92vw; padding: 28px 32px; border-radius: 14px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
    h1 { margin: 0 0 6px 0; font-size: 28px; letter-spacing: .3px; }
    .sub { margin: 0 0 20px 0; color:#666; font-size: 14px; }
    label { display:block; font-size:14px; margin:12px 0 6px; }
    input[type="text"], input[type="password"] {
      width:100%; height:38px; padding:8px 10px; border:1px solid #ccc; border-radius:8px; font-size:14px;
    }
    .actions { margin-top:18px; display:flex; justify-content:flex-end; }
    button { border:0; padding:10px 16px; border-radius:8px; font-size:14px; cursor:pointer; background:#1f6feb; color:#fff; }
    .error { margin-top:12px; color:#d32f2f; font-size:13px; word-wrap: break-word; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>BuyMe Login</h1>
      <p class="sub">Please sign in to continue</p>

      <form method="post" action="login">
        <label for="username">Username</label>
        <input id="username" name="username" type="text" autocomplete="username" required />

        <label for="password">Password</label>
        <input id="password" name="password" type="password" autocomplete="current-password" required />

        <div class="actions">
          <button type="submit">Log In</button>
        </div>

        <% String err = (String) request.getAttribute("error"); if (err != null) { %>
          <div class="error"><%= err %></div>
        <% } %>
      </form>
    </div>
  </div>
</body>
</html>
