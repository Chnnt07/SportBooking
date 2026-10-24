<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login - SportBooking</title>
    </head>
    <body>
        <h1>SportBooking Login</h1>
            <p style="color: red">${error}</p>
            <p style="color: green">${message}</p>

            <form action="${pageContext.request.contextPath}/login" method="post">

                <input type="hidden" name="action" value="login">

                <label>Username:</label>
                <input type="text" name="username"
                       maxlength="50" required>
                <br><br>

                <label>Password:</label>
                <input type="password" name="password" required>
                <br><br>

                <button type="submit">Login</button>
            </form>

            <p>
                Don't have an account?
                <a href="${pageContext.request.contextPath}/register">
                    Register here
                </a>
            </p>
    </body>
</html>
