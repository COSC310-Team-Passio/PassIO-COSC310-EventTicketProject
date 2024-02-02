<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>All Customers</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <div class="customer-header">
            <h2>Customer Information</h2>
            <form action="addCustomer.jsp" method="post" class="add-customer-form">
                <input type="submit" value="Add Customer" class="button">
            </form>
        </div>

        <% 
            try {
                getConnection();
                String sql = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid FROM Customer";
                PreparedStatement pstmt = con.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();

                while (rs.next()) {
                    String customerId = rs.getString("customerId");
                    out.println("<table class='table'>");
                    out.println("<tr><th>Customer ID</th><td>" + rs.getString("customerId") + "</td></tr>");
                    out.println("<tr><th>First Name</th><td>" + rs.getString("firstName") + "</td></tr>");
                    out.println("<tr><th>Last Name</th><td>" + rs.getString("lastName") + "</td></tr>");
                    out.println("<tr><th>Email</th><td>" + rs.getString("email") + "</td></tr>");
                    out.println("<tr><th>Phone Number</th><td>" + rs.getString("phonenum") + "</td></tr>");
                    out.println("<tr><th>Address</th><td>" + rs.getString("address") + "</td></tr>");
                    out.println("<tr><th>City</th><td>" + rs.getString("city") + "</td></tr>");
                    out.println("<tr><th>State</th><td>" + rs.getString("state") + "</td></tr>");
                    out.println("<tr><th>Postal Code</th><td>" + rs.getString("postalCode") + "</td></tr>");
                    out.println("<tr><th>Country</th><td>" + rs.getString("country") + "</td></tr>");
                    out.println("<tr><th>Username</th><td>" + rs.getString("userid") + "</td></tr>");
                    // Edit and Delete buttons
                    out.println("<tr><td colspan='2'>");
                    out.println("<form action='editCustomer.jsp' method='post' style='display: inline;'>");
                    out.println("<input type='hidden' name='customerId' value='" + customerId + "'/>");
                    out.println("<input type='submit' value='Edit' class='button'>");
                    out.println("</form> ");
                    out.println("<form action='deleteCustomer.jsp' method='post' style='display: inline;'>");
                    out.println("<input type='hidden' name='customerId' value='" + customerId + "'/>");
                    out.println("<input type='submit' value='Delete' class='button'>");
                    out.println("</form>");
                    out.println("</td></tr>");
                    out.println("</table><br/>");
                }

                rs.close();
                pstmt.close();
            } catch (SQLException e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                closeConnection();
            }
        %>
    </div>

</body>
</html>
