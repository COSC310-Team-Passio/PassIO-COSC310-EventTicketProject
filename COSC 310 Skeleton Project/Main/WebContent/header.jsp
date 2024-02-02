<header>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
    <div>
        <div>
            <div id="logo">
                <img src="img/logo.jpeg" alt="logo" class="logo">
            </div>
            <div id="branding">
                <h1>Passio</h1>
            </div>
        </div>
        <%
        String userName = (String) session.getAttribute("authenticatedUser");
        if (userName != null) {
            out.println("<div class='user-info' style='font-size: 12px; color: white; text-align: right;'>Signed in as: " + userName + "</div>");
        }
        %>
    </div>
    <nav style="margin-top: 10px;">
        <ul style="padding: 0; list-style: none; display: flex; justify-content: center;">
            <li style="margin: 0 10px;"><a href="home.jsp">Home</a></li>
            <li style="margin: 0 10px;"><a href="events.jsp">Events</a></li>
            <li style="margin: 0 10px;"><a href="checkout.jsp">Checkout</a></li>
            <li style="margin: 0 10px;"><a href="profile.jsp">Profile</a></li>
            <li style="margin: 0 10px;"><a href="admin.jsp">Admin</a></li>
            <% 
            if (userName == null) {
                out.println("<li style='margin: 0 10px;'><a href='login.jsp'>Log In</a></li>");
            } else {
                out.println("<li style='margin: 0 10px;'><a href='logout.jsp'>Log Out</a></li>");
            }
            %>
        </ul>
    </nav>
</header>
