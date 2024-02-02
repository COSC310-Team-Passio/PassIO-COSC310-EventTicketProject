<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    String productId = request.getParameter("productId");

    if(productId != null && !productId.isEmpty()) {
        try {
            getConnection();
            con.setAutoCommit(false);

            // First, delete or update foreign key references
            // Delete from orderproduct, incart, productinventory, review where productId matches
            String[] deleteQueries = {
                "DELETE FROM orderproduct WHERE productId = ?",
                "DELETE FROM incart WHERE productId = ?",
                "DELETE FROM productinventory WHERE productId = ?",
                "DELETE FROM review WHERE productId = ?"
            };

            PreparedStatement pstmt;
            for (String query : deleteQueries) {
                pstmt = con.prepareStatement(query);
                pstmt.setInt(1, Integer.parseInt(productId));
                pstmt.executeUpdate();
                pstmt.close();
            }

            // Now, delete the product
            String deleteProductSql = "DELETE FROM product WHERE productId = ?";
            pstmt = con.prepareStatement(deleteProductSql);
            pstmt.setInt(1, Integer.parseInt(productId));
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();

            if(rowsAffected > 0) {
                con.commit();
                response.sendRedirect("updatedeleteprod.jsp");
            } else {
                con.rollback();
                response.sendRedirect("updatedeleteprod.jsp?error=Product not found or could not be deleted");
            }
        } catch(SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException se) {
                // Handle rollback error
            }
            response.sendRedirect("updatedeleteprod.jsp?error=SQL Error: " + e.getMessage());
        } catch(NumberFormatException e) {
            response.sendRedirect("updatedeleteprod.jsp?error=Invalid Product ID format");
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    closeConnection();
                } catch (SQLException e) {
                    // Handle close connection error
                }
            }
        }
    } else {
        response.sendRedirect("updatedeleteprod.jsp?error=Invalid Product ID");
    }
%>
