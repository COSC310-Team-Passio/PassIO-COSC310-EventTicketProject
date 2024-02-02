<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
    <title>Quantum Cannoncraft - Product Information</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

<%@ include file="header3.jsp" %>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8 text-center">

            <%
            // Get product name to search for
            String productId = request.getParameter("id");

            String sql = "SELECT productName, productPrice, productImageURL, productDesc FROM Product WHERE productId = ?";

            NumberFormat currFormat = NumberFormat.getCurrencyInstance();

            try {
                getConnection();
                Statement stmt = con.createStatement();           
                stmt.execute("USE orders");
                
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(productId));            
                
                ResultSet rst = pstmt.executeQuery();
                        
                if (!rst.next()) {
                    out.println("Invalid product");
                } else {       
                    out.println("<h2>"+rst.getString(1)+"</h2>"); // Displaying product name
                    out.println("<img src=\""+rst.getString(3)+"\" class=\"img-fluid\" width=\"300\" height=\"300\">"); // Displaying product image
                    
                    out.println("<table class=\"table\">");
                    out.println("<tr><th>Price</th><td>" + currFormat.format(rst.getDouble(2)) + "</td></tr>"); // Displaying product price
                    out.println("<tr><th>Description</th><td>" + rst.getString(4) + "</td></tr>"); // Displaying product description
                    out.println("</table>");
                    
                    out.println("<h3><a href=\"addcart.jsp?id="+productId+ "&name=" + rst.getString(1)
                                            + "&price=" + rst.getDouble(2)+"\">Add to Cart</a></h3>");     
                    
                    out.println("<h3><a href=\"listprod.jsp\">Continue Shopping</a></h3>");
                }

                // Product Review Section
                String reviewSql = "SELECT r.reviewRating, r.reviewDate, r.reviewComment, c.userid " +
                                   "FROM Review r " +
                                   "JOIN Customer c ON r.customerId = c.customerId " +
                                   "WHERE r.productId = ?";
                PreparedStatement reviewPstmt = con.prepareStatement(reviewSql);
                reviewPstmt.setInt(1, Integer.parseInt(productId));
                ResultSet reviewRs = reviewPstmt.executeQuery();
    
                out.println("<div class='product-reviews'>");
                out.println("<h3>Product Reviews</h3>");
    
                if (!reviewRs.isBeforeFirst()) {
                    out.println("<p>No reviews available for this product.</p>");
                } else {
                    while (reviewRs.next()) {
                        String username = reviewRs.getString("userid");
                        out.println("<div class='review-box'>"); // Use review-box class for styling
                        out.println("<p>Rating: " + reviewRs.getInt("reviewRating") + "/5</p>");
                        out.println("<p>Date: " + reviewRs.getDate("reviewDate") + "</p>");
                        out.println("<p>Comment: " + reviewRs.getString("reviewComment") + "</p>");
                        out.println("<p>Reviewed by: " + username + "</p>");
                        out.println("</div>"); // Close the review-box div
                    }
                }
                reviewRs.close();
                reviewPstmt.close();

            } catch (SQLException ex) {
                out.println("<p>Error: " + ex.getMessage() + "</p>");
            } finally {
                closeConnection();
            }

            String reviewSuccessMessage = (String) session.getAttribute("reviewSuccessMessage");
            if (reviewSuccessMessage != null && !reviewSuccessMessage.isEmpty()) {
                out.println("<p>" + reviewSuccessMessage + "</p>");
                // Clear the message so it doesn't display again on refresh
                session.removeAttribute("reviewSuccessMessage");
            }
            %>

        </div>
    </div>
</div>

<%-- Review Submission Form --%>
<h3>Write a Review</h3>
<form action="submitReview.jsp" method="post">
    <input type="hidden" name="productId" value="<%= productId %>">
    <div class="form-group">
        <label for="reviewRating">Rating:</label>
        <select id="reviewRating" name="reviewRating">
            <option value="1">1 - Poor</option>
            <option value="2">2 - Fair</option>
            <option value="3">3 - Good</option>
            <option value="4">4 - Very Good</option>
            <option value="5">5 - Excellent</option>
        </select>
    </div>
    <div class="form-group">
        <label for="reviewComment">Comment:</label>
        <textarea id="reviewComment" name="reviewComment" rows="4" required></textarea>
    </div>
    <input type="submit" value="Submit Review" class="button">
</form>

</body>
</html>
