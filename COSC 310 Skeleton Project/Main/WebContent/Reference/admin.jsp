<!DOCTYPE html>
<html>
<head>
    <title>Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
	<%@ include file="header.jsp" %>

    <div class="container">
		<%@ include file="auth.jsp"%>
		<%@ page import="java.text.NumberFormat" %>
		<%@ include file="jdbc.jsp" %>
		<form action="loaddata.jsp" method="post">
			<input type="submit" value="Reload Data" class="button">
		</form>
		<%
		
		// Print out total order amount by day
		String sql = "select year(orderDate), month(orderDate), day(orderDate), SUM(totalAmount) FROM OrderSummary GROUP BY year(orderDate), month(orderDate), day(orderDate)";
		
		NumberFormat currFormat = NumberFormat.getCurrencyInstance();
		
		try 
		{	
			out.println("<h3>Administrator Sales Report by Day</h3>");
			
			getConnection();
			Statement stmt = con.createStatement(); 
			stmt.execute("USE orders");
		
			ResultSet rst = con.createStatement().executeQuery(sql);		
			out.println("<table class=\"table\" border=\"1\">");
			out.println("<tr><th>Order Date</th><th>Total Order Amount</th>");	
		
			while (rst.next())
			{
				out.println("<tr><td>"+rst.getString(1)+"-"+rst.getString(2)+"-"+rst.getString(3)+"</td><td>"+currFormat.format(rst.getDouble(4))+"</td></tr>");
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
    </div>
</body>
</html>
