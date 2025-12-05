<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    String name        = request.getParameter("name");
    String priceStr    = request.getParameter("price");
    String reserveStr  = request.getParameter("reserve");
    String subcategory = request.getParameter("subcategory");
    String subattr     = request.getParameter("subattr");
    String closeDateStr= request.getParameter("closeDate");
    String closeTimeStr= request.getParameter("closeTime");

    float price   = 0f;
    float reserve = 0f;

    try {
        price   = Float.parseFloat(priceStr);
        reserve = Float.parseFloat(reserveStr);
    } catch (NumberFormatException e) {
        out.println("<p style='color:red;'>Invalid price or reserve entered.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement psAuction = null;
    PreparedStatement psPost = null;
    ResultSet rsKeys = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        psAuction = conn.prepareStatement(
            "INSERT INTO auction " +
            "(Name, Price, CloseDate, CloseTime, Closed, Subcategory, SubAttribute, Reserve) " +
            "VALUES (?, ?, ?, ?, 0, ?, ?, ?)",
            Statement.RETURN_GENERATED_KEYS
        );

        psAuction.setString(1, name);
        psAuction.setFloat(2, price);
        psAuction.setDate(3, java.sql.Date.valueOf(closeDateStr));
        psAuction.setTime(4, java.sql.Time.valueOf(closeTimeStr + ":00")); // if time input lacks seconds
        psAuction.setString(5, subcategory);
        psAuction.setString(6, (subattr == null || subattr.isEmpty()) ? null : subattr);
        psAuction.setFloat(7, reserve);

        psAuction.executeUpdate();

        rsKeys = psAuction.getGeneratedKeys();
        int newAID = -1;
        if (rsKeys.next()) {
            newAID = rsKeys.getInt(1);
        }

        if (newAID == -1) {
            throw new SQLException("Failed to obtain new auction ID.");
        }

        // Insert into posts so we know who the seller is
        psPost = conn.prepareStatement(
            "INSERT INTO posts (PostDate, Username, A_ID) VALUES (CURDATE(), ?, ?)"
        );
        psPost.setString(1, currentUser);
        psPost.setInt(2, newAID);
        psPost.executeUpdate();

        conn.commit();

        session.setAttribute("flash", "Auction created successfully.");
        response.sendRedirect("myAuctions.jsp");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ignore) {}
        }
        out.println("<p style='color:red;'>Error creating auction: " + e.getMessage() + "</p>");
    } finally {
        if (rsKeys != null) try { rsKeys.close(); } catch (Exception e) {}
        if (psPost != null) try { psPost.close(); } catch (Exception e) {}
        if (psAuction != null) try { psAuction.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
