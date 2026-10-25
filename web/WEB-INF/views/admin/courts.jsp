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
    // ---- Lấy dữ liệu do AdminCourtController gửi sang ----
    String url = request.getContextPath() + "/AdminCourtController";
    String backUrl = request.getContextPath() + "/AdminBookingController"; // nút quay lại

    List<Court> courts = (List<Court>) request.getAttribute("courts");          // danh sách đang hiện (đã lọc)
    List<Court> allCourts = (List<Court>) request.getAttribute("allCourts");    // tất cả sân (cho thẻ thống kê)

    // Từ khóa đang tìm theo tên sân (rỗng nếu không tìm)
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) {
        keyword = "";
    }
    String keywordEncoded = URLEncoder.encode(keyword, StandardCharsets.UTF_8); // dùng trong đường dẫn
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

            <%-- Thông báo thành công / lỗi --%>
            <% if (message != null) { %>
                <div class="message <%= esc(messageType) %>"><%= esc(message) %></div>
            <% } %>

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
                            <% } %>
                        </div>
                    </form>
                </div>
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
        </main>
    </body>
</html>
