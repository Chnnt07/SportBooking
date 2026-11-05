
package controllers;

import dao.AdminBookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

public class AdminBookingController extends HttpServlet {

    private final AdminBookingDAO bookingDAO =
            new AdminBookingDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");

        if (status == null || status.isBlank()) {
            status = "ALL";
        }

        // Accept only the filter options used by the admin JSP.
        if (!"ALL".equalsIgnoreCase(status)
                && !"Pending".equalsIgnoreCase(status)
                && !"Confirmed".equalsIgnoreCase(status)
                && !"Cancelled".equalsIgnoreCase(status)) {
            status = "ALL";
        }

        try {
            request.setAttribute("selectedStatus", status);

            request.setAttribute(
                    "bookings",
                    bookingDAO.findAll(status)
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/bookings.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Failed to load bookings", e
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String id = request.getParameter("bookingId");
        String statusFilter = request.getParameter("status");

        if (id == null
                || (!"confirm".equals(action)
                && !"cancel".equals(action))) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        // Keep the filter value safe and predictable.
        if (!"ALL".equalsIgnoreCase(statusFilter)
                && !"Pending".equalsIgnoreCase(statusFilter)
                && !"Confirmed".equalsIgnoreCase(statusFilter)
                && !"Cancelled".equalsIgnoreCase(statusFilter)) {
            statusFilter = "ALL";
        }

        try {
            int bookingId = Integer.parseInt(id);

            if (bookingId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST
                );
                return;
            }

            String newStatus = "confirm".equals(action)
                    ? "Confirmed"
                    : "Cancelled";

            boolean updated = bookingDAO.updateStatus(
                    bookingId, newStatus
            );

            if (!updated) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND
                );
                return;
            }

            String redirectURL = request.getContextPath()
                    + "/AdminBookingController"
                    + "?status="
                    + URLEncoder.encode(
                            statusFilter,
                            StandardCharsets.UTF_8
                    );

            response.sendRedirect(redirectURL);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
        } catch (SQLException e) {
            throw new ServletException(
                    "Failed to update booking", e
            );
        }
    }
}
