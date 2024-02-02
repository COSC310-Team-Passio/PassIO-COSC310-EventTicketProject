<%@ page import="java.sql.*, java.math.BigDecimal, java.util.List, java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
    <title>Products</title>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <%@ include file="auth.jsp"%>
        <%@ page import="java.sql.*" %>
        <%@ include file="jdbc.jsp" %>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h2>Product List</h2>
            <form action="addProduct.jsp" method="get">
                <input type="submit" value="Add Product" class="button">
            </form>
        </div>
        <table>
            <tr>
                <th>Product Name</th>
                <th>Price</th>
                <th>Description</th>
                <th>Warehouse</th>
                <th>Edit</th>
            </tr>
            <%
                try {
                    getConnection();
                    String query = "SELECT p.productId, p.productName, p.productPrice, p.productDesc, w.warehouseName FROM product p LEFT JOIN productinventory pi ON p.productId = pi.productId LEFT JOIN warehouse w ON pi.warehouseId = w.warehouseId";
                    PreparedStatement pstmt = con.prepareStatement(query);
                    ResultSet rs = pstmt.executeQuery();
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("productName") + "</td>");
                        out.println("<td>" + rs.getString("productPrice") + "</td>");
                        out.println("<td>" + rs.getString("productDesc") + "</td>");
                        out.println("<td>" + rs.getString("warehouseName") + "</td>");
                        out.println("<td>");
                            // Edit button
                            out.println("<form action='editProduct.jsp' method='get'>");
                            out.println("<input type='hidden' name='productId' value='" + rs.getString("productId") + "'/>");
                            out.println("<input type='submit' value='Edit' class='button'/>");
                            out.println("</form>");
                            // Delete button
                            out.println("<form action='deleteProduct.jsp' method='post'>");
                            out.println("<input type='hidden' name='productId' value='" + rs.getString("productId") + "'/>");
                            out.println("<input type='submit' value='Delete' class='button'/>");
                            out.println("</form>");
                        out.println("</tr>");
                    }
                    rs.close();
                    pstmt.close();
                    closeConnection();
                } catch(SQLException e) {
                    out.println("SQL Error: " + e.getMessage());
                }
            %>
        </table>
    </div>
</body>
</html>
