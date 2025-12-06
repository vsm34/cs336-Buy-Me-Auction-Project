<%@ page import="java.sql.*, java.util.*, utils.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    if (role == null || !"user".equals(role) || currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = currentUser;
    request.setCharacterEncoding("UTF-8");

    String aIdStr      = request.getParameter("A_ID");
    String bidAmountStr= request.getParameter("bidAmount");
    String buyLimitStr = request.getParameter("buyLimit");
    String incrementStr= request.getParameter("increment");

    if (aIdStr == null || bidAmountStr == null) {
        session.setAttribute("flash", "Missing auction or bid amount.");
        response.sendRedirect("index.jsp");
        return;
    }

    int   A_ID;
    float bidAmount;
    Float buyLimit  = null;
    Float increment = null;

    try {
        A_ID      = Integer.parseInt(aIdStr);
        bidAmount = Float.parseFloat(bidAmountStr);
    } catch (NumberFormatException e) {
        session.setAttribute("flash", "Invalid bid amount.");
        response.sendRedirect("viewAuction.jsp?A_ID=" + aIdStr);
        return;
    }

    // If both auto-bid fields are provided and positive, treat as an auto-bid
    boolean isAutoBid = false;
    try {
        if (buyLimitStr != null && !buyLimitStr.isEmpty() &&
            incrementStr != null && !incrementStr.isEmpty()) {

            buyLimit  = Float.parseFloat(buyLimitStr);
            increment = Float.parseFloat(incrementStr);

            if (buyLimit > 0 && increment > 0 && buyLimit >= bidAmount) {
                isAutoBid = true;
            }
        }
    } catch (NumberFormatException e) {
        // invalid auto-bid inputs -> treat as normal bid
        isAutoBid = false;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);  // everything in one transaction

        // 1) Load auction, ensure it's open, and find seller
        ps = conn.prepareStatement(
            "SELECT a.Closed, a.Price, a.Reserve, p.Username AS SellerUsername " +
            "FROM auction a " +
            "LEFT JOIN posts p ON a.A_ID = p.A_ID " +
            "WHERE a.A_ID = ?"
        );
        ps.setInt(1, A_ID);
        rs = ps.executeQuery();

        if (!rs.next()) {
            session.setAttribute("flash", "Auction not found.");
            response.sendRedirect("index.jsp");
            return;
        }

        boolean closed = rs.getBoolean("Closed");
        float auctionStartPrice = rs.getFloat("Price");
        float reserve = rs.getFloat("Reserve");
        String seller = rs.getString("SellerUsername");
        rs.close(); ps.close();

        // Block seller from bidding on own auction
        if (seller != null && seller.equals(username)) {
            session.setAttribute("flash", "You cannot bid on your own auction.");
            conn.rollback();
            response.sendRedirect("viewAuction.jsp?A_ID=" + A_ID);
            return;
        }

        if (closed) {
            session.setAttribute("flash", "This auction is closed. You cannot bid.");
            conn.rollback();
            response.sendRedirect("viewAuction.jsp?A_ID=" + A_ID);
            return;
        }

        // 2) Find current highest bid (if any)
        float currentPrice = auctionStartPrice;
        int    currentTopBidId = -1;
        String currentTopUser  = null;

        ps = conn.prepareStatement(
            "SELECT b.BID_ID, b.Price, pl.Username " +
            "FROM bids b " +
            "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
            "JOIN places pl ON b.BID_ID = pl.BID_ID " +
            "WHERE bo.A_ID = ? " +
            "ORDER BY b.Price DESC, b.Time ASC " +
            "LIMIT 1"
        );
        ps.setInt(1, A_ID);
        rs = ps.executeQuery();
        if (rs.next()) {
            currentTopBidId = rs.getInt("BID_ID");
            currentPrice    = rs.getFloat("Price");
            currentTopUser  = rs.getString("Username");
        }
        rs.close(); ps.close();

        // 3) Validate user's initial bid
        if (bidAmount <= currentPrice) {
            session.setAttribute("flash",
                "Your bid must be higher than the current price ($" + currentPrice + ").");
            conn.rollback();
            response.sendRedirect("viewAuction.jsp?A_ID=" + A_ID);
            return;
        }

        // 4) Insert the user's bid into bids, bids_on, places
        int userBidId = -1;
        ps = conn.prepareStatement(
            "INSERT INTO bids (Price, Time) VALUES (?, CURTIME())",
            Statement.RETURN_GENERATED_KEYS
        );
        ps.setFloat(1, bidAmount);
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        if (rs.next()) {
            userBidId = rs.getInt(1);
        }
        rs.close(); ps.close();

        // Link bid to auction
        ps = conn.prepareStatement(
            "INSERT INTO bids_on (BID_ID, A_ID) VALUES (?, ?)"
        );
        ps.setInt(1, userBidId);
        ps.setInt(2, A_ID);
        ps.executeUpdate();
        ps.close();

        // Who placed it
        ps = conn.prepareStatement(
            "INSERT INTO places (Username, BID_ID) VALUES (?, ?)"
        );
        ps.setString(1, username);
        ps.setInt(2, userBidId);
        ps.executeUpdate();
        ps.close();

        // 5) If auto-bid, insert settings into autobid
        if (isAutoBid) {
            ps = conn.prepareStatement(
                "INSERT INTO autobid (BID_ID, Increment, Buy_Limit, Current) " +
                "VALUES (?, ?, ?, ?)"
            );
            ps.setInt(1, userBidId);
            ps.setFloat(2, increment);
            ps.setFloat(3, buyLimit);
            ps.setFloat(4, bidAmount);
            ps.executeUpdate();
            ps.close();
        }

        // 6) AUTO-BID RESOLUTION LOOP (unchanged)
        boolean changed = true;
        while (changed) {
            changed = false;

            // Recompute current highest bid
            float topPrice = auctionStartPrice;
            String topUser = null;

            ps = conn.prepareStatement(
                "SELECT b.BID_ID, b.Price, pl.Username " +
                "FROM bids b " +
                "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
                "JOIN places pl ON b.BID_ID = pl.BID_ID " +
                "WHERE bo.A_ID = ? " +
                "ORDER BY b.Price DESC, b.Time ASC " +
                "LIMIT 1"
            );
            ps.setInt(1, A_ID);
            rs = ps.executeQuery();
            if (rs.next()) {
                topPrice = rs.getFloat("Price");
                topUser  = rs.getString("Username");
            }
            rs.close(); ps.close();

            // Gather all autobidders for this auction
            class AutoBidder {
                int bidId;
                String user;
                float inc;
                float max;
            }

            List<AutoBidder> candidates = new ArrayList<>();

            ps = conn.prepareStatement(
                "SELECT ab.BID_ID, ab.Increment, ab.Buy_Limit, pl.Username " +
                "FROM autobid ab " +
                "JOIN bids b ON ab.BID_ID = b.BID_ID " +
                "JOIN bids_on bo ON b.BID_ID = bo.BID_ID " +
                "JOIN places pl ON b.BID_ID = pl.BID_ID " +
                "WHERE bo.A_ID = ?"
            );
            ps.setInt(1, A_ID);
            rs = ps.executeQuery();
            while (rs.next()) {
                AutoBidder ab = new AutoBidder();
                ab.bidId = rs.getInt("BID_ID");
                ab.user  = rs.getString("Username");
                ab.inc   = rs.getFloat("Increment");
                ab.max   = rs.getFloat("Buy_Limit");

                // can this autobidder still beat topPrice ?
                if (!ab.user.equals(topUser) && ab.max > topPrice) {
                    candidates.add(ab);
                }
            }
            rs.close(); ps.close();

            if (candidates.isEmpty()) {
                break; // no auto-bidder can raise further
            }

            // Simple rule: pick the auto-bidder with the highest max limit
            AutoBidder best = candidates.get(0);
            for (AutoBidder ab : candidates) {
                if (ab.max > best.max) best = ab;
            }

            float proposed = topPrice + best.inc;
            if (proposed > best.max) {
                proposed = best.max;
            }

            if (proposed <= topPrice) {
                continue; // can't actually outbid
            }

            // Create a new bid on behalf of this auto-bidder
            int newBidId = -1;
            ps = conn.prepareStatement(
                "INSERT INTO bids (Price, Time) VALUES (?, CURTIME())",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setFloat(1, proposed);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) newBidId = rs.getInt(1);
            rs.close(); ps.close();

            // link to auction
            ps = conn.prepareStatement(
                "INSERT INTO bids_on (BID_ID, A_ID) VALUES (?, ?)"
            );
            ps.setInt(1, newBidId);
            ps.setInt(2, A_ID);
            ps.executeUpdate();
            ps.close();

            // who placed it
            ps = conn.prepareStatement(
                "INSERT INTO places (Username, BID_ID) VALUES (?, ?)"
            );
            ps.setString(1, best.user);
            ps.setInt(2, newBidId);
            ps.executeUpdate();
            ps.close();

            // update autobid.Current so DB shows their latest auto-bid amount
            ps = conn.prepareStatement(
                "UPDATE autobid SET Current = ? WHERE BID_ID = ?"
            );
            ps.setFloat(1, proposed);
            ps.setInt(2, best.bidId);
            ps.executeUpdate();
            ps.close();

            changed = true; // run loop again
        }

        conn.commit();
        session.setAttribute("flash", "Your bid has been placed.");
        response.sendRedirect("viewAuction.jsp?A_ID=" + A_ID);

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ignore) {}
        }
        session.setAttribute("flash", "Error placing bid: " + e.getMessage());
        response.sendRedirect("viewAuction.jsp?A_ID=" + aIdStr);
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
