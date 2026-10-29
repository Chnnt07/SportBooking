package controllers;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Lịch đặt sân của chính khách đang đăng nhập.
 *   GET  /MyBookingController   danh sách lịch sử
 *   POST /MyBookingController   hủy một booking của mình (tham số bookingId)
 */
@WebServlet(name = "MyBookingController", urlPatterns = {"/MyBookingController"})
public class MyBookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object uid = session.getAttribute("userID");
        if (!(uid instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // flash: thông báo hiển thị một lần sau khi đặt/hủy
        request.setAttribute("flash", session.getAttribute("flash"));
        session.removeAttribute("flash");
        try {
            request.setAttribute("bookings", new BookingDAO().getBookingsByUser((Integer) uid));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object uid = session.getAttribute("userID");
        if (!(uid instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        boolean ok = false;
        try {
            int id = Integer.parseInt(request.getParameter("bookingId"));
            ok = new BookingDAO().cancelMyBooking(id, (Integer) uid);
        } catch (NumberFormatException e) {
            // id sai -> ok = false
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        session.setAttribute("flash", ok
                ? "Đã hủy lịch đặt."
                : "Không thể hủy: lịch không tồn tại, đã hủy hoặc đã đến giờ chơi.");
        response.sendRedirect(request.getContextPath() + "/MyBookingController");
    }
}
