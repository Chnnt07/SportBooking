<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List,models.Booking"%>
<%!
    private String esc(Object value) { if (value == null) return ""; return String.valueOf(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SportBooking | Quản lý lịch đặt</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"><link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{--ink:#182338;--muted:#718096;--primary:#5b5ce2;--bg:#f4f6fb}*{box-sizing:border-box}body{margin:0;font-family:'Be Vietnam Pro',Arial,sans-serif;color:var(--ink);background:var(--bg)}.topbar{height:74px;background:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 5%;box-shadow:0 4px 20px #252b550d}.brand{font-size:22px;font-weight:800;color:var(--primary)}.brand span{color:#f59e0b}.profile{color:var(--muted);font-size:14px}.wrap{max-width:1320px;margin:38px auto;padding:0 24px}.eyebrow{color:var(--primary);font-weight:700;font-size:13px;text-transform:uppercase;letter-spacing:1.4px}.title{font-size:32px;margin:8px 0 28px}.summary{display:flex;gap:18px;margin-bottom:26px}.card{background:#fff;border-radius:16px;padding:20px 24px;min-width:190px;box-shadow:0 8px 24px #252b550b}.card small{color:var(--muted)}.card strong{display:block;font-size:25px;margin-top:8px}.panel{background:#fff;border-radius:18px;box-shadow:0 8px 24px #252b550b;overflow:hidden}.panel-head{padding:22px 24px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #edf0f6}.filter select{border:1px solid #dfe3ee;border-radius:9px;padding:10px 34px 10px 12px;color:var(--ink);background:#fff;font:inherit}.table-wrap{overflow:auto}table{width:100%;border-collapse:collapse;min-width:920px}th,td{padding:16px 18px;text-align:left;border-bottom:1px solid #edf0f6;font-size:14px}th{background:#fafbfe;color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.4px}tr:hover td{background:#fafbff}.customer{font-weight:600}.sub{display:block;color:var(--muted);font-size:12px;margin-top:3px}.tag{display:inline-block;border-radius:99px;padding:6px 10px;font-size:12px;font-weight:700;background:#fff4d6;color:#a16207}.tag.confirmed{background:#dcfce7;color:#15803d}.tag.cancelled{background:#fee2e2;color:#b91c1c}.actions{display:flex;gap:7px}.btn{border:0;border-radius:8px;padding:8px 11px;color:#fff;cursor:pointer;font:600 12px 'Be Vietnam Pro'}.ok{background:#16a34a}.danger{background:#ef4444}.empty{text-align:center;padding:48px;color:var(--muted)}@media(max-width:700px){.wrap{margin:22px auto;padding:0 14px}.title{font-size:25px}.summary{flex-wrap:wrap}.card{flex:1;min-width:140px}.topbar{padding:0 18px}}
        </style>
    </head>
    <body>
        <header class="topbar"><div class="brand">Sport<span>Booking</span></div><div class="profile">Khu vực quản trị · <b>Admin</b></div></header>
        <main class="wrap"><div class="eyebrow">Admin dashboard</div><h1 class="title">Quản lý lịch đặt</h1>
        <% List<Booking> all=(List<Booking>)request.getAttribute("bookings"); int total=all==null?0:all.size(); %>
        <div class="summary"><div class="card"><small>Lịch đặt đang xem</small><strong><%=total%></strong></div><div class="card"><small>Trạng thái lọc</small><strong><%=esc(request.getAttribute("selectedStatus"))%></strong></div></div>
        <section class="panel"><div class="panel-head"><b>Danh sách booking</b><form class="filter" method="get" action="<%=request.getContextPath()%>/AdminBookingController"><select name="status" onchange="this.form.submit()">
                <% String selected=(String)request.getAttribute("selectedStatus"); %>
                <option value="ALL" <%= "ALL".equalsIgnoreCase(selected)?"selected":"" %>>Tất cả</option>
                <option value="Pending" <%= "Pending".equalsIgnoreCase(selected)?"selected":"" %>>Chờ xác nhận</option>
                <option value="Confirmed" <%= "Confirmed".equalsIgnoreCase(selected)?"selected":"" %>>Đã xác nhận</option>
                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(selected)?"selected":"" %>>Đã hủy</option>
            </select></form></div>
        <table><tr><th>Mã</th><th>Khách hàng</th><th>Sân</th><th>Ngày</th><th>Thời gian</th><th>Tổng tiền</th><th>Trạng thái</th><th>Thao tác</th></tr>
        <% List<Booking> bookings=(List<Booking>)request.getAttribute("bookings"); if (bookings != null) for (Booking b: bookings) { %>
            <tr><td>#<%=b.getBookingID()%></td><td class="customer"><%=esc(b.getFullName())%><span class="sub"><%=esc(b.getUsername())%></span></td><td><b><%=esc(b.getCourtName())%></b><span class="sub"><%=esc(b.getSportType())%></span></td><td><%=esc(b.getBookingDate())%></td><td><%=esc(b.getStartTime())%> - <%=esc(b.getEndTime())%></td><td><b><%=String.format("%,.0f",b.getTotalPrice())%> đ</b></td><td><span class="tag <%=b.getStatus()==null?"":b.getStatus().toLowerCase()%>"><%=esc(b.getStatus())%></span></td><td class="actions">
            <% if ("Pending".equalsIgnoreCase(b.getStatus())) { %><form method="post" action="<%=request.getContextPath()%>/AdminBookingController" style="display:inline"><input type="hidden" name="bookingId" value="<%=b.getBookingID()%>"><button class="btn ok" name="action" value="confirm">Xác nhận</button></form> <form method="post" action="<%=request.getContextPath()%>/AdminBookingController" style="display:inline"><input type="hidden" name="bookingId" value="<%=b.getBookingID()%>"><button class="btn danger" name="action" value="cancel" onclick="return confirm('Hủy lịch đặt này?')">Hủy</button></form><% } else { %>-<% } %>
            </td></tr>
        <% } %></table></div></section></main>
    </body>
</html>
