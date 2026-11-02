<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh sách sân - SportBooking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
            background: #f5f5f5;
            color: #333;
        }
        h1 { color: #333; }
        .nav {
            display: flex;
            gap: 10px;
            margin: 20px 0;
        }
        .nav a, .btn {
            display: inline-block;
            padding: 9px 14px;
            background: #1976d2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .nav a:hover, .btn:hover { background: #125ca1; }
        form { margin: 20px 0; }
        input, select, button {
            padding: 8px;
            margin-right: 5px;
        }
        button {
            cursor: pointer;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th { background: #eee; }
        .active { color: green; font-weight: bold; }
        .inactive { color: red; font-weight: bold; }
        .disabled {
            color: #888;
            font-size: 13px;
        }
    </style>
</head>
<body>

<h1>Danh sách sân thể thao</h1>

<div class="nav">
    <a href="${pageContext.request.contextPath}/MyBookingController">
        Lịch đặt của tôi
    </a>
    <a href="${pageContext.request.contextPath}/ProfileController">
        Hồ sơ của tôi
    </a>
</div>

<form action="${pageContext.request.contextPath}/CourtController"
      method="get">

    <input type="text" name="keyword"
           placeholder="Tìm theo tên sân"
           value="<c:out value='${keyword}'/>">

    <select name="sportType">
        <option value="">Tất cả loại sân</option>
        <option value="Badminton"
            <c:if test="${sportType == 'Badminton'}">selected</c:if>>
            Cầu lông
        </option>
        <option value="Pickleball"
            <c:if test="${sportType == 'Pickleball'}">selected</c:if>>
            Pickleball
        </option>
        <option value="Football"
            <c:if test="${sportType == 'Football'}">selected</c:if>>
            Bóng đá
        </option>
    </select>

    <button type="submit">Tìm kiếm</button>
    <a href="${pageContext.request.contextPath}/CourtController">Xóa lọc</a>
</form>

<table>
    <thead>
        <tr>
            <th>Mã sân</th>
            <th>Tên sân</th>
            <th>Loại sân</th>
            <th>Giá thuê / giờ</th>
            <th>Trạng thái</th>
            <th>Thao tác</th>
        </tr>
    </thead>

    <tbody>
        <c:forEach items="${courts}" var="c">
            <tr>
                <td><c:out value="${c.courtId}"/></td>
                <td><c:out value="${c.courtName}"/></td>
                <td><c:out value="${c.sportType}"/></td>
                <td>
                    <fmt:formatNumber value="${c.pricePerHour}"
                                      pattern="#,##0"/> VNĐ
                </td>
                <td>
                    <c:choose>
                        <c:when test="${c.active}">
                            <span class="active">Đang hoạt động</span>
                        </c:when>
                        <c:otherwise>
                            <span class="inactive">Ngừng hoạt động</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <c:choose>
                        <c:when test="${c.active}">
                            <a class="btn"
                               href="${pageContext.request.contextPath}/BookingController?courtId=${c.courtId}">
                                Đặt sân
                            </a>
                        </c:when>
                        <c:otherwise>
                            <span class="disabled">Không thể đặt</span>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>

        <c:if test="${empty courts}">
            <tr>
                <td colspan="6">Không tìm thấy sân.</td>
            </tr>
        </c:if>
    </tbody>
</table>

</body>
</html>
```