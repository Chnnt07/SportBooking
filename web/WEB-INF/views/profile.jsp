<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ của tôi - SportBooking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
            background: #f5f5f5;
            color: #333;
        }
        .profile {
            max-width: 500px;
            padding: 25px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px #ddd;
        }
        p { margin: 15px 0; }
        a {
            display: inline-block;
            margin-right: 10px;
            padding: 9px 14px;
            background: #1976d2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
    </style>
</head>
<body>

<div class="profile">
    <h1>Hồ sơ của tôi</h1>

    <p><strong>Mã người dùng:</strong>
        <c:out value="${sessionScope.userID}"/>
    </p>

    <p><strong>Họ và tên:</strong>
        <c:out value="${sessionScope.fullName}"/>
    </p>

    <p><strong>Tên đăng nhập:</strong>
        <c:out value="${sessionScope.username}"/>
    </p>

    <p><strong>Vai trò:</strong>
        <c:out value="${sessionScope.role}"/>
    </p>

    <a href="${pageContext.request.contextPath}/CourtController">
        Danh sách sân
    </a>

    <a href="${pageContext.request.contextPath}/MyBookingController">
        Lịch đặt của tôi
    </a>
</div>

</body>
</html>