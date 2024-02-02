<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<%
    // Retrieve form data
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    String userid = request.getParameter("userid");
    String password = request.getParameter("password");

    try {
        getConnection();
        // SQL query to insert customer data into the database
        String sql = "INSERT INTO Customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = con.prepareStatement(sql);

        pstmt.setString(1, firstName);
        pstmt.setString(2, lastName);
        pstmt.setString(3, email);
        pstmt.setString(4, phonenum);
        pstmt.setString(5, address);
        pstmt.setString(6, city);
        pstmt.setString(7, state);
        pstmt.setString(8, postalCode);
        pstmt.setString(9, country);
        pstmt.setString(10, userid);
        pstmt.setString(11, password);

        // Execute the update
        pstmt.executeUpdate();
        pstmt.close();

        // Redirect to a confirmation page or back to the customer list
        response.sendRedirect("customers.jsp");

    } catch (SQLException e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
        // Optionally, redirect to an error page or back to the form with an error message
    } finally {
        closeConnection();
    }
%>
