<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Product Table Data</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

<%
    getConnection();
    Statement stmt = null;
    ResultSet rs = null;
    try {
        stmt = con.createStatement();
        String sql = "SELECT * FROM product";
        rs = stmt.executeQuery(sql);

        out.println("<h2>Product Table Data:</h2>");
        out.println("<table border='1'><tr><th>Product ID</th><th>Product Name</th><th>Product Price</th><th>Product Image URL</th><th>Product Description</th><th>Category ID</th></tr>");

        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("productId") + "</td>");
            out.println("<td>" + rs.getString("productName") + "</td>");
            out.println("<td>" + rs.getBigDecimal("productPrice") + "</td>");
            out.println("<td>" + rs.getString("productImageURL") + "</td>");
            out.println("<td>" + rs.getString("productDesc") + "</td>");
            out.println("<td>" + rs.getInt("categoryId") + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    } catch (SQLException e) {
        out.println("SQL Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        closeConnection(); // Assuming this closes the 'con' variable
    }
%>

</body>
</html>
