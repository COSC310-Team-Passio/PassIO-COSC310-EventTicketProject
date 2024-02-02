<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Update Customer Profile</title>
    <link rel="stylesheet" type="text/css" href="style.css">

</head>
<body>
    <%@ include file="header3.jsp" %>

    <%
        // Retrieve form data
        String customerId = request.getParameter("customerId");
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

        // Validate input data
        if(customerId == null || firstName == null || lastName == null || email == null ||
           userid == null || password == null) {
            out.println("<p>Missing required fields.</p>");
        } else {
            try {
                getConnection();

                // Prepare the SQL statement to update customer information
                String sql = "UPDATE Customer SET firstName = ?, lastName = ?, email = ?, phonenum = ?, address = ?, city = ?, state = ?, postalCode = ?, country = ?, userid = ?, password = ? WHERE customerId = ?";
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
                pstmt.setInt(12, Integer.parseInt(customerId));

                // Execute the update statement
                int rowsAffected = pstmt.executeUpdate();

                if(rowsAffected > 0) {
                    out.println("<p>Profile updated successfully!</p>");
                } else {
                    out.println("<p>Error updating profile. Please try again.</p>");
                }

                pstmt.close();
                closeConnection();
            } catch(NumberFormatException e) {
                out.println("<p>Error: Invalid customer ID format.</p>");
            } catch(SQLException e) {
                out.println("<p>SQL Error: " + e.getMessage() + "</p>");
            } finally {
                closeConnection();
            }
        }
    %>

    <a href="customer.jsp">Back to Profile</a>
</body>
</html>
