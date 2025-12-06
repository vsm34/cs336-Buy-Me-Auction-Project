<%@ page import="java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");

    String role = (String) session.getAttribute("role");
    String user = (String) session.getAttribute("username");
    if (user == null || role == null || !"user".equals(role)) {
        response.sendRedirect("login.jsp?error=Please+log+in+to+set+alerts");
        return;
    }

    String aParam = request.getParameter("A_ID");
    if (aParam == null || aParam.trim().isEmpty()) {
        response.sendRedirect("browseAuctions.jsp?error=Missing+auction+id");
        return;
    }

    // Delegate to watchList.jsp which owns the "alert" / watchlist logic
    String redirect = "watchList.jsp?action=add&A_ID=" + URLEncoder.encode(aParam, "UTF-8");
    response.sendRedirect(redirect);
%>

