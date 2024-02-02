<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    String customerId = request.getParameter("customerId");

    if(customerId != null && !customerId.isEmpty()) {
        try {
            getConnection();
            String sql = "DELETE FROM Customer WHERE customerId = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(customerId));
            int rowsAffected = pstmt.executeUpdate();

            if(rowsAffected > 0) {
                // If the deletion was successful, redirect to a confirmation or customer list page
                response.sendRedirect("customers.jsp?status=deleteSuccess");
            } else {
                // If no rows were affected, redirect to an error page or back to the customer list with an error message
                response.sendRedirect("customers.jsp?status=deleteError");
            }

            pstmt.close();
        } catch(SQLException e) {
            // Handle SQL exceptions
            out.println("<p>Error: " + e.getMessage() + "</p>");
        } catch(NumberFormatException e) {
            // Handle potential format exceptions (e.g., parsing customerId to integer)
            out.println("<p>Error: Invalid customer ID format.</p>");
        } finally {
            closeConnection();
        }
    } else {
        // Redirect if customerId is null or empty
        response.sendRedirect("customers.jsp?status=invalidId");
    }
%>
