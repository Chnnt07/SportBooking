package controllers;

import java.io.IOException;
import dao.AdminBookingDAO;
import java.util.List;
import models.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminBookingController", urlPatterns = {"/AdminBookingController"})
public class AdminBookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        try { List<Booking> bookings = new AdminBookingDAO().findAll(status); request.setAttribute("bookings", bookings); request.setAttribute("selectedStatus", status == null ? "ALL" : status); request.getRequestDispatcher("/WEB-INF/views/admin/bookings.jsp").forward(request, response); }
        catch (Exception e) { throw new ServletException("Cannot load bookings", e); }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try { int id = Integer.parseInt(request.getParameter("bookingId")); String newStatus = "confirm".equals(action) ? "Confirmed" : "cancel".equals(action) ? "Cancelled" : null; if (newStatus == null) { response.sendError(400); return; } new AdminBookingDAO().updateStatus(id, newStatus); response.sendRedirect(request.getContextPath() + "/AdminBookingController"); }
        catch (NumberFormatException e) { response.sendError(400, "Invalid booking id"); }
        catch (Exception e) { throw new ServletException("Cannot update booking", e); }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
