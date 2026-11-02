<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
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
    // ---- Lấy dữ liệu do AdminCourtServlet gửi sang ----
    String url = request.getContextPath() + "/AdminCourtController";

    List<Court> courts = (List<Court>) request.getAttribute("courts");
    String searchKeyword = (String) request.getAttribute("searchKeyword");    // chữ đã tìm (nếu có)
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");

    // Dữ liệu của form (rỗng khi đang thêm mới, có giá trị khi đang sửa)
    Object formId = request.getAttribute("formId");
    Object formName = request.getAttribute("formName");
    Object formType = request.getAttribute("formType");
    Object formPrice = request.getAttribute("formPrice");

    // formId có giá trị -> đang sửa; không có -> đang thêm mới
    boolean editing = (formId != null && !formId.toString().isEmpty());

    DecimalFormat money = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        <header class="topbar">
            <div class="brand">Sport<span>Booking</span></div>
            <div class="profile">Khu vực quản trị · <b>Admin</b>
                <a class="btn nav-btn" href="<%= request.getContextPath() %>/AdminBookingController">&laquo; Quay lại lịch đặt</a>
            </div>
        </header>

        <main class="wrap">
            <div class="eyebrow">Admin dashboard</div>
            <h1 class="title">Quản lý sân</h1>

            <%-- Thông báo thành công / lỗi --%>
            <% if (message != null) { %>
                <div class="message <%= esc(messageType) %>"><%= esc(message) %></div>
            <% } %>

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

                        <div class="actions">
                            <button type="submit"><%= editing ? "Lưu thay đổi" : "Thêm sân" %></button>
                            <% if (editing) { %>
                                <a class="btn btn-gray" href="<%= url %>">Hủy sửa</a>
                            <% } %>
                        </div>
                    </form>
                </div>
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
        </main>
    </body>
</html>