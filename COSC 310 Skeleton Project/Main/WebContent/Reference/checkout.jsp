<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
<title>Quantum Cannoncraft - Checkout</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

<%
    String userName = (String) session.getAttribute("authenticatedUser");
    String customerId = null;

    if (userName != null) {
        try {
            getConnection();
            String sql = "SELECT customerId FROM Customer WHERE userid = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userName);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                customerId = rs.getString("customerId");
            }

            rs.close();
            pstmt.close();
            closeConnection();
        } catch (SQLException e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        }
    }

    if (customerId != null) {
        // Automatically redirect to order.jsp with the customerId
        response.sendRedirect("order.jsp?customerId=" + customerId);
    } else {
        // If no customer ID found or not logged in, display a message or redirect
        out.println("<h1>Please log in to proceed to checkout.</h1>");
    }
%>

</body>
</html>
