<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Dashboard</title></head>
<body>
  <h2>Welcome, <%= session.getAttribute("username") %>!</h2>
  <p>You are logged in.</p>
  <form method="post" action="logout"><button type="submit">Log Out</button></form>
</body>
</html>
