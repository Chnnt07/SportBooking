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
    Court deleteCourt = (Court) request.getAttribute("deleteCourt");          // sân đang chờ xác nhận xóa
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
        <title>Quản lý sân - Admin</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; background: #f4f6f8; color: #222; }
            .container { max-width: 900px; margin: 24px auto; padding: 0 16px; }
            h1 { margin-top: 0; }
            .box { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 20px;
                   box-shadow: 0 1px 3px rgba(0,0,0,.12); }
            .message { padding: 10px 14px; border-radius: 6px; margin-bottom: 16px; }
            .message.success { background: #e6f4ea; color: #1e6b34; border: 1px solid #b7dfc2; }
            .message.error { background: #fdecea; color: #a12622; border: 1px solid #f5c2be; }
            label { display: block; margin: 10px 0 4px; font-weight: bold; }
            input[type=text], input[type=number], select { width: 100%; padding: 8px; box-sizing: border-box;
                   border: 1px solid #bbb; border-radius: 4px; }
            button, .btn { display: inline-block; padding: 7px 14px; border: none; border-radius: 4px;
                   cursor: pointer; font-size: 14px; text-decoration: none; color: #fff; background: #1a73e8; }
            .btn-gray { background: #777; }
            .btn-orange { background: #e8710a; }
            .btn-green { background: #188038; }
            .btn-red { background: #d93025; }
            .message.warn { background: #fff4e5; color: #8a4b00; border: 1px solid #f5d4a6; }
            .tools { display: flex; gap: 16px; flex-wrap: wrap; }
            .tools .box { flex: 1; min-width: 280px; margin-bottom: 20px; }
            .tools h2 { margin-top: 0; font-size: 18px; }
            .row { display: flex; gap: 8px; }
            .row input { flex: 1; }
            .actions { margin-top: 14px; }
            table { width: 100%; border-collapse: collapse; }
            th, td { padding: 10px; border-bottom: 1px solid #e3e3e3; text-align: left; }
            th { background: #eef1f5; }
            .status-on { color: #188038; font-weight: bold; }
            .status-off { color: #d93025; font-weight: bold; }
            form.inline { display: inline; }
        </style>
    </head>
    <body>
        <div class="container">
            <p><a class="btn btn-gray" href="<%= request.getContextPath() %>/AdminBookingController">&laquo; Quay lại lịch đặt</a></p>
            <h1>Quản lý sân</h1>

            <%-- Thông báo thành công / lỗi --%>
            <% if (message != null) { %>
                <div class="message <%= esc(messageType) %>"><%= esc(message) %></div>
            <% } %>

            <%-- ============ HỎI XÁC NHẬN XÓA (chỉ hiện khi id tồn tại) ============ --%>
            <% if (deleteCourt != null) { %>
                <div class="message warn">
                    <b>Bạn có chắc muốn xóa sân này không?</b><br>
                    ID: <%= deleteCourt.getCourtId() %> -
                    <%= esc(deleteCourt.getCourtName()) %>
                    (<%= esc(deleteCourt.getSportType()) %>)
                    <form class="inline" method="post" action="<%= url %>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="courtId" value="<%= deleteCourt.getCourtId() %>">
                        <button type="submit" class="btn-red">Xóa</button>
                    </form>
                    <a class="btn btn-gray" href="<%= url %>">Không xóa</a>
                </div>
            <% } %>

            <%-- ============ HAI THANH: TÌM THEO TÊN / XÓA THEO ID ============ --%>
            <div class="tools">
                <div class="box">
                    <h2>Tìm theo tên sân</h2>
                    <form class="row" method="get" action="<%= url %>">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="keyword" maxlength="100" placeholder="Nhập tên sân"
                               value="<%= esc(searchKeyword) %>">
                        <button type="submit">Tìm</button>
                    </form>
                    <% if (searchKeyword != null) { %>
                        <p><a href="<%= url %>">Hiện tất cả sân</a></p>
                    <% } %>
                </div>

                <div class="box">
                    <h2>Xóa theo ID</h2>
                    <form class="row" method="get" action="<%= url %>">
                        <input type="hidden" name="action" value="deleteCheck">
                        <input type="number" name="id" min="1" placeholder="Nhập ID sân">
                        <button type="submit" class="btn-red">Xóa</button>
                    </form>
                </div>
            </div>

            <%-- ============ FORM THÊM / SỬA SÂN ============ --%>
            <div class="box">
                <h2><%= editing ? "Sửa sân" : "Thêm sân mới" %></h2>

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

            <%-- ============ DANH SÁCH SÂN ============ --%>
            <div class="box">
                <h2>Danh sách sân</h2>
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
                        <tr><td colspan="6">Chưa có sân nào.</td></tr>
                    <% } else { %>
                        <% for (Court c : courts) { %>
                            <tr>
                                <td><%= c.getCourtId() %></td>
                                <td><%= esc(c.getCourtName()) %></td>
                                <td><%= esc(c.getSportType()) %></td>
                                <td><%= money.format(c.getPricePerHour()) %></td>
                                <td>
                                    <% if (c.isActive()) { %>
                                        <span class="status-on">Hoạt động</span>
                                    <% } else { %>
                                        <span class="status-off">Ngừng hoạt động</span>
                                    <% } %>
                                </td>
                                <td>
                                    <%-- Nút Sửa --%>
                                    <a class="btn btn-orange"
                                       href="<%= url %>?action=edit&id=<%= c.getCourtId() %>">Sửa</a>

                                    <%-- Nút Ngừng hoạt động / Kích hoạt lại --%>
                                    <form class="inline" method="post" action="<%= url %>">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="courtId" value="<%= c.getCourtId() %>">
                                        <%-- gửi giá trị ngược với trạng thái hiện tại --%>
                                        <input type="hidden" name="active" value="<%= !c.isActive() %>">
                                        <% if (c.isActive()) { %>
                                            <button type="submit" class="btn-red"
                                                    onclick="return confirm('Ngừng hoạt động sân này?');">Ngừng</button>
                                        <% } else { %>
                                            <button type="submit" class="btn-green">Kích hoạt</button>
                                        <% } %>
                                    </form>

                                    <%-- Nút Xóa: kiểm tra rồi hỏi xác nhận (cùng cách với thanh "Xóa theo ID") --%>
                                    <a class="btn btn-red"
                                       href="<%= url %>?action=deleteCheck&id=<%= c.getCourtId() %>">Xóa</a>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </table>
            </div>
        </div>
    </body>
</html>
