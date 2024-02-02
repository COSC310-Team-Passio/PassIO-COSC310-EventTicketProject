<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Customer Profile</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header4.jsp" %>

    <h2>Edit Your Profile</h2>

    <%
        String customerId = request.getParameter("customerId");
        if(customerId == null || customerId.isEmpty()) {
            // Redirect back or show an error
            out.println("<p>Invalid customer ID.</p>");
        } else {
            try {
                getConnection();
                String sql = "SELECT * FROM Customer WHERE customerId = ?";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(customerId));
                ResultSet rs = pstmt.executeQuery();

                if(rs.next()) {
                    // Display form with existing data
    %>
    <form action="updateCustomer.jsp" method="post" class="form-style">
        <input type="hidden" name="customerId" value="<%= customerId %>">

        <div class="form-group">
            <label>First Name:</label>
            <input type="text" name="firstName" value="<%= rs.getString("firstName") %>" required>
        </div>

        <div class="form-group">
            <label>Last Name:</label>
            <input type="text" name="lastName" value="<%= rs.getString("lastName") %>" required>
        </div>

        <div class="form-group">
            <label>Email:</label>
            <input type="email" name="email" value="<%= rs.getString("email") %>" required>
        </div>

        <div class="form-group">
            <label>Phone Number:</label>
            <input type="text" name="phonenum" value="<%= rs.getString("phonenum") %>">
        </div>

        <div class="form-group">
            <label>Address:</label>
            <input type="text" name="address" value="<%= rs.getString("address") %>">
        </div>

        <div class="form-group">
            <label>City:</label>
            <input type="text" name="city" value="<%= rs.getString("city") %>">
        </div>

        <div class="form-group">
            <label>State:</label>
            <input type="text" name="state" value="<%= rs.getString("state") %>">
        </div>

        <div class="form-group">
            <label>Postal Code:</label>
            <input type="text" name="postalCode" value="<%= rs.getString("postalCode") %>">
        </div>

        <div class="form-group">
            <label>Country:</label>
            <input type="text" name="country" value="<%= rs.getString("country") %>">
        </div>

        <div class="form-group">
            <label>Username:</label>
            <input type="text" name="userid" value="<%= rs.getString("userid") %>" required>
        </div>

        <div class="form-group">
            <label>Password:</label>
            <input type="password" name="password" value="<%= rs.getString("password") %>" required>
        </div>

        <div class="form-group">
            <input type="submit" value="Update Profile" class="button">
        </div>
    </form>
    <%
                }
                rs.close();
                pstmt.close();
            } catch(Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                closeConnection();
            }
        }
    %>
</body>
</html>
