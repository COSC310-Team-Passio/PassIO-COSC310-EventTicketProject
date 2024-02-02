<%@ include file="jdbc.jsp" %>
<html>
<head>
    <title>Passio</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="container" style="text-align: center;">
        <section class="main-section">
            <div class="welcome-text">
                <h1>Welcome to Passio</h1>
            </div>
        </section>

        <section class="featured-events">
            <h2>Featured Events</h2>
            <div class="event-grid">
                <h3>Events go here.</h3>
            </div>
        </section>
              
        <section class="about-us">
            <h2>About Us</h2>
            <p>Learn more about Passio.</p>
            <a href="aboutus.jsp" class="button">Read More</a>
        </section>
    </div>
</body>
</html>
