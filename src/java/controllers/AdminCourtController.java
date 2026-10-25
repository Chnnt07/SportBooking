package controllers;

import dao.AdminCourtDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import models.Court;

/**
 * Admin quản lý sân: xem danh sách, tìm theo tên, thêm, sửa, ngừng hoạt động / kích hoạt lại, xóa.
 * URL được ánh xạ trong web.xml (không dùng @WebServlet): /AdminCourtController
 *
 * GET  /AdminCourtController                  -> hiện danh sách + form thêm sân
 * GET  /AdminCourtController?action=edit&id=3 -> hiện danh sách + form sửa sân số 3
 * POST action=add                             -> thêm sân
 * POST action=update                          -> sửa sân
 * GET  ...?keyword=abc                        -> chỉ hiện các sân có tên chứa "abc"
 * POST action=toggle                          -> ngừng hoạt động / kích hoạt lại sân
 * POST action=delete                          -> xóa sân (nút Xóa ở từng dòng)
 * POST action=deleteById                      -> xóa sân theo ID gõ ở thanh "Xóa theo ID"
 *
 * Đăng nhập và quyền ADMIN do AuthFilter (khai báo trong web.xml) kiểm tra.
 */
public class AdminCourtController extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/admin/courts.jsp";
    private static final String URL = "/AdminCourtController";

    // Các loại sân hợp lệ (trùng với dữ liệu mẫu trong database)
    private static final List<String> SPORT_TYPES = Arrays.asList("Badminton", "Pickleball", "Football");

    // ===================== GET: hiện trang =====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

//        if (!isAdmin(request, response)) {
//            return;
//        }

        AdminCourtDAO dao = new AdminCourtDAO();
        try {
            // Bấm nút "Sửa" -> nạp thông tin sân vào form
            if ("edit".equals(request.getParameter("action"))) {
                int id = toInt(request.getParameter("id"));
                Court court = dao.getById(id);
                if (court == null) {
                    request.setAttribute("message", "Không tìm thấy sân cần sửa.");
                    request.setAttribute("messageType", "error");
                } else {
                    request.setAttribute("formId", court.getCourtId());
                    request.setAttribute("formName", court.getCourtName());
                    request.setAttribute("formType", court.getSportType());
                    request.setAttribute("formPrice",
                            court.getPricePerHour().stripTrailingZeros().toPlainString());
                }
            }
            showPage(request, response, dao);
        } finally {
            dao.close();
        }
    }

    // ===================== POST: xử lý thao tác =====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

//        if (!isAdmin(request, response)) {
//            return;
//        }

        request.setCharacterEncoding("UTF-8"); // để đọc đúng tiếng Việt có dấu
        String action = request.getParameter("action");

        AdminCourtDAO dao = new AdminCourtDAO();
        try {
            if ("add".equals(action) || "update".equals(action)) {
                saveCourt(request, response, dao, action);
            } else if ("toggle".equals(action)) {
                toggleCourt(request, response, dao);
            } else if ("delete".equals(action)) {
                deleteCourt(request, response, dao, toInt(request.getParameter("courtId")));
            } else if ("deleteById".equals(action)) {
                deleteById(request, response, dao);
            } else {
                response.sendRedirect(request.getContextPath() + URL);
            }
        } finally {
            dao.close();
        }
    }

    // ===================== Thêm / sửa sân =====================
    private void saveCourt(HttpServletRequest request, HttpServletResponse response,
                           AdminCourtDAO dao, String action) throws ServletException, IOException {

        int id = toInt(request.getParameter("courtId"));
        String name = clean(request.getParameter("courtName"));
        String type = clean(request.getParameter("sportType"));
        String priceText = clean(request.getParameter("pricePerHour"));

        // Bước 1: kiểm tra dữ liệu nhập
        String error = validate(name, type, priceText);
        if (error == null && dao.nameExists(name, id)) {
            error = "Tên sân \"" + name + "\" đã tồn tại.";
        }

        // Có lỗi -> hiện lại form kèm dữ liệu vừa nhập để người dùng sửa
        if (error != null) {
            request.setAttribute("formId", id == 0 ? "" : id);
            request.setAttribute("formName", name);
            request.setAttribute("formType", type);
            request.setAttribute("formPrice", priceText);
            request.setAttribute("message", error);
            request.setAttribute("messageType", "error");
            showPage(request, response, dao);
            return;
        }

        // Bước 2: lưu vào database
        BigDecimal price = new BigDecimal(priceText);
        boolean ok;
        String successMessage;
        if ("add".equals(action)) {
            ok = dao.insert(name, type, price);
            successMessage = "Đã thêm sân \"" + name + "\".";
        } else {
            ok = dao.update(id, name, type, price);
            successMessage = "Đã cập nhật sân \"" + name + "\".";
        }

        if (ok) {
            redirectWithMessage(request, response, successMessage, "success");
        } else {
            String reason = (dao.getLastError() != null) ? dao.getLastError() : "không tìm thấy sân.";
            redirectWithMessage(request, response, "Thao tác thất bại: " + reason, "error");
        }
    }

    // ===================== Ngừng hoạt động / kích hoạt lại =====================
    private void toggleCourt(HttpServletRequest request, HttpServletResponse response,
                             AdminCourtDAO dao) throws IOException {

        int id = toInt(request.getParameter("courtId"));
        boolean active = "true".equals(request.getParameter("active")); // true = kích hoạt, false = ngừng

        if (dao.setActive(id, active)) {
            String text = active ? "Đã kích hoạt lại sân." : "Đã ngừng hoạt động sân.";
            redirectWithMessage(request, response, text, "success");
        } else {
            redirectWithMessage(request, response, "Không tìm thấy sân.", "error");
        }
    }

    // ===================== Xóa sân =====================

    // Xóa theo ID gõ vào thanh "Xóa sân theo ID"
    private void deleteById(HttpServletRequest request, HttpServletResponse response,
                            AdminCourtDAO dao) throws IOException {
        int id = toInt(clean(request.getParameter("deleteId")));
        if (id <= 0) {
            redirectWithMessage(request, response,
                    "Vui lòng nhập ID sân hợp lệ (số nguyên dương).", "error");
            return;
        }
        deleteCourt(request, response, dao, id);
    }

    // Xóa sân (dùng chung cho nút "Xóa" ở từng dòng và thanh xóa theo ID)
    private void deleteCourt(HttpServletRequest request, HttpServletResponse response,
                             AdminCourtDAO dao, int id) throws IOException {

        // Bước 1: sân có tồn tại không?
        Court court = dao.getById(id);
        if (court == null) {
            String text = (dao.getLastError() != null)
                    ? "Thao tác thất bại: " + dao.getLastError()
                    : "Không tìm thấy sân có ID = " + id + ".";
            redirectWithMessage(request, response, text, "error");
            return;
        }

        // Bước 2: xóa sân (kèm các booking của sân đó)
        int deletedBookings = dao.deleteCourt(id);
        if (deletedBookings < 0) {
            redirectWithMessage(request, response,
                    "Thao tác thất bại: " + dao.getLastError(), "error");
            return;
        }

        String text = "Đã xóa sân \"" + court.getCourtName() + "\" (ID " + id + ")";
        if (deletedBookings > 0) {
            text += " cùng " + deletedBookings + " lượt đặt của sân này";
        }
        redirectWithMessage(request, response, text + ".", "success");
    }

    // ===================== Các hàm hỗ trợ =====================

    // Chỉ cho Admin đã đăng nhập vào. Session do AuthController lưu: "userID" và "role".
//    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
//            throws IOException {
//        HttpSession session = request.getSession(false);
//
//        if (session == null || session.getAttribute("userID") == null) {
//            response.sendRedirect(request.getContextPath() + "/login"); // chưa đăng nhập
//            return false;
//        }
//        if (!"ADMIN".equals(session.getAttribute("role"))) {
//            response.sendError(HttpServletResponse.SC_FORBIDDEN);       // không phải Admin
//            return false;
//        }
//        return true;
//    }

    // Kiểm tra dữ liệu nhập. Trả về câu báo lỗi, hoặc null nếu mọi thứ hợp lệ.
    private String validate(String name, String type, String priceText) {
        if (name.isEmpty()) {
            return "Vui lòng nhập tên sân.";
        }
        if (name.length() > 100) {
            return "Tên sân tối đa 100 ký tự.";
        }
        if (!SPORT_TYPES.contains(type)) {
            return "Vui lòng chọn loại sân hợp lệ.";
        }
        if (priceText.isEmpty()) {
            return "Vui lòng nhập giá thuê.";
        }

        BigDecimal price;
        try {
            price = new BigDecimal(priceText);
        } catch (NumberFormatException e) {
            return "Giá thuê phải là một số (ví dụ: 80000).";
        }
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            return "Giá thuê phải lớn hơn 0.";
        }
        if (price.stripTrailingZeros().scale() > 0) {
            return "Giá thuê phải là số nguyên (đơn vị VNĐ).";
        }
        if (price.compareTo(new BigDecimal("1000000000")) > 0) {
            return "Giá thuê tối đa là 1.000.000.000 VNĐ.";
        }
        return null; // hợp lệ
    }

    // Nạp danh sách sân rồi chuyển sang trang JSP
    private void showPage(HttpServletRequest request, HttpServletResponse response,
                          AdminCourtDAO dao) throws ServletException, IOException {

        // Lấy thông báo được lưu từ lần thao tác trước (nếu có), hiện xong thì xóa đi
        HttpSession session = request.getSession();
        Object message = session.getAttribute("flashMessage");
        if (message != null) {
            request.setAttribute("message", message);
            request.setAttribute("messageType", session.getAttribute("flashType"));
            session.removeAttribute("flashMessage");
            session.removeAttribute("flashType");
        }

        // Thanh tìm theo tên: có từ khóa thì chỉ hiện các sân khớp tên, không thì hiện tất cả
        String keyword = clean(request.getParameter("keyword"));
        List<Court> allCourts = dao.getAll();
        request.setAttribute("allCourts", allCourts);   // dùng cho các thẻ thống kê
        request.setAttribute("keyword", keyword);
        request.setAttribute("courts", keyword.isEmpty() ? allCourts : dao.search(keyword));

        // Nếu lấy dữ liệu lỗi (mất kết nối, sai tên database...) thì báo lỗi ngay trên trang
        if (dao.getLastError() != null) {
            request.setAttribute("message", "Lỗi database: " + dao.getLastError());
            request.setAttribute("messageType", "error");
        }
        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    // Lưu thông báo vào session rồi chuyển hướng về trang danh sách
    // (tránh lỗi gửi lại form khi người dùng nhấn F5)
    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response,
                                     String message, String type) throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("flashMessage", message);
        session.setAttribute("flashType", type);

        // Giữ nguyên từ khóa đang tìm để danh sách không bị mất bộ lọc sau khi thao tác
        String keyword = clean(request.getParameter("keyword"));
        String target = request.getContextPath() + URL;
        if (!keyword.isEmpty()) {
            target += "?keyword=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8);
        }
        response.sendRedirect(target);
    }

    // Đổi chuỗi sang số nguyên, sai định dạng thì trả về 0
    private int toInt(String text) {
        try {
            return Integer.parseInt(text);
        } catch (Exception e) {
            return 0;
        }
    }

    // Bỏ khoảng trắng đầu/cuối; null thì thành chuỗi rỗng
    private String clean(String text) {
        return text == null ? "" : text.trim();
    }

    @Override
    public String getServletInfo() {
        return "Admin court management";
    }
}
