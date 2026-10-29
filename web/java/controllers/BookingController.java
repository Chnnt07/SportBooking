package controllers;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import models.Court;

/**
 * Đặt sân (khách hàng).
 *   GET  /BookingController?courtId=..&date=..   form đặt sân + các giờ đã có người đặt
 *   POST /BookingController                      tạo booking, thành công thì chuyển sang /MyBookingController
 * Việc đăng nhập đã được AuthFilter kiểm tra; session có "userID".
 */
@WebServlet(name = "BookingController", urlPatterns = {"/BookingController"})
public class BookingController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/booking.jsp";

    private static Integer parseInt(String v) {
        try {
            return Integer.valueOf(v.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static LocalDate parseDate(String v) {
        try {
            return LocalDate.parse(v.trim());
        } catch (DateTimeException | NullPointerException e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer courtId = parseInt(request.getParameter("courtId"));
        LocalDate date = parseDate(request.getParameter("date"));
        loadForm(request, courtId, date, request.getParameter("start"), request.getParameter("end"));
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Object uid = request.getSession().getAttribute("userID");
        Integer courtId = parseInt(request.getParameter("courtId"));
        LocalDate date = parseDate(request.getParameter("date"));
        String startStr = request.getParameter("start");
        String endStr = request.getParameter("end");
        Integer startMin = BookingDAO.parseMinutes(startStr);
        Integer endMin = BookingDAO.parseMinutes(endStr);

        String error;
        if (!(uid instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        } else if (courtId == null || date == null || startMin == null || endMin == null) {
            error = "Vui lòng chọn sân, ngày, giờ bắt đầu và giờ kết thúc hợp lệ.";
        } else {
            BookingDAO.Result result = new BookingDAO()
                    .createBooking((Integer) uid, courtId, date, startMin, endMin);
            switch (result) {
                case OK:
                    request.getSession().setAttribute("flash",
                            "Đặt sân thành công! Đơn đang chờ Admin xác nhận.");
                    response.sendRedirect(request.getContextPath() + "/MyBookingController");
                    return;
                case OVERLAP:
                    error = "Khoảng giờ này đã có người đặt (trùng một phần hoặc toàn bộ). "
                            + "Xem các giờ đã đặt bên dưới và chọn giờ khác.";
                    break;
                case PAST:
                    error = "Không thể đặt giờ đã qua.";
                    break;
                case COURT_UNAVAILABLE:
                    error = "Sân không tồn tại hoặc đã ngừng hoạt động.";
                    break;
                case INVALID_TIME:
                    error = "Giờ không hợp lệ: sân mở 05:00 - 24:00, chọn theo bước 15 phút, "
                            + "đặt tối thiểu 30 phút và giờ kết thúc phải sau giờ bắt đầu.";
                    break;
                default:
                    error = "Có lỗi hệ thống, vui lòng thử lại.";
            }
        }
        request.setAttribute("error", error);
        loadForm(request, courtId, date, startStr, endStr);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /** Nạp dữ liệu cho booking.jsp: danh sách sân, giờ đã đặt, các giờ có thể chọn. */
    private void loadForm(HttpServletRequest request, Integer courtId, LocalDate date,
            String start, String end) throws ServletException {
        try {
            BookingDAO dao = new BookingDAO();
            request.setAttribute("courts", dao.getActiveCourts());
            request.setAttribute("today", LocalDate.now().toString());
            request.setAttribute("selectedCourtId", courtId);
            request.setAttribute("selectedDate", date == null ? null : date.toString());
            request.setAttribute("selectedStart", start);
            request.setAttribute("selectedEnd", end);
            if (courtId == null || date == null || date.isBefore(LocalDate.now())) {
                return;
            }
            Court court = dao.findActiveCourt(courtId);
            if (court == null) {
                return;
            }
            request.setAttribute("court", court);
            request.setAttribute("busy", dao.getBusyRanges(courtId, date));

            // Các giờ để chọn (bước 15 phút). Nếu là hôm nay thì bỏ các giờ đã qua.
            LocalDateTime now = LocalDateTime.now();
            int nowMin = now.getHour() * 60 + now.getMinute();
            boolean today = date.equals(LocalDate.now());
            List<String> startOptions = new ArrayList<>();
            List<String> endOptions = new ArrayList<>();
            for (int m = BookingDAO.OPEN_MIN; m <= BookingDAO.CLOSE_MIN; m += BookingDAO.STEP_MIN) {
                if (m < BookingDAO.CLOSE_MIN && (!today || m > nowMin)) {
                    startOptions.add(BookingDAO.formatMinutes(m));
                }
                if (m > BookingDAO.OPEN_MIN) {
                    endOptions.add(BookingDAO.formatMinutes(m));
                }
            }
            request.setAttribute("startOptions", startOptions);
            request.setAttribute("endOptions", endOptions);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
