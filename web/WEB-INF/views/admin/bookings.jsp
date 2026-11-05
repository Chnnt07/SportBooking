<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.Booking"%>

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
    String url = request.getContextPath()
            + "/AdminBookingController";

    List<Booking> bookings =
            (List<Booking>) request.getAttribute("bookings");

    String selected =
            (String) request.getAttribute("selectedStatus");

    if (selected == null || selected.isEmpty()) {
        selected = "ALL";
    }

    int total = bookings == null ? 0 : bookings.size();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Quản lý lịch đặt - Admin</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            color: #182338;
            background: #f4f6fb;
        }

        .topbar {
            background: white;
            padding: 16px 5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            box-shadow: 0 2px 8px #0001;
        }

        .brand {
            font-size: 22px;
            font-weight: bold;
            color: #5b5ce2;
        }

        .brand span {
            color: #f59e0b;
        }

        .profile {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            color: #718096;
        }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 16px;
        }

        h1 {
            margin-bottom: 24px;
        }

        .summary {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .card, .panel {
            background: white;
            border-radius: 10px;
            padding: 18px;
            box-shadow: 0 2px 8px #0001;
        }

        .card {
            min-width: 160px;
        }

        .card small {
            color: #718096;
        }

        .card strong {
            display: block;
            font-size: 24px;
            margin-top: 8px;
        }

        .panel-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }

        select {
            padding: 9px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background: white;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 850px;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        th {
            background: #f7f8fc;
            color: #718096;
            font-size: 12px;
        }

        .sub {
            display: block;
            margin-top: 4px;
            color: #718096;
            font-size: 12px;
        }

        .tag {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            background: #fff4d6;
            color: #a16207;
            font-size: 12px;
            font-weight: bold;
        }

        .confirmed {
            background: #dcfce7;
            color: #15803d;
        }

        .cancelled {
            background: #fee2e2;
            color: #b91c1c;
        }

        button, .btn {
            display: inline-block;
            padding: 8px 11px;
            border: none;
            border-radius: 5px;
            color: white;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }

        .green {
            background: #16a34a;
        }

        .red, .logout {
            background: #dc2626;
        }

        .blue {
            background: #4f46e5;
        }

        .actions {
            white-space: nowrap;
        }

        .empty {
            text-align: center;
            padding: 25px;
            color: #718096;
        }

        @media (max-width: 600px) {
            .topbar {
                padding: 14px;
            }

            .brand {
                font-size: 18px;
            }

            .profile {
                gap: 6px;
                font-size: 13px;
            }

            .container {
                margin-top: 20px;
            }
        }
    </style>
</head>

<body>

    <!-- Header and navigation -->
    <header class="topbar">
        <div class="brand">Sport<span>Booking</span></div>

        <div class="profile">
            <b>Admin</b>

            <a class="btn blue"
               href="<%= request.getContextPath() %>/AdminCourtController">
                Manage Courts
            </a>

            <form method="post"
                  action="<%= request.getContextPath() %>/login">
                <input type="hidden" name="action" value="logout">
                <button type="submit" class="logout">Logout</button>
            </form>
        </div>
    </header>

    <main class="container">

        <h1>Quản lý lịch đặt</h1>

        <!-- Booking summary -->
        <div class="summary">
            <div class="card">
                <small>Số lịch đặt đang xem</small>
                <strong><%= total %></strong>
            </div>

            <div class="card">
                <small>Trạng thái lọc</small>
                <strong><%= esc(selected) %></strong>
            </div>
        </div>

        <!-- Booking table -->
        <section class="panel">

            <div class="panel-head">
                <h3>Danh sách lịch đặt</h3>

                <form method="get" action="<%= url %>">
                    <select name="status"
                            onchange="this.form.submit()">

                        <option value="ALL"
                            <%= "ALL".equalsIgnoreCase(selected)
                                    ? "selected" : "" %>>
                            Tất cả
                        </option>

                        <option value="Pending"
                            <%= "Pending".equalsIgnoreCase(selected)
                                    ? "selected" : "" %>>
                            Chờ xác nhận
                        </option>

                        <option value="Confirmed"
                            <%= "Confirmed".equalsIgnoreCase(selected)
                                    ? "selected" : "" %>>
                            Đã xác nhận
                        </option>

                        <option value="Cancelled"
                            <%= "Cancelled".equalsIgnoreCase(selected)
                                    ? "selected" : "" %>>
                            Đã hủy
                        </option>
                    </select>
                </form>
            </div>

            <div class="table-wrap">
                <table>
                    <tr>
                        <th>Mã</th>
                        <th>Khách hàng</th>
                        <th>Sân</th>
                        <th>Ngày</th>
                        <th>Thời gian</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>

                    <% if (bookings == null || bookings.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="empty">
                                Không có lịch đặt nào.
                            </td>
                        </tr>
                    <% } else { %>

                        <% for (Booking b : bookings) { %>
                            <tr>
                                <td>#<%= b.getBookingID() %></td>

                                <td>
                                    <b><%= esc(b.getFullName()) %></b>
                                    <span class="sub">
                                        <%= esc(b.getUsername()) %>
                                    </span>
                                </td>

                                <td>
                                    <b><%= esc(b.getCourtName()) %></b>
                                    <span class="sub">
                                        <%= esc(b.getSportType()) %>
                                    </span>
                                </td>

                                <td><%= esc(b.getBookingDate()) %></td>

                                <td>
                                    <%= esc(b.getStartTime()) %>
                                    -
                                    <%= esc(b.getEndTime()) %>
                                </td>

                                <td>
                                    <b>
                                        <%= String.format(
                                                "%,.0f",
                                                b.getTotalPrice()) %> đ
                                    </b>
                                </td>

                                <td>
                                    <span class="tag <%= b.getStatus() == null
                                            ? ""
                                            : b.getStatus().toLowerCase(
                                                    java.util.Locale.ROOT) %>">
                                        <%= esc(b.getStatus()) %>
                                    </span>
                                </td>

                                <td class="actions">
                                    <% if ("Pending".equalsIgnoreCase(
                                            b.getStatus())) { %>

                                        <!-- Confirm booking -->
                                        <form method="post" action="<%= url %>"
                                              style="display:inline">
                                            <input type="hidden"
                                                   name="bookingId"
                                                   value="<%= b.getBookingID() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="<%= esc(selected) %>">

                                            <button type="submit"
                                                    name="action"
                                                    value="confirm"
                                                    class="green">
                                                Xác nhận
                                            </button>
                                        </form>

                                        <!-- Cancel booking -->
                                        <form method="post" action="<%= url %>"
                                              style="display:inline">
                                            <input type="hidden"
                                                   name="bookingId"
                                                   value="<%= b.getBookingID() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="<%= esc(selected) %>">

                                            <button type="submit"
                                                    name="action"
                                                    value="cancel"
                                                    class="red"
                                                    onclick="return confirm('Hủy lịch đặt này?')">
                                                Hủy
                                            </button>
                                        </form>

                                    <% } else { %>
                                        -
                                    <% } %>
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
