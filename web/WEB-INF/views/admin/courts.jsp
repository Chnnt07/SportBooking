<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="models.Court"%>

<%!
    private String esc(Object value) {
        if (value == null) return "";

        return value.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String url = request.getContextPath() + "/AdminCourtController";

    List<Court> courts =
            (List<Court>) request.getAttribute("courts");

    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");

    Object formId = request.getAttribute("formId");
    Object formName = request.getAttribute("formName");
    Object formType = request.getAttribute("formType");
    Object formPrice = request.getAttribute("formPrice");

    boolean editing = formId != null
            && !formId.toString().isEmpty();

    DecimalFormat money = new DecimalFormat("#,##0");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý sân - Admin</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background: #f4f6f8;
            color: #222;
        }

        .container {
            max-width: 1000px;
            margin: 24px auto;
            padding: 0 16px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .nav-actions {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .box {
            background: white;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px #0002;
        }

        label {
            display: block;
            margin: 10px 0 4px;
            font-weight: bold;
        }

        input[type=text],
        input[type=number],
        select {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
            border: 1px solid #bbb;
            border-radius: 4px;
        }

        button, .btn {
            display: inline-block;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            color: white;
            background: #1a73e8;
        }

        .orange { background: #e8710a; }
        .green { background: #188038; }
        .red { background: #d93025; }
        .gray { background: #777; }

        .message {
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 16px;
        }

        .success {
            background: #e6f4ea;
            color: #1e6b34;
        }

        .error {
            background: #fdecea;
            color: #a12622;
        }

        .actions {
            margin-top: 14px;
        }

        .inline {
            display: inline;
        }

        .status-on {
            color: #188038;
            font-weight: bold;
        }

        .status-off {
            color: #d93025;
            font-weight: bold;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }

        th {
            background: #eef1f5;
        }

        @media (max-width: 600px) {
            .topbar {
                align-items: flex-start;
                flex-direction: column;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <!-- Page heading and navigation -->
    <div class="topbar">
        <h1>Quản lý sân</h1>

        <div class="nav-actions">
            <a class="btn"
               href="<%= request.getContextPath() %>/AdminBookingController">
                Manage Bookings
            </a>

            <form method="post"
                  action="<%= request.getContextPath() %>/login">
                <input type="hidden" name="action" value="logout">
                <button type="submit" class="red">Logout</button>
            </form>
        </div>
    </div>

    <!-- Success or error message -->
    <% if (message != null) { %>
        <div class="message <%= "success".equals(messageType)
                ? "success" : "error" %>">
            <%= esc(message) %>
        </div>
    <% } %>

    <!-- Add or edit court -->
    <div class="box">
        <h2><%= editing ? "Sửa sân" : "Thêm sân mới" %></h2>

        <form method="post" action="<%= url %>">
            <input type="hidden" name="action"
                   value="<%= editing ? "update" : "add" %>">

            <input type="hidden" name="courtId"
                   value="<%= editing ? esc(formId) : "" %>">

            <label for="courtName">Tên sân</label>
            <input type="text" id="courtName" name="courtName"
                   maxlength="100" required
                   value="<%= esc(formName) %>">

            <label for="sportType">Loại sân</label>
            <select id="sportType" name="sportType" required>
                <option value="">-- Chọn loại sân --</option>

                <option value="Badminton"
                    <%= "Badminton".equals(formType) ? "selected" : "" %>>
                    Cầu lông (Badminton)
                </option>

                <option value="Pickleball"
                    <%= "Pickleball".equals(formType) ? "selected" : "" %>>
                    Pickleball
                </option>

                <option value="Football"
                    <%= "Football".equals(formType) ? "selected" : "" %>>
                    Bóng đá (Football)
                </option>
            </select>

            <label for="pricePerHour">Giá thuê mỗi giờ (VNĐ)</label>
            <input type="number" id="pricePerHour"
                   name="pricePerHour" min="1" step="1"
                   required value="<%= esc(formPrice) %>">

            <div class="actions">
                <button type="submit">
                    <%= editing ? "Lưu thay đổi" : "Thêm sân" %>
                </button>

                <% if (editing) { %>
                    <a class="btn gray" href="<%= url %>">Hủy sửa</a>
                <% } %>
            </div>
        </form>
    </div>

    <!-- Court list -->
    <div class="box">
        <h2>Danh sách sân</h2>

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
                    <tr>
                        <td colspan="6">Chưa có sân nào.</td>
                    </tr>
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
                                    <span class="status-off">
                                        Ngừng hoạt động
                                    </span>
                                <% } %>
                            </td>

                            <td>
                                <a class="btn orange"
                                   href="<%= url %>?action=edit&id=<%= c.getCourtId() %>">
                                    Sửa
                                </a>

                                <form class="inline" method="post"
                                      action="<%= url %>">
                                    <input type="hidden" name="action"
                                           value="toggle">

                                    <input type="hidden" name="courtId"
                                           value="<%= c.getCourtId() %>">

                                    <input type="hidden" name="active"
                                           value="<%= !c.isActive() %>">

                                    <% if (c.isActive()) { %>
                                        <button type="submit" class="red"
                                                onclick="return confirm('Ngừng hoạt động sân này?');">
                                            Ngừng
                                        </button>
                                    <% } else { %>
                                        <button type="submit" class="green">
                                            Kích hoạt
                                        </button>
                                    <% } %>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
            </table>
        </div>
    </div>

</div>
</body>
</html>
