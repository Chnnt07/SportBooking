<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="models.Court"%>
<%!
    // Đổi các ký tự đặc biệt của HTML để tên sân không làm hỏng trang (chống XSS)
    private String esc(Object value) {
        if (value == null) {
            return "";
        }
        return value.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
<<<<<<< HEAD
    // ---- Lấy dữ liệu do AdminCourtServlet gửi sang ----
    String url = request.getContextPath() + "/AdminCourtController";
=======
    // ---- Lấy dữ liệu do AdminCourtController gửi sang ----
    String url = request.getContextPath() + "/AdminCourtController";
    String backUrl = request.getContextPath() + "/AdminBookingController"; // nút quay lại
>>>>>>> feature/admin-courts

<<<<<<< Updated upstream
    List<Court> courts = (List<Court>) request.getAttribute("courts");          // danh sách đang hiện (đã lọc)
    List<Court> allCourts = (List<Court>) request.getAttribute("allCourts");    // tất cả sân (cho thẻ thống kê)

    // Từ khóa đang tìm theo tên sân (rỗng nếu không tìm)
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) {
        keyword = "";
    }
    String keywordEncoded = URLEncoder.encode(keyword, StandardCharsets.UTF_8); // dùng trong đường dẫn
=======
    List<Court> courts = (List<Court>) request.getAttribute("courts");
    String searchKeyword = (String) request.getAttribute("searchKeyword");    // chữ đã tìm (nếu có)
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
>>>>>>> feature/admin-courts
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");

    // Dữ liệu của form (rỗng khi đang thêm mới, có giá trị khi đang sửa)
    Object formId = request.getAttribute("formId");
    Object formName = request.getAttribute("formName");
    Object formType = request.getAttribute("formType");
    Object formPrice = request.getAttribute("formPrice");

    // formId có giá trị -> đang sửa; không có -> đang thêm mới
    boolean editing = (formId != null && !formId.toString().isEmpty());

    // Số liệu cho các thẻ thống kê
    int total = 0;
    int activeCount = 0;
    if (allCourts != null) {
        total = allCourts.size();
        for (Court c : allCourts) {
            if (c.isActive()) {
                activeCount++;
            }
        }
    }
    int inactiveCount = total - activeCount;
    int shown = (courts == null) ? 0 : courts.size();

    DecimalFormat money = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/feature/court-list-hung
        <title>SportBooking | Quản lý sân</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root { --ink: #182338; --muted: #718096; --primary: #5b5ce2; --bg: #f4f6fb; }
            * { box-sizing: border-box; }
            body { margin: 0; font-family: 'Be Vietnam Pro', Arial, sans-serif; color: var(--ink); background: var(--bg); }

            .topbar { height: 74px; background: #fff; display: flex; align-items: center; justify-content: space-between;
                      padding: 0 5%; box-shadow: 0 4px 20px #252b550d; }
            .brand { font-size: 22px; font-weight: 800; color: var(--primary); }
            .brand span { color: #f59e0b; }
            .profile { color: var(--muted); font-size: 14px; }

            .wrap { max-width: 1320px; margin: 38px auto; padding: 0 24px; }
            .eyebrow { color: var(--primary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 1.4px; }
            .title { font-size: 32px; margin: 8px 0 28px; }

            .panel { background: #fff; border-radius: 18px; box-shadow: 0 8px 24px #252b550b; overflow: hidden; margin-bottom: 26px; }
            .panel-head { padding: 22px 24px; display: flex; align-items: center; justify-content: space-between;
                          border-bottom: 1px solid #edf0f6; gap: 12px; flex-wrap: wrap; }
            .panel-body { padding: 24px; }
            .panel-head h2 { margin: 0; font-size: 16px; }

            .message { padding: 12px 16px; border-radius: 12px; margin-bottom: 22px; font-size: 14px; font-weight: 500; }
            .message.success { background: #dcfce7; color: #15803d; }
            .message.error { background: #fee2e2; color: #b91c1c; }

            label { display: block; margin: 16px 0 6px; font-weight: 600; font-size: 14px; }
            label:first-of-type { margin-top: 0; }
            input[type=text], input[type=number], select {
                width: 100%; padding: 11px 13px; border: 1px solid #dfe3ee; border-radius: 9px;
                font: inherit; font-size: 14px; color: var(--ink); background: #fff; }
            input:focus, select:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px #5b5ce220; }

            button, .btn { display: inline-block; border: 0; border-radius: 8px; padding: 10px 16px; color: #fff; cursor: pointer;
                           font: 600 13px 'Be Vietnam Pro', Arial, sans-serif; text-decoration: none; background: var(--primary); }
            button:hover, .btn:hover { opacity: .9; }
            .btn-gray { background: #64748b; }
            .btn-orange { background: #f59e0b; }
            .btn-green { background: #16a34a; }
            .btn-red { background: #ef4444; }
            .btn-sm { padding: 8px 11px; font-size: 12px; }
            .nav-btn { margin-left: 14px; padding: 9px 14px; }

            .row { display: flex; gap: 10px; }
            .row input { flex: 1; }
            .actions { margin-top: 22px; display: flex; gap: 8px; }
            .hint { margin: 12px 0 0; font-size: 13px; }
            .hint a { color: var(--primary); font-weight: 600; text-decoration: none; }

            .table-wrap { overflow: auto; }
            table { width: 100%; border-collapse: collapse; min-width: 760px; }
            th, td { padding: 16px 18px; text-align: left; border-bottom: 1px solid #edf0f6; font-size: 14px; }
            th { background: #fafbfe; color: var(--muted); font-size: 12px; text-transform: uppercase; letter-spacing: .4px; }
            tr:hover td { background: #fafbff; }
            .empty { text-align: center; padding: 40px; color: var(--muted); }

            .tag { display: inline-block; border-radius: 99px; padding: 6px 10px; font-size: 12px; font-weight: 700; }
            .tag.on { background: #dcfce7; color: #15803d; }
            .tag.off { background: #fee2e2; color: #b91c1c; }

            .cell-actions { display: flex; gap: 7px; }
            form.inline { display: inline; }

            @media (max-width: 700px) {
                .wrap { margin: 22px auto; padding: 0 14px; }
                .title { font-size: 25px; }
                .topbar { padding: 0 18px; }
                .profile { font-size: 12px; }
            }
        </style>
    </head>
    <body>
<<<<<<< HEAD
=======
<<<<<<< Updated upstream
        <title>Quản lý sân - SportBooking</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap">
        <style>
            * { box-sizing: border-box; }
            body { margin: 0; background: #f5f7fb; color: #111827;
                   font-family: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }

            /* ===== Thanh trên cùng ===== */
            .topbar { background: #fff; height: 84px; padding: 0 32px; display: flex;
                      align-items: center; justify-content: space-between;
                      box-shadow: 0 2px 12px rgba(17,24,39,.05); }
            .logo { font-size: 32px; font-weight: 800; text-decoration: none; letter-spacing: -.5px; }
            .logo .sport { color: #5b4fe0; }
            .logo .booking { color: #f59e0b; }
            .topbar-right { color: #6b7280; font-size: 16px; }
            .topbar-right strong { color: #4b5563; font-weight: 700; }

            /* ===== Nội dung ===== */
            .page { max-width: 1600px; margin: 0 auto; padding: 36px 32px 60px; }
            .page-head { display: flex; align-items: flex-end; justify-content: space-between;
                         gap: 16px; flex-wrap: wrap; margin-bottom: 28px; }
            .eyebrow { color: #4f46e5; font-weight: 700; font-size: 15px;
                       letter-spacing: .12em; text-transform: uppercase; }
            h1 { margin: 6px 0 0; font-size: 44px; line-height: 1.15; font-weight: 800; color: #0f172a; }
            .btn-back { display: inline-flex; align-items: center; gap: 8px; padding: 12px 20px;
                        border-radius: 999px; background: #fff; color: #4f46e5; font-weight: 700;
                        font-size: 15px; text-decoration: none; border: 1px solid #e0e3ff;
                        box-shadow: 0 2px 8px rgba(79,70,229,.08); }
            .btn-back:hover { background: #eef0ff; }

            /* ===== Thẻ thống kê ===== */
            .stats { display: flex; gap: 24px; flex-wrap: wrap; margin-bottom: 32px; }
            .stat { background: #fff; border-radius: 24px; padding: 26px 36px; min-width: 285px;
                    box-shadow: 0 8px 30px rgba(17,24,39,.05); }
            .stat .label { color: #6b7280; font-size: 17px; }
            .stat .value { margin-top: 10px; font-size: 40px; font-weight: 800; color: #0f172a; }

            /* ===== Khung nội dung ===== */
            .card { background: #fff; border-radius: 28px; margin-bottom: 32px; overflow: hidden;
                    box-shadow: 0 8px 30px rgba(17,24,39,.05); }
            .card-head { padding: 28px 36px; display: flex; align-items: center;
                         justify-content: space-between; gap: 12px; }
            .card-head h2 { margin: 0; font-size: 24px; font-weight: 700; color: #0f172a; }
            .card-body { padding: 0 36px 32px; }

            /* ===== Thông báo ===== */
            .message { padding: 14px 20px; border-radius: 16px; margin-bottom: 24px; font-weight: 500; }
            .message.success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
            .message.error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

            /* ===== Form ===== */
            .form-grid { display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 20px; }
            @media (max-width: 800px) { .form-grid { grid-template-columns: 1fr; } }
            label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 15px; color: #374151; }
            input[type=text], input[type=number], select {
                width: 100%; padding: 13px 16px; border: 1px solid #e5e7eb; border-radius: 14px;
                font-family: inherit; font-size: 16px; background: #fff; color: #111827; }
            input:focus, select:focus { outline: none; border-color: #4f46e5;
                                        box-shadow: 0 0 0 3px rgba(79,70,229,.15); }
            .form-actions { margin-top: 24px; display: flex; gap: 12px; flex-wrap: wrap; }
            .btn-primary { padding: 13px 28px; border: none; border-radius: 14px; background: #4f46e5;
                           color: #fff; font-family: inherit; font-size: 16px; font-weight: 700; cursor: pointer; }
            .btn-primary:hover { background: #4338ca; }
            .btn-cancel { display: inline-flex; align-items: center; padding: 13px 24px; border-radius: 14px;
                          background: #f3f4f6; color: #374151; font-weight: 600; text-decoration: none; }
            .btn-cancel:hover { background: #e5e7eb; }

            /* ===== Thanh tìm kiếm / xóa theo ID ===== */
            .toolbar { padding: 0 36px 24px; display: flex; gap: 20px; flex-wrap: wrap; }
            .toolbar form { display: flex; gap: 10px; flex: 1 1 340px; align-items: center; }
            .toolbar input { flex: 1; min-width: 0; }
            .btn-search { padding: 13px 22px; border: none; border-radius: 14px; background: #4f46e5;
                          color: #fff; font-family: inherit; font-size: 15px; font-weight: 700; cursor: pointer; }
            .btn-search:hover { background: #4338ca; }
            .btn-danger { padding: 13px 22px; border: none; border-radius: 14px; background: #dc2626;
                          color: #fff; font-family: inherit; font-size: 15px; font-weight: 700; cursor: pointer; white-space: nowrap; }
            .btn-danger:hover { background: #b91c1c; }
            .btn-clear { color: #6b7280; font-weight: 600; text-decoration: none; white-space: nowrap; }
            .btn-clear:hover { color: #111827; }
            .muted { color: #6b7280; font-size: 15px; }

            /* ===== Bảng ===== */
            .table-wrap { overflow-x: auto; }
            table { width: 100%; border-collapse: collapse; }
            th { background: #f9fafc; color: #6b7280; font-size: 14px; font-weight: 700;
                 letter-spacing: .04em; text-transform: uppercase; text-align: left;
                 padding: 20px 24px; border-top: 1px solid #eef0f5; border-bottom: 1px solid #eef0f5; }
            td { padding: 22px 24px; border-bottom: 1px solid #eef0f5; font-size: 17px; vertical-align: middle; }
            th:first-child, td:first-child { padding-left: 36px; }
            th:last-child, td:last-child { padding-right: 36px; }
            tr:last-child td { border-bottom: none; }
            .name { font-weight: 700; color: #0f172a; }
            .sub { margin-top: 4px; color: #6b7280; font-size: 15px; font-weight: 400; }
            .price { font-weight: 700; }
            .pill { display: inline-block; padding: 7px 16px; border-radius: 999px; font-size: 15px; font-weight: 700; }
            .pill.on { background: #dcfce7; color: #15803d; }
            .pill.off { background: #fee2e2; color: #b91c1c; }
            .empty { text-align: center; color: #6b7280; padding: 40px 0; }

            /* ===== Nút thao tác trong bảng ===== */
            td.actions-cell { white-space: nowrap; }
            form.inline { display: inline; }
            .act { display: inline-block; padding: 9px 16px; margin-right: 6px; border: none; border-radius: 12px;
                   font-family: inherit; font-size: 14px; font-weight: 600; text-decoration: none; cursor: pointer; }
            .act-edit { background: #fff1e0; color: #c2410c; }
            .act-edit:hover { background: #ffe4c4; }
            .act-stop { background: #fee2e2; color: #b91c1c; }
            .act-stop:hover { background: #fecaca; }
            .act-start { background: #dcfce7; color: #15803d; }
            .act-start:hover { background: #bbf7d0; }
            .act-delete { background: #f3f4f6; color: #374151; margin-right: 0; }
            .act-delete:hover { background: #e5e7eb; }
        </style>
    </head>
    <body>
        <%-- ============ THANH TRÊN CÙNG ============ --%>
        <header class="topbar">
            <a class="logo" href="<%= backUrl %>"><span class="sport">Sport</span><span class="booking">Booking</span></a>
            <div class="topbar-right">Khu vực quản trị · <strong>Admin</strong></div>
        </header>

        <main class="page">
            <div class="page-head">
                <div>
                    <div class="eyebrow">Admin Dashboard</div>
                    <h1>Quản lý sân</h1>
                </div>
                <%-- Nút quay lại trang Quản lý lịch đặt --%>
                <a class="btn-back" href="<%= backUrl %>">&larr; Quay lại quản lý lịch đặt</a>
            </div>

            <%-- ============ THẺ THỐNG KÊ ============ --%>
            <div class="stats">
                <div class="stat"><div class="label">Tổng số sân</div><div class="value"><%= total %></div></div>
                <div class="stat"><div class="label">Đang hoạt động</div><div class="value"><%= activeCount %></div></div>
                <div class="stat"><div class="label">Ngừng hoạt động</div><div class="value"><%= inactiveCount %></div></div>
            </div>
=======
        <title>SportBooking | Quản lý sân</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root { --ink: #182338; --muted: #718096; --primary: #5b5ce2; --bg: #f4f6fb; }
            * { box-sizing: border-box; }
            body { margin: 0; font-family: 'Be Vietnam Pro', Arial, sans-serif; color: var(--ink); background: var(--bg); }

            .topbar { height: 74px; background: #fff; display: flex; align-items: center; justify-content: space-between;
                      padding: 0 5%; box-shadow: 0 4px 20px #252b550d; }
            .brand { font-size: 22px; font-weight: 800; color: var(--primary); }
            .brand span { color: #f59e0b; }
            .profile { color: var(--muted); font-size: 14px; }

            .wrap { max-width: 1320px; margin: 38px auto; padding: 0 24px; }
            .eyebrow { color: var(--primary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 1.4px; }
            .title { font-size: 32px; margin: 8px 0 28px; }

            .panel { background: #fff; border-radius: 18px; box-shadow: 0 8px 24px #252b550b; overflow: hidden; margin-bottom: 26px; }
            .panel-head { padding: 22px 24px; display: flex; align-items: center; justify-content: space-between;
                          border-bottom: 1px solid #edf0f6; gap: 12px; flex-wrap: wrap; }
            .panel-body { padding: 24px; }
            .panel-head h2 { margin: 0; font-size: 16px; }

            .message { padding: 12px 16px; border-radius: 12px; margin-bottom: 22px; font-size: 14px; font-weight: 500; }
            .message.success { background: #dcfce7; color: #15803d; }
            .message.error { background: #fee2e2; color: #b91c1c; }

            label { display: block; margin: 16px 0 6px; font-weight: 600; font-size: 14px; }
            label:first-of-type { margin-top: 0; }
            input[type=text], input[type=number], select {
                width: 100%; padding: 11px 13px; border: 1px solid #dfe3ee; border-radius: 9px;
                font: inherit; font-size: 14px; color: var(--ink); background: #fff; }
            input:focus, select:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px #5b5ce220; }

            button, .btn { display: inline-block; border: 0; border-radius: 8px; padding: 10px 16px; color: #fff; cursor: pointer;
                           font: 600 13px 'Be Vietnam Pro', Arial, sans-serif; text-decoration: none; background: var(--primary); }
            button:hover, .btn:hover { opacity: .9; }
            .btn-gray { background: #64748b; }
            .btn-orange { background: #f59e0b; }
            .btn-green { background: #16a34a; }
            .btn-red { background: #ef4444; }
            .btn-sm { padding: 8px 11px; font-size: 12px; }
            .nav-btn { margin-left: 14px; padding: 9px 14px; }

            .row { display: flex; gap: 10px; }
            .row input { flex: 1; }
            .actions { margin-top: 22px; display: flex; gap: 8px; }
            .hint { margin: 12px 0 0; font-size: 13px; }
            .hint a { color: var(--primary); font-weight: 600; text-decoration: none; }

            .table-wrap { overflow: auto; }
            table { width: 100%; border-collapse: collapse; min-width: 760px; }
            th, td { padding: 16px 18px; text-align: left; border-bottom: 1px solid #edf0f6; font-size: 14px; }
            th { background: #fafbfe; color: var(--muted); font-size: 12px; text-transform: uppercase; letter-spacing: .4px; }
            tr:hover td { background: #fafbff; }
            .empty { text-align: center; padding: 40px; color: var(--muted); }

            .tag { display: inline-block; border-radius: 99px; padding: 6px 10px; font-size: 12px; font-weight: 700; }
            .tag.on { background: #dcfce7; color: #15803d; }
            .tag.off { background: #fee2e2; color: #b91c1c; }

            .cell-actions { display: flex; gap: 7px; }
            form.inline { display: inline; }

            @media (max-width: 700px) {
                .wrap { margin: 22px auto; padding: 0 14px; }
                .title { font-size: 25px; }
                .topbar { padding: 0 18px; }
                .profile { font-size: 12px; }
            }
        </style>
    </head>
    <body>
>>>>>>> feature/admin-courts
=======
>>>>>>> origin/feature/court-list-hung
        <header class="topbar">
            <div class="brand">Sport<span>Booking</span></div>
            <div class="profile">Khu vực quản trị · <b>Admin</b>
                <a class="btn nav-btn" href="<%= request.getContextPath() %>/AdminBookingController">&laquo; Quay lại lịch đặt</a>
            </div>
        </header>

        <main class="wrap">
            <div class="eyebrow">Admin dashboard</div>
            <h1 class="title">Quản lý sân</h1>
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
>>>>>>> feature/admin-courts
=======
>>>>>>> origin/feature/court-list-hung

            <%-- Thông báo thành công / lỗi --%>
            <% if (message != null) { %>
                <div class="message <%= esc(messageType) %>"><%= esc(message) %></div>
            <% } %>

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/feature/court-list-hung
            <%-- ============ THANH TÌM THEO TÊN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2>Tìm theo tên sân</h2></div>
                <div class="panel-body">
                    <form class="row" method="get" action="<%= url %>">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="keyword" maxlength="100" placeholder="Nhập tên sân"
                               value="<%= esc(searchKeyword) %>">
                        <button type="submit">Tìm</button>
                    </form>
                    <% if (searchKeyword != null) { %>
                        <p class="hint"><a href="<%= url %>">Hiện tất cả sân</a></p>
                    <% } %>
                </div>
            </section>

            <%-- ============ FORM THÊM / SỬA SÂN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2><%= editing ? "Sửa sân" : "Thêm sân mới" %></h2></div>
                <div class="panel-body">
                    <form method="post" action="<%= url %>">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "add" %>">
                        <input type="hidden" name="courtId" value="<%= editing ? esc(formId) : "" %>">

                        <label for="courtName">Tên sân</label>
                        <input type="text" id="courtName" name="courtName" maxlength="100"
                               value="<%= esc(formName) %>">

                        <label for="sportType">Loại sân</label>
                        <select id="sportType" name="sportType">
                            <option value="">-- Chọn loại sân --</option>
                            <option value="Badminton" <%= "Badminton".equals(formType) ? "selected" : "" %>>Cầu lông (Badminton)</option>
                            <option value="Pickleball" <%= "Pickleball".equals(formType) ? "selected" : "" %>>Pickleball</option>
                            <option value="Football" <%= "Football".equals(formType) ? "selected" : "" %>>Bóng đá (Football)</option>
                        </select>

                        <label for="pricePerHour">Giá thuê mỗi giờ (VNĐ)</label>
                        <input type="number" id="pricePerHour" name="pricePerHour" min="1" step="1"
                               value="<%= esc(formPrice) %>">

<<<<<<< HEAD
=======
<<<<<<< Updated upstream
            <%-- ============ FORM THÊM / SỬA SÂN ============ --%>
            <div class="card">
                <div class="card-head">
                    <h2><%= editing ? "Sửa sân" : "Thêm sân mới" %></h2>
                </div>
                <div class="card-body">
                    <form method="post" action="<%= url %>">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "add" %>">
                        <input type="hidden" name="courtId" value="<%= editing ? esc(formId) : "" %>">
                        <input type="hidden" name="keyword" value="<%= esc(keyword) %>">

                        <div class="form-grid">
                            <div>
                                <label for="courtName">Tên sân</label>
                                <input type="text" id="courtName" name="courtName" maxlength="100"
                                       value="<%= esc(formName) %>">
                            </div>
                            <div>
                                <label for="sportType">Loại sân</label>
                                <select id="sportType" name="sportType">
                                    <option value="">-- Chọn loại sân --</option>
                                    <option value="Badminton" <%= "Badminton".equals(formType) ? "selected" : "" %>>Cầu lông (Badminton)</option>
                                    <option value="Pickleball" <%= "Pickleball".equals(formType) ? "selected" : "" %>>Pickleball</option>
                                    <option value="Football" <%= "Football".equals(formType) ? "selected" : "" %>>Bóng đá (Football)</option>
                                </select>
                            </div>
                            <div>
                                <label for="pricePerHour">Giá thuê mỗi giờ (VNĐ)</label>
                                <input type="number" id="pricePerHour" name="pricePerHour" min="1" step="1"
                                       value="<%= esc(formPrice) %>">
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-primary"><%= editing ? "Lưu thay đổi" : "Thêm sân" %></button>
                            <% if (editing) { %>
                                <a class="btn-cancel" href="<%= url %><%= keyword.isEmpty() ? "" : "?keyword=" + keywordEncoded %>">Hủy sửa</a>
=======
            <%-- ============ THANH TÌM THEO TÊN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2>Tìm theo tên sân</h2></div>
                <div class="panel-body">
                    <form class="row" method="get" action="<%= url %>">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="keyword" maxlength="100" placeholder="Nhập tên sân"
                               value="<%= esc(searchKeyword) %>">
                        <button type="submit">Tìm</button>
                    </form>
                    <% if (searchKeyword != null) { %>
                        <p class="hint"><a href="<%= url %>">Hiện tất cả sân</a></p>
                    <% } %>
                </div>
            </section>

            <%-- ============ FORM THÊM / SỬA SÂN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2><%= editing ? "Sửa sân" : "Thêm sân mới" %></h2></div>
                <div class="panel-body">
                    <form method="post" action="<%= url %>">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "add" %>">
                        <input type="hidden" name="courtId" value="<%= editing ? esc(formId) : "" %>">

                        <label for="courtName">Tên sân</label>
                        <input type="text" id="courtName" name="courtName" maxlength="100"
                               value="<%= esc(formName) %>">

                        <label for="sportType">Loại sân</label>
                        <select id="sportType" name="sportType">
                            <option value="">-- Chọn loại sân --</option>
                            <option value="Badminton" <%= "Badminton".equals(formType) ? "selected" : "" %>>Cầu lông (Badminton)</option>
                            <option value="Pickleball" <%= "Pickleball".equals(formType) ? "selected" : "" %>>Pickleball</option>
                            <option value="Football" <%= "Football".equals(formType) ? "selected" : "" %>>Bóng đá (Football)</option>
                        </select>

                        <label for="pricePerHour">Giá thuê mỗi giờ (VNĐ)</label>
                        <input type="number" id="pricePerHour" name="pricePerHour" min="1" step="1"
                               value="<%= esc(formPrice) %>">

>>>>>>> feature/admin-courts
=======
>>>>>>> origin/feature/court-list-hung
                        <div class="actions">
                            <button type="submit"><%= editing ? "Lưu thay đổi" : "Thêm sân" %></button>
                            <% if (editing) { %>
                                <a class="btn btn-gray" href="<%= url %>">Hủy sửa</a>
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
>>>>>>> feature/admin-courts
=======
>>>>>>> origin/feature/court-list-hung
                            <% } %>
                        </div>
                    </form>
                </div>
<<<<<<< HEAD
<<<<<<< HEAD
            </section>

            <%-- ============ DANH SÁCH SÂN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2>Danh sách sân</h2></div>
                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Tên sân</th>
                            <th>Loại</th>
                            <th>Giá/giờ (VNĐ)</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>

                        <% if (courts == null || courts.isEmpty()) { %>
                            <tr><td colspan="6" class="empty">Chưa có sân nào.</td></tr>
                        <% } else { %>
                            <% for (Court c : courts) { %>
                                <tr>
                                    <td>#<%= c.getCourtId() %></td>
                                    <td><b><%= esc(c.getCourtName()) %></b></td>
                                    <td><%= esc(c.getSportType()) %></td>
                                    <td><b><%= money.format(c.getPricePerHour()) %> đ</b></td>
                                    <td>
                                        <% if (c.isActive()) { %>
                                            <span class="tag on">Hoạt động</span>
                                        <% } else { %>
                                            <span class="tag off">Ngừng hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="cell-actions">
                                            <%-- Nút Sửa --%>
                                            <a class="btn btn-sm btn-orange"
                                               href="<%= url %>?action=edit&id=<%= c.getCourtId() %>">Sửa</a>

                                            <%-- Nút Ngừng hoạt động / Kích hoạt lại --%>
                                            <form class="inline" method="post" action="<%= url %>">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                                <%-- gửi giá trị ngược với trạng thái hiện tại --%>
                                                <input type="hidden" name="active" value="<%= !c.isActive() %>">
                                                <% if (c.isActive()) { %>
                                                    <button type="submit" class="btn-sm btn-red"
                                                            onclick="return confirm('Ngừng hoạt động sân này?');">Ngừng</button>
                                                <% } else { %>
                                                    <button type="submit" class="btn-sm btn-green">Kích hoạt</button>
                                                <% } %>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </table>
                </div>
            </section>
=======
<<<<<<< Updated upstream
            </div>

            <%-- ============ DANH SÁCH SÂN ============ --%>
            <div class="card">
                <div class="card-head">
                    <h2>Danh sách sân</h2>
                    <span class="muted">Hiển thị <%= shown %> / <%= total %> sân</span>
                </div>

                <%-- ===== 2 thanh: tìm theo tên sân | xóa theo ID ===== --%>
                <div class="toolbar">
                    <%-- Thanh 1: tìm sân theo tên --%>
                    <form method="get" action="<%= url %>">
                        <input type="text" name="keyword" maxlength="100" placeholder="Tìm theo tên sân..."
                               value="<%= esc(keyword) %>">
                        <button type="submit" class="btn-search">Tìm</button>
                        <% if (!keyword.isEmpty()) { %>
                            <a class="btn-clear" href="<%= url %>">Xóa lọc</a>
                        <% } %>
                    </form>

                    <%-- Thanh 2: nhập ID để xóa sân (không thấy ID thì báo lỗi) --%>
                    <form method="post" action="<%= url %>"
                          onsubmit="return confirm('Xóa sân có ID này cùng các lượt đặt của sân? Không thể hoàn tác.');">
                        <input type="hidden" name="action" value="deleteById">
                        <input type="hidden" name="keyword" value="<%= esc(keyword) %>">
                        <input type="number" name="deleteId" min="1" step="1" placeholder="Nhập ID sân cần xóa...">
                        <button type="submit" class="btn-danger">Xóa theo ID</button>
                    </form>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>Mã</th>
                            <th>Sân</th>
                            <th>Giá/giờ</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>

                        <% if (courts == null || courts.isEmpty()) { %>
                            <tr><td colspan="5" class="empty">
                                <% if (keyword.isEmpty()) { %>
                                    Chưa có sân nào.
                                <% } else { %>
                                    Không tìm thấy sân nào có tên chứa "<%= esc(keyword) %>".
                                <% } %>
                            </td></tr>
                        <% } else { %>
                            <% for (Court c : courts) { %>
                                <tr>
                                    <td>#<%= c.getCourtId() %></td>
                                    <td>
                                        <div class="name"><%= esc(c.getCourtName()) %></div>
                                        <div class="sub"><%= esc(c.getSportType()) %></div>
                                    </td>
                                    <td class="price"><%= money.format(c.getPricePerHour()) %> đ</td>
                                    <td>
                                        <% if (c.isActive()) { %>
                                            <span class="pill on">Hoạt động</span>
                                        <% } else { %>
                                            <span class="pill off">Ngừng hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td class="actions-cell">
                                        <%-- Nút Sửa --%>
                                        <a class="act act-edit" href="<%= url %>?action=edit&id=<%= c.getCourtId() %><%= keyword.isEmpty() ? "" : "&keyword=" + keywordEncoded %>">Sửa</a>

                                        <%-- Nút Ngừng hoạt động / Kích hoạt lại --%>
                                        <form class="inline" method="post" action="<%= url %>">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                            <input type="hidden" name="keyword" value="<%= esc(keyword) %>">
                                            <%-- gửi giá trị ngược với trạng thái hiện tại --%>
                                            <input type="hidden" name="active" value="<%= !c.isActive() %>">
                                            <% if (c.isActive()) { %>
                                                <button type="submit" class="act act-stop"
                                                        onclick="return confirm('Ngừng hoạt động sân này?');">Ngừng</button>
                                            <% } else { %>
                                                <button type="submit" class="act act-start">Kích hoạt</button>
                                            <% } %>
                                        </form>

                                        <%-- Nút Xóa: xóa sân (kèm các lượt đặt của sân đó) --%>
                                        <form class="inline" method="post" action="<%= url %>">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                            <input type="hidden" name="keyword" value="<%= esc(keyword) %>">
                                            <button type="submit" class="act act-delete"
                                                    onclick="return confirm('Xóa sân này cùng các lượt đặt của sân? Không thể hoàn tác.');">Xóa</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </table>
                </div>
            </div>
=======
            </section>

            <%-- ============ DANH SÁCH SÂN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2>Danh sách sân</h2></div>
                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Tên sân</th>
                            <th>Loại</th>
                            <th>Giá/giờ (VNĐ)</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>

                        <% if (courts == null || courts.isEmpty()) { %>
                            <tr><td colspan="6" class="empty">Chưa có sân nào.</td></tr>
                        <% } else { %>
                            <% for (Court c : courts) { %>
                                <tr>
                                    <td>#<%= c.getCourtId() %></td>
                                    <td><b><%= esc(c.getCourtName()) %></b></td>
                                    <td><%= esc(c.getSportType()) %></td>
                                    <td><b><%= money.format(c.getPricePerHour()) %> đ</b></td>
                                    <td>
                                        <% if (c.isActive()) { %>
                                            <span class="tag on">Hoạt động</span>
                                        <% } else { %>
                                            <span class="tag off">Ngừng hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="cell-actions">
                                            <%-- Nút Sửa --%>
                                            <a class="btn btn-sm btn-orange"
                                               href="<%= url %>?action=edit&id=<%= c.getCourtId() %>">Sửa</a>

                                            <%-- Nút Ngừng hoạt động / Kích hoạt lại --%>
                                            <form class="inline" method="post" action="<%= url %>">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                                <%-- gửi giá trị ngược với trạng thái hiện tại --%>
                                                <input type="hidden" name="active" value="<%= !c.isActive() %>">
                                                <% if (c.isActive()) { %>
                                                    <button type="submit" class="btn-sm btn-red"
                                                            onclick="return confirm('Ngừng hoạt động sân này?');">Ngừng</button>
                                                <% } else { %>
                                                    <button type="submit" class="btn-sm btn-green">Kích hoạt</button>
                                                <% } %>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </table>
                </div>
            </section>
>>>>>>> Stashed changes
>>>>>>> feature/admin-courts
=======
            </section>

            <%-- ============ DANH SÁCH SÂN ============ --%>
            <section class="panel">
                <div class="panel-head"><h2>Danh sách sân</h2></div>
                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Tên sân</th>
                            <th>Loại</th>
                            <th>Giá/giờ (VNĐ)</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>

                        <% if (courts == null || courts.isEmpty()) { %>
                            <tr><td colspan="6" class="empty">Chưa có sân nào.</td></tr>
                        <% } else { %>
                            <% for (Court c : courts) { %>
                                <tr>
                                    <td>#<%= c.getCourtId() %></td>
                                    <td><b><%= esc(c.getCourtName()) %></b></td>
                                    <td><%= esc(c.getSportType()) %></td>
                                    <td><b><%= money.format(c.getPricePerHour()) %> đ</b></td>
                                    <td>
                                        <% if (c.isActive()) { %>
                                            <span class="tag on">Hoạt động</span>
                                        <% } else { %>
                                            <span class="tag off">Ngừng hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="cell-actions">
                                            <%-- Nút Sửa --%>
                                            <a class="btn btn-sm btn-orange"
                                               href="<%= url %>?action=edit&id=<%= c.getCourtId() %>">Sửa</a>

                                            <%-- Nút Ngừng hoạt động / Kích hoạt lại --%>
                                            <form class="inline" method="post" action="<%= url %>">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                                <%-- gửi giá trị ngược với trạng thái hiện tại --%>
                                                <input type="hidden" name="active" value="<%= !c.isActive() %>">
                                                <% if (c.isActive()) { %>
                                                    <button type="submit" class="btn-sm btn-red"
                                                            onclick="return confirm('Ngừng hoạt động sân này?');">Ngừng</button>
                                                <% } else { %>
                                                    <button type="submit" class="btn-sm btn-green">Kích hoạt</button>
                                                <% } %>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </table>
                </div>
            </section>
>>>>>>> origin/feature/court-list-hung
        </main>
    </body>
</html>