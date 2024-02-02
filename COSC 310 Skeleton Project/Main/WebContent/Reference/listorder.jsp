<%@ page import="java.sql.*,java.util.Locale" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Ray's Grocery Order List</title>
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
	<%@ include file="header2.jsp" %>
<h1>Order List</h1>

<%
String sql = "SELECT orderId, O.CustomerId, totalAmount, firstName+' '+lastName, orderDate FROM OrderSummary O, Customer C WHERE "
		+ "O.customerId = C.customerId";

NumberFormat currFormat = NumberFormat.getCurrencyInstance(Locale.US);

try  
{	
	getConnection();
    Statement stmt = con.createStatement(); 			
	stmt.execute("USE orders");
	
	ResultSet rst = stmt.executeQuery(sql);		
	out.print("<table border=\"1\"><tr><th>Order Id</th><th>Order Date</th><th>Customer Id</th><th>Customer Name</th><th>Total Amount</th></tr>");
	
	// Use a PreparedStatement as will execute many times
	sql = "SELECT productId, quantity, price FROM OrderProduct WHERE orderId=?";
	PreparedStatement pstmt = con.prepareStatement(sql);
	
	while (rst.next())
	{	int orderId = rst.getInt(1);
		out.print("<tr><td>"+orderId+"</td>");
		out.print("<td>"+rst.getString(5)+"</td>");
		out.print("<td>"+rst.getInt(2)+"</td>");		
		out.print("<td>"+rst.getString(4)+"</td>");
		out.print("<td>"+currFormat.format(rst.getDouble(3))+"</td>");
		out.println("</tr>");

		// Retrieve all the items for an order
		pstmt.setInt(1, orderId);				
		ResultSet rst2 = pstmt.executeQuery();
		
		out.println("<tr align=\"right\"><td colspan=\"4\"><table border=\"1\">");
		out.println("<th>Product Id</th> <th>Quantity</th> <th>Price</th></tr>");
		while (rst2.next())
		{
			out.print("<tr><td>"+rst2.getInt(1)+"</td>");
			out.print("<td>"+rst2.getInt(2)+"</td>");
			out.println("<td>"+currFormat.format(rst2.getDouble(3))+"</td></tr>");
		}
		out.println("</table></td></tr>");
	}
	out.println("</table>");
}
catch (SQLException ex) 
{ 	out.println(ex); 
}
finally
{
	closeConnection();
}
%>
</body>
</html>