<!DOCTYPE html>
<html>
<head>
    <title>Edit Warehouse</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ page import="java.sql.*" %>
    <%@ include file="jdbc.jsp" %>

    <div class="container">
        <h2>Edit Warehouse Inventory</h2>

        <%
        String warehouseId = request.getParameter("warehouseId");
        if (warehouseId == null || warehouseId.isEmpty()) {
            out.println("<p>Invalid warehouse ID.</p>");
        } else {
            try {
                getConnection();
                // Fetch warehouse name
                String fetchWarehouseSql = "SELECT warehouseName FROM warehouse WHERE warehouseId = ?";
                PreparedStatement fetchWarehouseStmt = con.prepareStatement(fetchWarehouseSql);
                fetchWarehouseStmt.setInt(1, Integer.parseInt(warehouseId));
                ResultSet warehouseRs = fetchWarehouseStmt.executeQuery();
                if (warehouseRs.next()) {
                    String warehouseName = warehouseRs.getString("warehouseName");
                    out.println("<h3>Editing Inventory for " + warehouseName + "</h3>");
                }

                // Fetch products in the warehouse
                String productSql = "SELECT pi.productId, p.productName, pi.quantity FROM productinventory pi " +
                                    "JOIN product p ON pi.productId = p.productId " +
                                    "WHERE pi.warehouseId = ?";
                PreparedStatement productStmt = con.prepareStatement(productSql);
                productStmt.setInt(1, Integer.parseInt(warehouseId));
                ResultSet productRs = productStmt.executeQuery();

                while (productRs.next()) {
                    out.println("<form action='updateWarehouseInventory.jsp' method='post'>");
                    out.println("<input type='hidden' name='warehouseId' value='" + warehouseId + "'>");
                    out.println("<input type='hidden' name='productId' value='" + productRs.getString("productId") + "'>");
                    out.println("<p>" + productRs.getString("productName") + " (Current Quantity: " + productRs.getInt("quantity") + ")</p>");
                    out.println("<label>Update Quantity:</label>");
                    out.println("<input type='number' name='newQuantity' min='0' required>");
                    out.println("<input type='submit' value='Update' class='button'>");
                    out.println("</form>");
                }

                productRs.close();
                productStmt.close();
                warehouseRs.close();
                fetchWarehouseStmt.close();
            } catch (SQLException e) {
                out.println("<p>SQL Error: " + e.getMessage() + "</p>");
            } finally {
                closeConnection();
            }
        }
        %>
    </div>
</body>
</html>
