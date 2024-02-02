<%@ page import="java.sql.*, java.math.BigDecimal, java.util.List, java.util.ArrayList" %>

<!DOCTYPE html>
<html>
<head>
    <title>Add Product</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <%@ include file="auth.jsp"%>
        <%@ page import="java.sql.*" %>
        <%@ include file="jdbc.jsp" %>

        <%
            String message = "";
            List<String> warehouses = new ArrayList<>();

            try {
                getConnection();
                String fetchWarehousesSql = "SELECT warehouseId, warehouseName FROM warehouse";
                Statement warehouseStmt = con.createStatement();
                ResultSet warehouseRs = warehouseStmt.executeQuery(fetchWarehousesSql);

                while (warehouseRs.next()) {
                    warehouses.add(warehouseRs.getInt("warehouseId") + "-" + warehouseRs.getString("warehouseName"));
                }
                warehouseRs.close();
                warehouseStmt.close();
            } catch (SQLException e) {
                message = "SQL Error: " + e.getMessage();
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String productName = request.getParameter("productName");
                String productPrice = request.getParameter("productPrice");
                String productDesc = request.getParameter("productDesc");
                String categoryId = request.getParameter("categoryId");
                String warehouseId = request.getParameter("warehouseId");

                PreparedStatement productPstmt = null;
                PreparedStatement inventoryPstmt = null;

                try {
                    getConnection();
                    con.setAutoCommit(false);

                    // Insert product
                    String sqlProduct = "INSERT INTO product (productName, productPrice, productImageURL, productImage, productDesc, categoryId) VALUES (?, ?, 'http://example.com/image.jpg', 0x123456, ?, ?)";
                    productPstmt = con.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS);
                    productPstmt.setString(1, productName);
                    productPstmt.setBigDecimal(2, new BigDecimal(productPrice));
                    productPstmt.setString(3, productDesc);
                    productPstmt.setInt(4, Integer.parseInt(categoryId));
                    productPstmt.executeUpdate();

                    // Retrieve the generated product ID
                    ResultSet generatedKeys = productPstmt.getGeneratedKeys();
                    int newProductId = 0;
                    if (generatedKeys.next()) {
                        newProductId = generatedKeys.getInt(1);
                    }
					String productQuantity = request.getParameter("productQuantity"); // Get the quantity from the form

                    // Insert into productinventory
					String sqlInventory = "INSERT INTO productinventory (productId, warehouseId, quantity, price) VALUES (?, ?, ?, ?)";
					inventoryPstmt = con.prepareStatement(sqlInventory);
					inventoryPstmt.setInt(1, newProductId);
					inventoryPstmt.setInt(2, Integer.parseInt(warehouseId));
					inventoryPstmt.setInt(3, Integer.parseInt(productQuantity)); // Use the provided quantity
					inventoryPstmt.setBigDecimal(4, new BigDecimal(productPrice));
					inventoryPstmt.executeUpdate();

                    con.commit();
                    message = "Product added successfully!";
                } catch (SQLException ex) {
                    message = "SQL Error: " + ex.getMessage();
                    if (con != null) {
                        try {
                            con.rollback();
                        } catch (SQLException se) {
                            message += " Error on rollback: " + se.getMessage();
                        }
                    }
                } finally {
                    if (productPstmt != null) productPstmt.close();
                    if (inventoryPstmt != null) inventoryPstmt.close();
                    con.setAutoCommit(true);
                    closeConnection();
                }
            }

            List<String> categories = new ArrayList<>();
            try {
                getConnection();
                String fetchCategoriesSql = "SELECT categoryId, categoryName FROM category";
                Statement categoryStmt = con.createStatement();
                ResultSet categoryRs = categoryStmt.executeQuery(fetchCategoriesSql);
                while (categoryRs.next()) {
                    categories.add(categoryRs.getInt("categoryId") + "-" + categoryRs.getString("categoryName"));
                }
                categoryRs.close();
                categoryStmt.close();
                closeConnection();
            } catch (SQLException e) {
                message += " SQL Error: " + e.getMessage();
            }
        %>

        <% if (!"".equals(message)) { %>
            <p><%= message %></p>
        <% } %>


        <h2>Add Product</h2>
        <form action="addProduct.jsp" method="post">
            <div class="form-group">
                <label>Product Name:</label>
                <input type="text" name="productName" required>
            </div>
            <div class="form-group">
                <label>Product Price:</label>
                <input type="text" name="productPrice" required>
            </div>
            <div class="form-group">
                <label>Product Description:</label>
                <input type="text" name="productDesc" required>
            </div>
            <div class="form-group">
                <label>Category:</label>
                <select name="categoryId">
					<% for (String category : categories) {
						String[] parts = category.split("-");
						String categoryName = parts[1];
						if (parts.length > 2) {
							// Manually concatenate the parts if there are more than two elements
							for (int i = 2; i < parts.length; i++) {
								categoryName += "-" + parts[i];
							}
						}
					%>
						<option value="<%= parts[0] %>"><%= categoryName %></option>
					<% } %>
					
                </select>
            </div>
			<div class="form-group">
                <label>Quantity:</label>
                <input type="number" name="productQuantity" min="1" required>
            </div>
			<div class="form-group">
                <label>Warehouse:</label>
                <select name="warehouseId">
                    <% for (String warehouse : warehouses) {
                        String[] parts = warehouse.split("-");
                        String warehouseName = parts[1];
                    %>
                        <option value="<%= parts[0] %>"><%= warehouseName %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <input type="submit" value="Add Product" class="button">
            </div>
        </form>
    </div>
</body>
</html>