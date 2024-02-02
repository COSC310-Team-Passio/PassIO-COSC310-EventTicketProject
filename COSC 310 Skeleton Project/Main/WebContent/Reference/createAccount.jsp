<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Create Account</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header4.jsp" %>

    <div class="container">
        <h2>Create Your Account</h2>

        <% 
            String message = "";
            if ("POST".equalsIgnoreCase(request.getMethod())) {
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
                    String sql = "INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
                    pstmt.executeUpdate();

                    // Set user as logged in
                    session.setAttribute("authenticatedUser", userid);

                    pstmt.close();
                    closeConnection();
                    
                    // Redirect to index.jsp
                    response.sendRedirect("index.jsp");
                } catch (SQLException e) {
                    message = "SQL Error: " + e.getMessage();
                }
            }
        %>

        <% if (!"".equals(message)) { %>
            <p><%= message %></p>
        <% } %>

        <form action="createAccount.jsp" method="post" class="form-style">
            <div class="form-group">
                <label for="firstName">First Name:</label>
                <input type="text" id="firstName" name="firstName" placeholder="First Name" required>
            </div>
            <div class="form-group">
                <label for="lastName">Last Name:</label>
                <input type="text" id="lastName" name="lastName" placeholder="Last Name" required>
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" placeholder="Email" required>
            </div>
            <div class="form-group">
                <label for="phonenum">Phone Number:</label>
                <input type="text" id="phonenum" name="phonenum" placeholder="Phone Number">
            </div>
            <div class="form-group">
                <label for="address">Address:</label>
                <input type="text" id="address" name="address" placeholder="Address">
            </div>
            <div class="form-group">
                <label for="city">City:</label>
                <input type="text" id="city" name="city" placeholder="City">
            </div>
            <div class="form-group">
                <label for="state">State:</label>
                <input type="text" id="state" name="state" placeholder="State">
            </div>
            <div class="form-group">
                <label for="postalCode">Postal Code:</label>
                <input type="text" id="postalCode" name="postalCode" placeholder="Postal Code">
            </div>
            <div class="form-group">
                <label for="country">Country:</label>
                <input type="text" id="country" name="country" placeholder="Country">
            </div>
            <div class="form-group">
                <label for="userid">Username:</label>
                <input type="text" id="userid" name="userid" placeholder="Username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" placeholder="Password" required>
            </div>
            <div class="form-group">
                <input type="submit" value="Create Account" class="button">
            </div>
        </form>       
    </div>
</body>
</html>
