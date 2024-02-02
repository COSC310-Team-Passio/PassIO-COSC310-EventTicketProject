<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    String productId = request.getParameter("productId");
    String reviewRating = request.getParameter("reviewRating");
    String reviewComment = request.getParameter("reviewComment");
    String username = (String) session.getAttribute("authenticatedUser");

    if (username != null) {
        try {
            getConnection();
            // Get customerId from the username
            String sqlGetCustomerId = "SELECT customerId FROM Customer WHERE userId = ?";
            PreparedStatement pstmtGetCustomerId = con.prepareStatement(sqlGetCustomerId);
            pstmtGetCustomerId.setString(1, username);
            ResultSet rsCustomerId = pstmtGetCustomerId.executeQuery();

            if (rsCustomerId.next()) {
                int customerId = rsCustomerId.getInt("customerId");
                java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());

                // Insert review
                String sqlInsertReview = "INSERT INTO Review (productId, reviewRating, reviewComment, customerId, reviewDate) VALUES (?, ?, ?, ?,?)";
                PreparedStatement pstmtInsertReview = con.prepareStatement(sqlInsertReview);
                pstmtInsertReview.setInt(1, Integer.parseInt(productId));
                pstmtInsertReview.setInt(2, Integer.parseInt(reviewRating));
                pstmtInsertReview.setString(3, reviewComment);
                pstmtInsertReview.setInt(4, customerId);
                pstmtInsertReview.setDate(5,currentDate);
                pstmtInsertReview.executeUpdate();
                pstmtInsertReview.close();

                // Set success message in session
                session.setAttribute("reviewSuccessMessage", "Review submitted successfully.");
            } else {
                // Handle case where customerId is not found
                out.println("<p>Error: Customer ID not found for username.</p>");
            }

            rsCustomerId.close();
            pstmtGetCustomerId.close();
            response.sendRedirect("product.jsp?id=" + productId); // Redirect back to product page
        } catch (SQLException e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        } catch (NumberFormatException e) {
            out.println("<p>Error: Invalid input</p>");
        } finally {
            closeConnection();
        }
    } else {
        out.println("<p>Error: User not logged in</p>");
    }
%>
