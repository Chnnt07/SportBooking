<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login - SportBooking</title>
    </head>
    <body>
        <h1>SportBooking Login</h1>
        
            <c:if test="${not empty error}">
                <p style="color: red"><c:out value="${error}"/></p>
            </c:if>

    
            <c:if test="${not empty message}">
                <p style="color: green"><c:out value="${message}"/></p>
            </c:if>

            
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
