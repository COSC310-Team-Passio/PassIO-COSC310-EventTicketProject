<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Ray's Grocery Shipment Processing</title>
</head>
<body>
        
<%@ include file="header.jsp" %>

<%
// Get order id
String ordId = request.getParameter("orderId");
          
try 
{	
	if (ordId == null || ordId.equals(""))
		out.println("<h1>Invalid order id.</h1>");	
	else
	{					
		// Get database connection
        getConnection();
	            
     	// Check if valid order id
        String sql = "SELECT orderId, productId, quantity, price FROM orderproduct WHERE orderId = ?";	
				      
   		con = DriverManager.getConnection(url, uid, pw);
   		PreparedStatement pstmt = con.prepareStatement(sql);
   		pstmt.setInt(1, Integer.parseInt(ordId));
   		ResultSet rst = pstmt.executeQuery();
   		int orderId=0;
   		String custName = "";

   		if (!rst.next())
   		{
   			out.println("<h1>Invalid order id or no items in order.</h1>");
   		}
   		else
   		{	
   			try
   			{
   				// Turn off auto-commit
   				con.setAutoCommit(false);

	   			// Enter shipment information into database
   	   			sql = "INSERT INTO shipment (shipmentDate, warehouseId) VALUES (?, 1);";   	   	
   	   			pstmt = con.prepareStatement(sql);   	   			
   	   			pstmt.setTimestamp(1, new java.sql.Timestamp(new Date().getTime()));
   	   			pstmt.executeUpdate();
   	   			
   				// Verify that each item has sufficient inventory to be shipped
   				// Update inventory
   				String sqlq = "SELECT quantity FROM productinventory WHERE warehouseId = 1 and productId = ?";
   				PreparedStatement pstmtq = con.prepareStatement(sqlq);  
   				boolean success = true;
   				
   				sql = "UPDATE productinventory SET quantity = ? WHERE warehouseId = 1 and productId = ?";
   				pstmt = con.prepareStatement(sql);   
   				
	   			do
	   			{
	   				int prodId = rst.getInt(2);
	   				int qty = rst.getInt(3);
	   				pstmtq.setInt(1, prodId);
	   				ResultSet resq = pstmtq.executeQuery();
	   				if (!resq.next() || resq.getInt(1) < qty)
	   				{
	   					// No inventory record.
	   					out.println("<h1>Shipment not done. Insufficient inventory for product id: "+prodId+"</h1>");
	   					success = false;	   					
	   					break;
	   				}
	   				
	   				// Update inventory record
	   				int inventory = resq.getInt(1);
	   				pstmt.setInt(1, inventory - qty);
	   				pstmt.setInt(2, prodId);
	   				pstmt.executeUpdate();
	   				
	   				out.println("<h2>Ordered product: "+prodId+" Qty: "+qty+" Previous inventory: "+inventory+" New inventory: "+(inventory-qty)+"</h2><br>");
	   			} while (rst.next());
   				
	   			
   				// Commit or rollback
   				if (!success)
   					con.rollback();
   				else
   				{
   					out.println("<h1>Shipment successfully processed.</h1>");
   					con.commit();   				
   				}
   			}
   			catch (SQLException e)
   			{	con.rollback();  
   				out.println(e);
   			}
   			finally
   			{
	   			// Turn on auto-commit
	   			con.setAutoCommit(true);
   			}
		}
   	}
}
catch (SQLException ex)
{ 	out.println(ex);
}
finally
{
	try
	{
		if (con != null)
			con.close();
	}
	catch (SQLException ex)
	{       out.println(ex);
	}
}  
%>                       				

<h2><a href="shop.html">Back to Main Page</a></h2>

</body>
</html>
