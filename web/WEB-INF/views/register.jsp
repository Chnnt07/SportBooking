<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Register - SportBooking</title>
    </head>
    <body>
        <h1>Create an Account</h1>
         <p style="color: red">${error}</p>

         <form action="${pageContext.request.contextPath}/register" method="post">
             
        <input type="hidden" name="action" value="register">

        <label>Full Name:</label>
        <input type="text" name="fullName"
               maxlength="100" required>
        <br><br>

        <label>Username:</label>
        <input type="text" name="username"
               maxlength="50" required>
        <br><br>

        <label>Password:</label>
        <input type="password" name="password"
               minlength="8" required>
        <br><br>

        <label>Confirm Password:</label>
        <input type="password" name="confirmPassword"
               minlength="8" required>
        <br><br>

        <button type="submit">Register</button>
    </form>

    <p>
        Already have an account?
         <a href="${pageContext.request.contextPath}/login">
            Login here
        </a>
    </p>
    </body>
</html>
