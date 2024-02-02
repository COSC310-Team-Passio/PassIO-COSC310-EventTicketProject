<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    String warehouseId = request.getParameter("warehouseId");
    String productId = request.getParameter("productId");
    int newQuantity = Integer.parseInt(request.getParameter("newQuantity"));

    if(warehouseId != null && productId != null) {
        try {
            getConnection();
            String sql = "UPDATE productinventory SET quantity = ? WHERE warehouseId = ? AND productId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, newQuantity);
            pstmt.setString(2, warehouseId);
            pstmt.setString(3, productId);
            pstmt.executeUpdate();
            pstmt.close();

            response.sendRedirect("warehouse.jsp"); // Redirect back to the warehouse page
        } catch (SQLException e) {
            out.println("SQL Error: " + e.getMessage());
            // Handle the error appropriately
        } finally {
            closeConnection();
        }
    } else {
        out.println("Invalid warehouse or product ID.");
        // Redirect or handle the error
    }
%>
