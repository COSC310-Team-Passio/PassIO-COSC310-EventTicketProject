<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quantum Cannoncraft - Futuristic Weapons</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>
    <div>
        <form action="loaddata.jsp" method="post">
			<input type="submit" value="Reload Data" class="button">
		</form>
    </div>


    <div class="main-content">
        <section class="hero-section">
            <div class="hero-text">
                <h1>Welcome to Quantum Cannoncraft</h1>
                <p>Explore the future of weaponry</p>
                <img src="img/logo.jpeg" alt="Futuristic Weapon" class="product-image">
            </div>
        </section>

        <section class="featured-products">
            <h2>Featured Products</h2>
            <div class="product-grid">
                <%
                    try {
                        getConnection();
                        String sql = "SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY productId) AS RowNum, productName, productDesc, productImageURL FROM Product) AS RowConstrainedResult WHERE RowNum >= 1 AND RowNum <= 3";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        ResultSet rs = pstmt.executeQuery();
        
                        while (rs.next()) {
                            String productName = rs.getString("productName");
                            String productDesc = rs.getString("productDesc");
                            String productImageURL = rs.getString("productImageURL");
                %>
                            <div class="product-item">
                                <h3><%= productName %></h3>
                                <p><%= productDesc %></p>
                                <img src="<%= productImageURL %>" alt="<%= productName %>" class="product-image">
                            </div>
                <%
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
        </section>
              

        <section class="about-us">
            <h2>About Us</h2>
            <p>Learn more about our journey in the world of futuristic weaponry.</p>
            <a href="aboutus.jsp" class="button">Read More</a>
        </section>

        <section class="latest-news">
            <h2>Latest News</h2>
            <p>Stay updated with our latest developments and innovations.</p>
            <a href="news.jsp" class="button">Discover</a>
        </section>
    </div>
</body>
</html>
