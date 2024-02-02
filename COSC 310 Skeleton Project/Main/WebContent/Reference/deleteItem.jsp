<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>

<%
    String productId = request.getParameter("productId");

    if(productId != null && !productId.isEmpty()) {
        @SuppressWarnings("unchecked")
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        if (productList != null && productList.containsKey(productId)) {
            productList.remove(productId); // Remove the item from the cart
            session.setAttribute("productList", productList); // Update the cart in the session
            response.sendRedirect("showcart.jsp"); // Redirect back to the cart page
        } else {
            response.sendRedirect("showcart.jsp"); // Redirect if product not found or cart is empty
        }
    } else {
        response.sendRedirect("showcart.jsp"); // Redirect if invalid product ID
    }
%>
