<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
String warehouseId = request.getParameter("warehouseId");

if (warehouseId != null && !warehouseId.isEmpty()) {
    try {
        getConnection();
        // Begin transaction
        con.setAutoCommit(false);

        // Delete inventory records for the warehouse
        String deleteInventorySql = "DELETE FROM productinventory WHERE warehouseId = ?";
        PreparedStatement inventoryStmt = con.prepareStatement(deleteInventorySql);
        inventoryStmt.setInt(1, Integer.parseInt(warehouseId));
        inventoryStmt.executeUpdate();

        // Delete the warehouse
        String deleteWarehouseSql = "DELETE FROM warehouse WHERE warehouseId = ?";
        PreparedStatement warehouseStmt = con.prepareStatement(deleteWarehouseSql);
        warehouseStmt.setInt(1, Integer.parseInt(warehouseId));
        warehouseStmt.executeUpdate();

        // Commit transaction
        con.commit();

        inventoryStmt.close();
        warehouseStmt.close();
    } catch (SQLException e) {
        // Rollback in case of error
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException se) {
                // Handle rollback error
            }
        }
        out.println("SQL Error: " + e.getMessage());
    } finally {
        if (con != null) {
            try {
                con.setAutoCommit(true);
            } catch (SQLException se) {
                // Handle error setting auto-commit
            }
        }
        closeConnection();
    }
    // Redirect back to the warehouse page
    response.sendRedirect("warehouse.jsp");
} else {
    // Handle invalid warehouse ID
    out.println("Invalid Warehouse ID.");
}
%>
