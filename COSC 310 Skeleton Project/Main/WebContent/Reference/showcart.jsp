<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Your Shopping Cart</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .flex-container {
            display: flex;
            align-items: center;
        }
        .flex-item {
            margin: 0 5px; /* Adjust margin as needed */
        }
    </style>
</head>
<body>
    <%-- Include your header --%>
    <%@ include file="header3.jsp" %>

    <%
    @SuppressWarnings("unchecked")
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    NumberFormat currFormat = NumberFormat.getCurrencyInstance(Locale.US);

    if (productList != null && !productList.isEmpty()) {
        out.println("<h1>Your Shopping Cart</h1>");
        out.print("<table><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th><th>Price</th><th>Subtotal</th><th>Delete</th></tr>");

        double total = 0;
        for (Map.Entry<String, ArrayList<Object>> entry : productList.entrySet()) {
            ArrayList<Object> product = entry.getValue();
            String productId = product.get(0).toString();
            String productName = product.get(1).toString();
            double price = Double.parseDouble(product.get(2).toString());
            int quantity = Integer.parseInt(product.get(3).toString());

            out.print("<tr><td>"+productId+"</td>");
            out.print("<td>"+productName+"</td>");
            out.print("<td>");
            out.print("<div class='flex-container'>");
            // Decrement button
            out.print("<form action='updateItem.jsp' method='post' class='flex-item'>");
            out.print("<input type='hidden' name='action_" + productId + "' value='decrement'>");
            out.print("<input type='submit' value='-' class='flex-item'>");
            out.print("</form>");
            // Display quantity
            out.print("<span class='flex-item'>" + quantity + "</span>");
            // Increment button
            out.print("<form action='updateItem.jsp' method='post' class='flex-item'>");
            out.print("<input type='hidden' name='action_" + productId + "' value='increment'>");
            out.print("<input type='submit' value='+' class='flex-item'>");
            out.print("</form>");
            out.print("</div>");
            out.print("</td>");
            out.print("<td>"+currFormat.format(price)+"</td>");
            out.print("<td>"+currFormat.format(price * quantity)+"</td>");
            out.print("<td>");
            // Delete button
            out.print("<form action='deleteItem.jsp' method='post' class='flex-item'>");
            out.print("<input type='hidden' name='productId' value='" + productId + "'>");
            out.print("<input type='hidden' name='action' value='delete'>");
            out.print("<input type='submit' value='Delete'>");
            out.print("</form>");
            out.print("</td>");
            out.print("</tr>");

            total += price * quantity;
        }

        out.println("<tr><td colspan='5' align='right'><b>Order Total</b></td><td align='right'>" + currFormat.format(total) + "</td></tr>");
        out.println("</table>");
    } else {
        out.println("<h1>Your shopping cart is empty!</h1>");
    }
    %>
    <h2><a href="listprod.jsp">Continue Shopping</a></h2>
    <h2><a href="checkout.jsp">Checkout</a></h2>
</body>
</html>
