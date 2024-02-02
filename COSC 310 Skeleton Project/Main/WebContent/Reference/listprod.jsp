<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
    <link rel="stylesheet" type="text/css" href="style.css">
    <%@ include file="header3.jsp" %>

<h2>Browse Products By Category and Search by Product Name:</h2>

    <form method="get" action="listprod.jsp" class="form-inline my-2 my-lg-0">
        <select size="1" name="categoryName" class="form-control mr-sm-2">
            <option>All</option>
            <option>Plasma Beam Cannons</option>
            <option>Quantum Torpedo Launchers</option>
            <option>Electromagnetic Railguns</option>  
			<option>Graviton Pulse Emitters</option> 
			<option>Photon Disruptors</option> 
			<option>Nano-Drone Swarms</option>    
        </select>
        <input type="text" name="productName" size="50" class="form-control mr-sm-2">
        <button type="submit" class="btn btn-outline-success my-2 my-sm-0">Submit</button>
        <button type="reset" class="btn btn-outline-secondary my-2 my-sm-0 ml-2">Reset</button>
    </form>
<%
/*
// Could create category list dynamically - more adaptable, but a little more costly
try               
{
	getConnection();
 	ResultSet rst = executeQuery("SELECT DISTINCT categoryName FROM Product");
        while (rst.next()) 
		out.println("<option>"+rst.getString(1)+"</option>");
}
catch (SQLException ex)
{       out.println(ex);
}
*/
%>

<%
// Get product name to search for
String name = request.getParameter("productName");
String category = request.getParameter("categoryName");

boolean hasNameParam = name != null && !name.equals("");
boolean hasCategoryParam = category != null && !category.equals("") && !category.equals("All");
String filter = "", sql = "";

if (hasNameParam && hasCategoryParam)
{
	filter = "<h3>Products containing '"+name+"' in category: '"+category+"'</h3>";
	name = '%'+name+'%';
	sql = "SELECT productId, productName, productPrice, categoryName FROM Product P JOIN Category C ON P.categoryId = C.categoryId WHERE productName LIKE ? AND categoryName = ?";
}
else if (hasNameParam)
{
	filter = "<h3>Products containing '"+name+"'</h3>";
	name = '%'+name+'%';
	sql = "SELECT productId, productName, productPrice, categoryName FROM Product P JOIN Category C ON P.categoryId = C.categoryId WHERE productName LIKE ?";
}
else if (hasCategoryParam)
{
	filter = "<h3>Products in category: '"+category+"'</h3>";
	sql = "SELECT productId, productName, productPrice, categoryName FROM Product P JOIN Category C ON P.categoryId = C.categoryId WHERE categoryName = ?";
}
else
{
	filter = "<h3>All Products</h3>";
	sql = "SELECT productId, productName, productPrice, categoryName FROM Product P JOIN Category C ON P.categoryId = C.categoryId";
}

out.println(filter);

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try 
{
	getConnection();
	Statement stmt = con.createStatement(); 			
	stmt.execute("USE orders");
	
	PreparedStatement pstmt = con.prepareStatement(sql);
	if (hasNameParam)
	{
		pstmt.setString(1, name);	
		if (hasCategoryParam)
		{
			pstmt.setString(2, category);
		}
	}
	else if (hasCategoryParam)
	{
		pstmt.setString(1, category);
	}
	
	ResultSet rst = pstmt.executeQuery();

	out.print("<table class=\"table\" border=\"1\"><tr><th class=\"col-md-1\"></th><th>Product Name</th>");
		out.println("<th>Category</th><th>Price</th></tr>");
		while (rst.next()) 
		{
			int id = rst.getInt(1);
			out.print("<td class=\"col-md-1\"><a href=\"addcart.jsp?id=" + id + "&name=" + rst.getString(2)
					+ "&price=" + rst.getDouble(3) + "\">Add to Cart</a></td>");
		
			out.println("<td><a href=\"product.jsp?id=" + id + "\">" + rst.getString(2) + "</a></td>"
					+ "<td>" + rst.getString("categoryName") + "</td>"
					+ "<td>" + currFormat.format(rst.getDouble(3)) + "</td></tr>");
		}
		out.println("</table>");
	closeConnection();
	} catch (SQLException ex) {
	out.println(ex);
	}
%>

</body>
</html>
