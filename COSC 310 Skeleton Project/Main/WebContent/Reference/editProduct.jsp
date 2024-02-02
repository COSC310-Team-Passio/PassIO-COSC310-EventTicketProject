<%@ page import="java.sql.*, java.math.BigDecimal, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ include file="jdbc.jsp" %>

<%
    String productId = request.getParameter("productId");
    String message = "";
    String productName = "";
    String productPrice = "";
    String productDesc = "";
    String categoryId = "";
    String warehouseId = "";
    String productQuantity = "";

    try {
        getConnection();
        String inventorySql = "SELECT quantity FROM productinventory WHERE productId = ?";
        PreparedStatement inventoryPstmt = con.prepareStatement(inventorySql);
        inventoryPstmt.setInt(1, Integer.parseInt(productId));
        ResultSet inventoryRs = inventoryPstmt.executeQuery();

        if(inventoryRs.next()) {
            productQuantity = inventoryRs.getString("quantity");
        }
        closeConnection();
    } catch(SQLException e) {
        message = "SQL Error: " + e.getMessage();
    }

    List<Map<String, Object>> categories = new ArrayList<>();
    List<Map<String, Object>> warehouses = new ArrayList<>();

    // Fetch product details
    if(productId != null && !productId.isEmpty()) {
        try {
            getConnection();
            // Fetch product details
            String productSql = "SELECT productName, productPrice, productDesc, categoryId FROM product WHERE productId = ?";
            PreparedStatement productPstmt = con.prepareStatement(productSql);
            productPstmt.setInt(1, Integer.parseInt(productId));
            ResultSet productRs = productPstmt.executeQuery();

            if(productRs.next()) {
                productName = productRs.getString("productName");
                productPrice = productRs.getString("productPrice");
                productDesc = productRs.getString("productDesc");
                categoryId = productRs.getString("categoryId");
            }

            // Fetch warehouseId from productinventory
            String warehouseSql = "SELECT warehouseId FROM productinventory WHERE productId = ?";
            PreparedStatement warehousePstmt = con.prepareStatement(warehouseSql);
            warehousePstmt.setInt(1, Integer.parseInt(productId));
            ResultSet warehouseRs = warehousePstmt.executeQuery();

            if(warehouseRs.next()) {
                warehouseId = Integer.toString(warehouseRs.getInt("warehouseId"));
            }

            productRs.close();
            warehouseRs.close();
            productPstmt.close();
            warehousePstmt.close();
            closeConnection();
        } catch(SQLException e) {
            message = "SQL Error: " + e.getMessage();
        }
    } 

    // Fetch Warehouses for Dropdown
try {
    getConnection();
    String fetchWarehousesSql = "SELECT warehouseId, warehouseName FROM warehouse";
    PreparedStatement fetchWarehousesStmt = con.prepareStatement(fetchWarehousesSql);
    ResultSet warehouseRs = fetchWarehousesStmt.executeQuery();

    while (warehouseRs.next()) {
        Map<String, Object> warehouse = new HashMap<>();
        warehouse.put("id", warehouseRs.getInt("warehouseId"));
        warehouse.put("name", warehouseRs.getString("warehouseName"));
        warehouses.add(warehouse);
    }
    warehouseRs.close();
    fetchWarehousesStmt.close();
    closeConnection();
} catch(SQLException e) {
    message = "SQL Error: " + e.getMessage();
}

    // Handle form submission
    if("POST".equalsIgnoreCase(request.getMethod())) {
        productName = request.getParameter("productName");
        productPrice = request.getParameter("productPrice");
        productDesc = request.getParameter("productDesc");
        categoryId = request.getParameter("categoryId");
        warehouseId = request.getParameter("warehouseId");
        String updatedQuantity = request.getParameter("productQuantity");

        try {
            getConnection();
            // Update product details
            String updateProductSql = "UPDATE product SET productName = ?, productPrice = ?, productDesc = ?, categoryId = ? WHERE productId = ?";
            PreparedStatement updateProductPstmt = con.prepareStatement(updateProductSql);
            updateProductPstmt.setString(1, productName);
            updateProductPstmt.setBigDecimal(2, new BigDecimal(productPrice));
            updateProductPstmt.setString(3, productDesc);
            updateProductPstmt.setInt(4, Integer.parseInt(categoryId));
            updateProductPstmt.setInt(5, Integer.parseInt(productId));
            updateProductPstmt.executeUpdate();

            // Update warehouseId in productinventory
            String updateInventorySql = "UPDATE productinventory SET warehouseId = ?, quantity = ? WHERE productId = ?";
            PreparedStatement updateInventoryPstmt = con.prepareStatement(updateInventorySql);
            updateInventoryPstmt.setInt(1, Integer.parseInt(warehouseId));
            updateInventoryPstmt.setInt(2, Integer.parseInt(updatedQuantity));
            updateInventoryPstmt.setInt(3, Integer.parseInt(productId));
            updateInventoryPstmt.executeUpdate();
    
            message = "Product updated successfully!";
            updateProductPstmt.close();
            updateInventoryPstmt.close();
            closeConnection();
        } catch (SQLException e) {
            message = "SQL Error: " + e.getMessage();
            // ... existing error handling ...
        }
    }

    try {
        getConnection();
        String sql = "SELECT categoryId, categoryName FROM category";
        PreparedStatement pstmt = con.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        while(rs.next()) {
            Map<String, Object> category = new HashMap<>();
            category.put("id", rs.getInt("categoryId"));
            category.put("name", rs.getString("categoryName"));
            categories.add(category);
        }

        rs.close();
        pstmt.close();
        closeConnection();
    } catch(SQLException e) {
        message = "SQL Error: " + e.getMessage();
    }
    
%>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <title>Edit Product</title>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <% if(!message.isEmpty()) { %>
            <p><%= message %></p>
        <% } %>
        <h2>Edit Product</h2>
        <form action="editProduct.jsp?productId=<%= productId %>" method="post">
            <div class="form-group">
                <label>Product Name:</label>
                <input type="text" name="productName" value="<%= productName %>">
            </div>
            <div class="form-group">
                <label>Product Price:</label>
                <input type="text" name="productPrice" value="<%= productPrice %>">
            </div>
            <div class="form-group">
                <label>Product Description:</label>
                <input type="text" name="productDesc" value="<%= productDesc %>">
            </div>
            <div class="form-group">
                <label>Category:</label>
                <select name="categoryId">
                    <% for (Map<String, Object> category : categories) { %>
                        <option value="<%= category.get("id") %>" <%= category.get("id").equals(Integer.parseInt(categoryId)) ? "selected" : "" %>><%= category.get("name") %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>Quantity:</label>
                <input type="number" name="productQuantity" value="<%= productQuantity %>" min="1" required>
            </div>
            <div class="form-group">
                <label>Warehouse:</label>
                <select name="warehouseId">
                    <% for (Map<String, Object> warehouse : warehouses) { %>
                        <option value="<%= warehouse.get("id") %>" <%= warehouse.get("id").toString().equals(warehouseId) ? "selected" : "" %>><%= warehouse.get("name") %></option>
                    <% } %>
                </select>
            </div>        
            <div class="form-group">
                <input type="submit" value="Update Product" class="button">
            </div>
        </form>
    </div>
</body>
</html>
