<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>

<%
@SuppressWarnings("unchecked")
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
HttpServletResponse httpResponse = response;

if (productList != null) {
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();

    while (iterator.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
        ArrayList<Object> product = entry.getValue();
        String productId = product.get(0).toString();

        String action = request.getParameter("action_" + productId);

        try {
            if ("increment".equals(action)) {
                // Increment the quantity
                int currentQuantity = (Integer) product.get(3);
                product.set(3, currentQuantity + 1);
            } else if ("decrement".equals(action)) {
                // Decrement the quantity
                int currentQuantity = (Integer) product.get(3);
                if (currentQuantity > 1) {
                    product.set(3, currentQuantity - 1);
                }
            } else if ("delete".equals(action)) {
                // Delete the item
                iterator.remove();
            }
        } catch (Exception e) {
            // Handle any parsing errors or other exceptions
            out.println("Error processing request: " + e.getMessage());
            return;
        }
    }
    session.setAttribute("productList", productList);
    httpResponse.sendRedirect("showcart.jsp");
} else {
    out.println("Product list is null.");
    httpResponse.sendRedirect("showcart.jsp");
}
%>
