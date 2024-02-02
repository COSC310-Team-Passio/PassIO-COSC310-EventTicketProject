<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Add New Customer</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container">
        <h2>Add New Customer</h2>
        <form action="processAddCustomer.jsp" method="post" class="form-style">
            <div class="form-group">
                <label for="firstName">First Name:</label>
                <input type="text" id="firstName" name="firstName" required>
            </div>
            <div class="form-group">
                <label for="lastName">Last Name:</label>
                <input type="text" id="lastName" name="lastName" required>
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="phonenum">Phone Number:</label>
                <input type="text" id="phonenum" name="phonenum">
            </div>
            <div class="form-group">
                <label for="address">Address:</label>
                <input type="text" id="address" name="address">
            </div>
            <div class="form-group">
                <label for="city">City:</label>
                <input type="text" id="city" name="city">
            </div>
            <div class="form-group">
                <label for="state">State:</label>
                <input type="text" id="state" name="state">
            </div>
            <div class="form-group">
                <label for="postalCode">Postal Code:</label>
                <input type="text" id="postalCode" name="postalCode">
            </div>
            <div class="form-group">
                <label for="country">Country:</label>
                <input type="text" id="country" name="country">
            </div>
            <div class="form-group">
                <label for="userid">Username:</label>
                <input type="text" id="userid" name="userid" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <input type="submit" value="Add Customer" class="button">
            </div>
        </form>        
    </div>
</body>
</html>
