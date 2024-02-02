<!DOCTYPE html>
<html>
<head>
    <title>Warehouse Inventory</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <%@ include file="auth.jsp"%>
        <%@ page import="java.sql.*" %>
        <%@ include file="jdbc.jsp" %>

                <h2>Add New Warehouse</h2>
                <form action="addWarehouse.jsp" method="post">
                    <label for="warehouseName">Warehouse Name:</label>
                    <input type="text" id="warehouseName" name="warehouseName" required>
                    <input type="submit" value="Add Warehouse">
                </form>
        
                <%
                try {
                    getConnection();
                    // Fetch all warehouses
                    String warehouseSql = "SELECT warehouseId, warehouseName FROM warehouse";
                    PreparedStatement warehouseStmt = con.prepareStatement(warehouseSql);
                    ResultSet warehouseRs = warehouseStmt.executeQuery();
    
                    while (warehouseRs.next()) {
                        String warehouseId = warehouseRs.getString("warehouseId");
                        String warehouseName = warehouseRs.getString("warehouseName");
    
                        // Flex container for warehouse name and edit button
                        out.println("<div style='display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;'>");
                        out.println("<h3 style='margin: 0;'>" + warehouseName + "</h3>");
                
                        // Edit button
                        out.println("<form action='editWarehouse.jsp' method='post' style='margin: 0;'>");
                        out.println("<input type='hidden' name='warehouseId' value='" + warehouseId + "'/>");
                        out.println("<input type='submit' value='Edit Warehouse' class='button'/>");
                        out.println("</form>");
                        out.println("<form action='deleteWarehouse.jsp' method='post'>");
                        out.println("<input type='hidden' name='warehouseId' value='" + warehouseId + "'/>");
                        out.println("<input type='submit' value='Delete Warehouse' class='button'/>");
                        out.println("</form>");
                        out.println("</div>");
                
                        // Table for warehouse inventory
                        out.println("<table class='table' border='1'><tr><th>Product</th><th>Quantity</th></tr>");
    
                        // Fetch products for each warehouse
                        String productSql = "SELECT p.productName, pi.quantity FROM productinventory pi " +
                                            "JOIN product p ON pi.productId = p.productId " +
                                            "WHERE pi.warehouseId = ?";
                        PreparedStatement productStmt = con.prepareStatement(productSql);
                        productStmt.setString(1, warehouseId);
                        ResultSet productRs = productStmt.executeQuery();
    
                        while (productRs.next()) {
                            out.println("<tr><td>" + productRs.getString("productName") + "</td>");
                            out.println("<td>" + productRs.getInt("quantity") + "</td></tr>");
                        }
                        out.println("</table>");    
                        productRs.close();
                        productStmt.close();
                    }
                    warehouseRs.close();
                    warehouseStmt.close();
                } catch (SQLException e) {
                    out.println("SQL Error: " + e.getMessage());
                } finally {
                    closeConnection();
                }
            %>
        </div>
    </body>
    </html>