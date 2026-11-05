<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1"><title>Đăng nhập | SportBooking</title>
        <style>*{box-sizing:border-box}body{margin:0;min-height:100vh;font-family:Arial,sans-serif;background:linear-gradient(135deg,#4f46e5,#7c3aed);display:grid;place-items:center}.box{width:min(420px,92%);background:#fff;border-radius:20px;padding:38px;box-shadow:0 20px 60px #21145c55}.logo{font-size:25px;font-weight:800;color:#5548dc;margin-bottom:8px}.logo span{color:#f59e0b}h1{margin:0 0 8px;color:#172033;font-size:27px}p{color:#718096}.msg{padding:11px;border-radius:8px;background:#fee2e2;color:#b91c1c}.field{margin:18px 0}.field label{display:block;margin-bottom:7px;font-size:13px;font-weight:bold;color:#475569}.field input{width:100%;padding:13px;border:1px solid #dbe1ec;border-radius:9px;font-size:15px}.field input:focus{outline:2px solid #c7d2fe;border-color:#6366f1}.submit{width:100%;padding:13px;border:0;border-radius:9px;background:#5b5ce2;color:#fff;font-size:15px;font-weight:bold;cursor:pointer}.register{text-align:center;font-size:14px}.register a{color:#4f46e5;font-weight:bold;text-decoration:none}</style>
    </head>
    <body>
        <main class="box"><div class="logo">Sport<span>Booking</span></div><h1>Chào mừng trở lại</h1><p>Đăng nhập để quản lý lịch đặt sân của bạn.</p>
        
            <% if (request.getAttribute("error") != null) { %>
                <p class="msg"><%=esc(request.getAttribute("error"))%></p>
            <% } %>
            <% if (request.getAttribute("message") != null) { %>
                <p style="color:#15803d;background:#dcfce7;padding:11px;border-radius:8px"><%=esc(request.getAttribute("message"))%></p>
            <% } %>

            
            <form action="${pageContext.request.contextPath}/login" method="post">

                <input type="hidden" name="action" value="login">

                <div class="field"><label for="username">Tên đăng nhập</label>
                <input id="username" type="text" name="username"
                       maxlength="50" required>
                </div>

                <div class="field"><label for="password">Mật khẩu</label>
                <input id="password" type="password" name="password" required>
                </div>

                <button class="submit" type="submit">Đăng nhập</button>
            </form>

            <p class="register">
                Chưa có tài khoản?
                <a href="${pageContext.request.contextPath}/register">
                    Đăng ký ngay
                </a>
            </p></main>
    </body>
</html>
