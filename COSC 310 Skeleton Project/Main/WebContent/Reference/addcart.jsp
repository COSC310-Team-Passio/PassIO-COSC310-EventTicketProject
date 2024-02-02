<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
    // Get the current list of products
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList == null) {
        // No products currently in list. Create a new list.
        productList = new HashMap<String, ArrayList<Object>>();
    }

    // Add new product selected
    // Get product information
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String price = request.getParameter("price");

    // If the product is not already in the cart, add it with a quantity of 1
    if (!productList.containsKey(id)) {
        // Store product information in an ArrayList
        ArrayList<Object> product = new ArrayList<Object>();
        product.add(id);
        product.add(name);
        product.add(price);
        product.add(new Integer(1)); // Initial quantity is set to 1

        productList.put(id, product);
    }

    // Update the productList in the session
    session.setAttribute("productList", productList);

    // Forward to the show cart page
    %>
    <jsp:forward page="showcart.jsp" />
