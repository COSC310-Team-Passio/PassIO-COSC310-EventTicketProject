<header>
    <div class="container" style="text-align: center;">
        <div class="header-top" style="display: flex; justify-content: center; align-items: center;">
            <div id="logo" style="flex: 1;">
                <img src="img/logo.jpg" alt="Quantum Cannoncraft Logo" style="max-height: 80px;">
            </div>
            <div id="branding">
                <h1>Quantum Cannoncraft</h1>
            </div>
            <div style="flex: 1;"></div> <!-- Additional div for spacing -->
        </div>
        <!-- User Info Positioned Outside of header-top -->
        <%
        String userName = (String) session.getAttribute("authenticatedUser");
        if (userName != null) {
            out.println("<div class='user-info' style='font-size: 12px; color: white; text-align: right;'>Signed in as: " + userName + "</div>");
        }
        %>
        </div>
        <nav style="margin-top: 10px;">
            <ul style="padding: 0; list-style: none; display: flex; justify-content: center;">
                <li style="margin: 0 10px;"><a href="index.jsp">Home</a></li>
                <li style="margin: 0 10px;"><a href="admin.jsp">Sales</a></li>
                <li style="margin: 0 10px;"><a href="customers.jsp">Customers</a></li>
                <li style="margin: 0 10px;"><a href="updatedeleteprod.jsp">Products</a></li>
                <li style="margin: 0 10px;"><a href="warehouse.jsp">Warehouse</a></li>
            </ul>
        </nav>
    </div>
</header>
