<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SportBooking | Lịch đặt của tôi</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"><link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{--ink:#182338;--muted:#718096;--primary:#5b5ce2;--bg:#f4f6fb}*{box-sizing:border-box}body{margin:0;font-family:'Be Vietnam Pro',Arial,sans-serif;color:var(--ink);background:var(--bg)}
            .topbar{height:74px;background:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 5%;box-shadow:0 4px 20px #252b550d}.brand{font-size:22px;font-weight:800;color:var(--primary)}.brand span{color:#f59e0b}
            .nav{display:flex;gap:18px;align-items:center;font-size:14px}.nav a{color:var(--muted);text-decoration:none;font-weight:600}.nav a:hover{color:var(--primary)}.nav button{border:0;background:none;color:var(--muted);font:600 14px 'Be Vietnam Pro';cursor:pointer}
            .wrap{max-width:1100px;margin:38px auto;padding:0 18px}.eyebrow{color:var(--primary);font-weight:700;font-size:13px;text-transform:uppercase;letter-spacing:1.4px}.title{font-size:30px;margin:8px 0 24px}
            .flash{background:#dcfce7;color:#15803d;border-radius:10px;padding:12px 14px;margin-bottom:18px;font-size:14px;font-weight:600}
            .panel{background:#fff;border-radius:18px;box-shadow:0 8px 24px #252b550b;overflow:hidden}.table-wrap{overflow:auto}
            table{width:100%;border-collapse:collapse;min-width:760px}th,td{padding:16px 18px;text-align:left;border-bottom:1px solid #edf0f6;font-size:14px}th{background:#fafbfe;color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.4px}
            .sub{display:block;color:var(--muted);font-size:12px;margin-top:3px}
            .tag{display:inline-block;border-radius:99px;padding:6px 10px;font-size:12px;font-weight:700;background:#fff4d6;color:#a16207}.tag.confirmed{background:#dcfce7;color:#15803d}.tag.cancelled{background:#fee2e2;color:#b91c1c}
            .btn{border:0;border-radius:8px;padding:8px 12px;color:#fff;background:#ef4444;cursor:pointer;font:600 12px 'Be Vietnam Pro'}.btn.primary{background:var(--primary);text-decoration:none;display:inline-block;padding:12px 20px;font-size:14px;font-weight:700;border-radius:10px}
            .empty{text-align:center;padding:52px;color:var(--muted)}
        </style>
    </head>
    <body>
        <header class="topbar"><div class="brand">Sport<span>Booking</span></div>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/CourtController">Danh sách sân</a>
                <a href="${pageContext.request.contextPath}/BookingController">Đặt sân mới</a>
                <form method="post" action="${pageContext.request.contextPath}/login" style="margin:0"><input type="hidden" name="action" value="logout"><button type="submit">Đăng xuất</button></form>
            </nav>
        </header>
        <main class="wrap">
            <div class="eyebrow">Khách hàng</div><h1 class="title">Lịch đặt sân của tôi</h1>
            <c:if test="${not empty flash}"><div class="flash"><c:out value="${flash}"/></div></c:if>
            <section class="panel">
                <c:choose>
                    <c:when test="${empty bookings}">
                        <div class="empty">Bạn chưa có lịch đặt nào.<br><br><a class="btn primary" href="${pageContext.request.contextPath}/BookingController">Đặt sân ngay</a></div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap"><table>
                            <tr><th>Mã</th><th>Sân</th><th>Ngày</th><th>Giờ chơi</th><th>Tổng tiền</th><th>Trạng thái</th><th></th></tr>
                            <c:forEach items="${bookings}" var="b">
                                <tr>
                                    <td>#${b.bookingID}</td>
                                    <td><b><c:out value="${b.courtName}"/></b><span class="sub"><c:out value="${b.sportType}"/></span></td>
                                    <td>${b.bookingDate}</td>
                                    <td>${b.startTime} - ${b.endTime}</td>
                                    <td><b><fmt:formatNumber value="${b.totalPrice}" pattern="#,##0"/> đ</b></td>
                                    <td><span class="tag ${b.status.toLowerCase()}">${b.status}</span></td>
                                    <td>
                                        <c:if test="${b.status == 'PENDING' || b.status == 'CONFIRMED'}">
                                            <form method="post" action="${pageContext.request.contextPath}/MyBookingController" style="margin:0">
                                                <input type="hidden" name="bookingId" value="${b.bookingID}">
                                                <button type="submit" class="btn" onclick="return confirm('Hủy lịch đặt này?')">Hủy</button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table></div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>
    </body>
</html>
