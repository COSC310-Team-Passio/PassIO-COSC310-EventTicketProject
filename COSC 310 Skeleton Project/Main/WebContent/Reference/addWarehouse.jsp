<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    String warehouseName = request.getParameter("warehouseName");

    if(warehouseName != null && !warehouseName.isEmpty()) {
        try {
            getConnection();

            String sql = "INSERT INTO warehouse (warehouseName) VALUES (?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, warehouseName);
            pstmt.executeUpdate();
            pstmt.close();

            response.sendRedirect("warehouse.jsp"); // Redirect back to the warehouse page
        } catch (SQLException e) {
            out.println("SQL Error: " + e.getMessage());
            // Handle the error appropriately
        } finally {
            closeConnection();
        }
    } else {
        out.println("Invalid warehouse name.");
        // Redirect or handle the error
    }
%>
