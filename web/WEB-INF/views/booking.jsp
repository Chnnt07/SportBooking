<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SportBooking | Đặt sân</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"><link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{--ink:#182338;--muted:#718096;--primary:#5b5ce2;--bg:#f4f6fb}*{box-sizing:border-box}body{margin:0;font-family:'Be Vietnam Pro',Arial,sans-serif;color:var(--ink);background:var(--bg)}
            .topbar{height:74px;background:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 5%;box-shadow:0 4px 20px #252b550d}.brand{font-size:22px;font-weight:800;color:var(--primary)}.brand span{color:#f59e0b}
            .nav{display:flex;gap:18px;align-items:center;font-size:14px}.nav a{color:var(--muted);text-decoration:none;font-weight:600}.nav a:hover{color:var(--primary)}.nav button{border:0;background:none;color:var(--muted);font:600 14px 'Be Vietnam Pro';cursor:pointer}
            .wrap{max-width:760px;margin:38px auto;padding:0 18px}.eyebrow{color:var(--primary);font-weight:700;font-size:13px;text-transform:uppercase;letter-spacing:1.4px}.title{font-size:30px;margin:8px 0 24px}
            .panel{background:#fff;border-radius:18px;box-shadow:0 8px 24px #252b550b;padding:24px;margin-bottom:22px}
            label{display:block;margin:14px 0 6px;font-weight:600;font-size:14px}select,input[type=date]{width:100%;border:1px solid #dfe3ee;border-radius:9px;padding:11px 12px;font:inherit;color:var(--ink);background:#fff}
            .row{display:flex;gap:10px;align-items:end}.row>div{flex:1}.grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
            .btn{border:0;border-radius:10px;padding:12px 20px;color:#fff;background:var(--primary);cursor:pointer;font:700 14px 'Be Vietnam Pro'}.btn.sec{background:#64748b}
            .err{background:#fee2e2;color:#b91c1c;border-radius:10px;padding:12px 14px;margin-bottom:18px;font-size:14px}
            .busy{display:flex;flex-wrap:wrap;gap:8px;margin:10px 0 0}.busy span{background:#fee2e2;color:#b91c1c;border-radius:99px;padding:6px 12px;font-size:13px;font-weight:600}
            .free{color:#15803d;font-weight:600}.hint{color:var(--muted);font-size:13px}#total{font-size:18px;font-weight:700;margin-top:16px;min-height:26px}
            @media(max-width:560px){.grid{grid-template-columns:1fr}.row{flex-direction:column;align-items:stretch}}
        </style>
    </head>
    <body>
        <header class="topbar"><div class="brand">Sport<span>Booking</span></div>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/CourtController">Danh sách sân</a>
                <a href="${pageContext.request.contextPath}/MyBookingController">Lịch đặt của tôi</a>
                <form method="post" action="${pageContext.request.contextPath}/login" style="margin:0"><input type="hidden" name="action" value="logout"><button type="submit">Đăng xuất</button></form>
            </nav>
        </header>
        <main class="wrap">
            <div class="eyebrow">Đặt sân</div><h1 class="title">Chọn sân và khung giờ</h1>

            <c:if test="${not empty error}"><div class="err"><c:out value="${error}"/></div></c:if>

            <section class="panel">
                <form method="get" action="${pageContext.request.contextPath}/BookingController">
                    <label for="courtId">Sân</label>
                    <select id="courtId" name="courtId" required>
                        <option value="">-- Chọn sân --</option>
                        <c:forEach items="${courts}" var="c">
                            <option value="${c.courtId}" <c:if test="${selectedCourtId == c.courtId}">selected</c:if>>
                                <c:out value="${c.courtName}"/> - <c:out value="${c.sportType}"/> (<fmt:formatNumber value="${c.pricePerHour}" pattern="#,##0"/> đ/giờ)
                            </option>
                        </c:forEach>
                    </select>
                    <div class="row">
                        <div><label for="date">Ngày</label><input id="date" type="date" name="date" min="${today}" value="${selectedDate}" required></div>
                        <button type="submit" class="btn sec">Xem lịch</button>
                    </div>
                </form>
            </section>

            <c:if test="${not empty court}">
                <section class="panel">
                    <h3 style="margin:0 0 4px"><c:out value="${court.courtName}"/> · ${selectedDate}</h3>
                    <p class="hint" style="margin:0 0 14px">Sân mở cửa 05:00 - 24:00. Chọn giờ theo bước 15 phút, tối thiểu 30 phút.</p>
                    <c:choose>
                        <c:when test="${empty busy}"><div class="free">Cả ngày còn trống.</div></c:when>
                        <c:otherwise>
                            <div class="hint">Các giờ đã có người đặt:</div>
                            <div class="busy"><c:forEach items="${busy}" var="r"><span>${r}</span></c:forEach></div>
                        </c:otherwise>
                    </c:choose>

                    <form method="post" action="${pageContext.request.contextPath}/BookingController" id="bookingForm" data-price="${court.pricePerHour}">
                        <input type="hidden" name="courtId" value="${court.courtId}">
                        <input type="hidden" name="date" value="${selectedDate}">
                        <div class="grid">
                            <div><label for="start">Giờ bắt đầu</label>
                                <select id="start" name="start" required><option value="">--</option>
                                    <c:forEach items="${startOptions}" var="t"><option value="${t}" <c:if test="${selectedStart == t}">selected</c:if>>${t}</option></c:forEach>
                                </select></div>
                            <div><label for="end">Giờ kết thúc</label>
                                <select id="end" name="end" required><option value="">--</option>
                                    <c:forEach items="${endOptions}" var="t"><option value="${t}" <c:if test="${selectedEnd == t}">selected</c:if>>${t}</option></c:forEach>
                                </select></div>
                        </div>
                        <div id="total"></div>
                        <button type="submit" class="btn" style="margin-top:8px">Xác nhận đặt sân</button>
                    </form>
                </section>
                <script src="${pageContext.request.contextPath}/js/booking.js"></script>
            </c:if>
        </main>
    </body>
</html>
