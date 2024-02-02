<!DOCTYPE html>
<html>
<head>
    <title>Customer Page</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <%@ include file="header3.jsp" %>
</head>
<body>
    <%@ include file="auth.jsp"%>
    <%@ page import="java.text.NumberFormat" %>
    <%@ include file="jdbc.jsp" %>

    <div class="container">
        <% 
            String sql = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password FROM Customer WHERE userid = ?";
            NumberFormat currFormat = NumberFormat.getCurrencyInstance();
            getConnection();
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userName);    
            ResultSet rst = pstmt.executeQuery();
            
            if (rst.next()) {
        %>
        <div class="customer-header">
            <h3>Customer Profile</h3>
            <form action='editCustomer.jsp' method='post'>
                <input type='hidden' name='customerId' value='<%= rst.getString(1) %>'/>
                <input type='submit' value='Edit Profile' class='button'>
            </form>
        </div>
        <table class="table" border="1">
            <tr><th>Id</th><td><%= rst.getString(1) %></td></tr>
            <tr><th>First Name</th><td><%= rst.getString(2) %></td></tr>
            <tr><th>Last Name</th><td><%= rst.getString(3) %></td></tr>
            <tr><th>Email</th><td><%= rst.getString(4) %></td></tr>
            <tr><th>Phone</th><td><%= rst.getString(5) %></td></tr>
            <tr><th>Address</th><td><%= rst.getString(6) %></td></tr>
            <tr><th>City</th><td><%= rst.getString(7) %></td></tr>
            <tr><th>State</th><td><%= rst.getString(8) %></td></tr>
            <tr><th>Postal Code</th><td><%= rst.getString(9) %></td></tr>
            <tr><th>Country</th><td><%= rst.getString(10) %></td></tr>
            <tr><th>User id</th><td><%= rst.getString(11) %></td></tr>
        </table>
        <% 
            }
            pstmt.close();
        %>
    </div>
    <% 
        closeConnection(); 
    %>
</body>
</html>
