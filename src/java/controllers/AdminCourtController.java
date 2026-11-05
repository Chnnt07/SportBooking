
package controllers;

import dao.AdminCourtDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import models.Court;

public class AdminCourtController extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/admin/courts.jsp";

    private static final String URL =
            "/AdminCourtController";

    private static final List<String> SPORT_TYPES =
            Arrays.asList(
                    "Badminton",
                    "Pickleball",
                    "Football"
            );

    // Display the court management page.
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) {
            return;
        }

        AdminCourtDAO dao = new AdminCourtDAO();

        try {
            if ("edit".equals(request.getParameter("action"))) {
                int id = toInt(request.getParameter("id"));

                Court court = dao.getById(id);

                if (court == null) {
                    request.setAttribute(
                            "message",
                            "Court not found."
                    );
                    request.setAttribute(
                            "messageType",
                            "error"
                    );
                } else {
                    request.setAttribute(
                            "formId", court.getCourtId()
                    );
                    request.setAttribute(
                            "formName", court.getCourtName()
                    );
                    request.setAttribute(
                            "formType", court.getSportType()
                    );
                    request.setAttribute(
                            "formPrice",
                            court.getPricePerHour()
                                    .stripTrailingZeros()
                                    .toPlainString()
                    );
                }
            }

            showPage(request, response, dao);

        } finally {
            dao.close();
        }
    }

    // Handle add, update, and activate/deactivate actions.
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        AdminCourtDAO dao = new AdminCourtDAO();

        try {
            if ("add".equals(action)
                    || "update".equals(action)) {

                saveCourt(request, response, dao, action);

            } else if ("toggle".equals(action)) {

                toggleCourt(request, response, dao);

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST
                );
            }

        } finally {
            dao.close();
        }
    }

    // Add a new court or update an existing court.
    private void saveCourt(HttpServletRequest request,
                           HttpServletResponse response,
                           AdminCourtDAO dao,
                           String action)
            throws ServletException, IOException {

        int id = toInt(request.getParameter("courtId"));

        String name = clean(
                request.getParameter("courtName")
        );

        String type = clean(
                request.getParameter("sportType")
        );

        String priceText = clean(
                request.getParameter("pricePerHour")
        );

        String error = validate(name, type, priceText);

        if (error == null && "update".equals(action) && id <= 0) {
            error = "Invalid court ID.";
        }

        if (error == null && dao.nameExists(name, id)) {
            error = "Court name \"" + name
                    + "\" already exists.";
        }

        if (error != null) {
            request.setAttribute(
                    "formId", id == 0 ? "" : id
            );
            request.setAttribute("formName", name);
            request.setAttribute("formType", type);
            request.setAttribute("formPrice", priceText);
            request.setAttribute("message", error);
            request.setAttribute("messageType", "error");

            showPage(request, response, dao);
            return;
        }

        BigDecimal price = new BigDecimal(priceText);

        boolean success;
        String successMessage;

        if ("add".equals(action)) {
            success = dao.insert(name, type, price);
            successMessage =
                    "Court \"" + name + "\" added successfully.";
        } else {
            success = dao.update(id, name, type, price);
            successMessage =
                    "Court \"" + name + "\" updated successfully.";
        }

        if (success) {
            redirectWithMessage(
                    request,
                    response,
                    successMessage,
                    "success"
            );
        } else {
            String reason = dao.getLastError();

            if (reason == null || reason.isBlank()) {
                reason = "Court not found or the operation failed.";
            }

            redirectWithMessage(
                    request,
                    response,
                    "Operation failed: " + reason,
                    "error"
            );
        }
    }

    // Activate or deactivate a court.
    private void toggleCourt(HttpServletRequest request,
                             HttpServletResponse response,
                             AdminCourtDAO dao)
            throws IOException {

        int id = toInt(request.getParameter("courtId"));

        if (id <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        boolean active = "true".equalsIgnoreCase(
                request.getParameter("active")
        );

        if (dao.setActive(id, active)) {
            String message = active
                    ? "Court activated successfully."
                    : "Court deactivated successfully.";

            redirectWithMessage(
                    request, response, message, "success"
            );
        } else {
            redirectWithMessage(
                    request,
                    response,
                    "Court not found or the operation failed.",
                    "error"
            );
        }
    }

    // Verify the session and administrator role.
    private boolean isAdmin(HttpServletRequest request,
                            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userID") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return false;
        }

        Object role = session.getAttribute("role");

        if (role == null
                || !"ADMIN".equalsIgnoreCase(role.toString())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );
            return false;
        }

        return true;
    }

    // Validate form input.
    private String validate(String name,
                            String type,
                            String priceText) {

        if (name.isEmpty()) {
            return "Please enter a court name.";
        }

        if (name.length() > 100) {
            return "Court name must not exceed 100 characters.";
        }

        if (!SPORT_TYPES.contains(type)) {
            return "Please select a valid sport type.";
        }

        if (priceText.isEmpty()) {
            return "Please enter the hourly price.";
        }

        BigDecimal price;

        try {
            price = new BigDecimal(priceText);
        } catch (NumberFormatException e) {
            return "Price must be a valid number, for example 80000.";
        }

        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            return "Price must be greater than zero.";
        }

        if (price.stripTrailingZeros().scale() > 0) {
            return "Price must be a whole number in VND.";
        }

        if (price.compareTo(
                new BigDecimal("1000000000")) > 0) {
            return "Price must not exceed 1,000,000,000 VND.";
        }

        return null;
    }

    // Load the courts and forward to the JSP.
    private void showPage(HttpServletRequest request,
                          HttpServletResponse response,
                          AdminCourtDAO dao)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Only show a flash message if this request has no message already.
        if (request.getAttribute("message") == null) {
            Object flashMessage =
                    session.getAttribute("flashMessage");

            if (flashMessage != null) {
                request.setAttribute(
                        "message", flashMessage
                );
                request.setAttribute(
                        "messageType",
                        session.getAttribute("flashType")
                );

                session.removeAttribute("flashMessage");
                session.removeAttribute("flashType");
            }
        }

        request.setAttribute("courts", dao.getAll());

        if (dao.getLastError() != null) {
            request.setAttribute(
                    "message",
                    "Database error: " + dao.getLastError()
            );
            request.setAttribute("messageType", "error");
        }

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }

    // Save a message for display after redirecting.
    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            String type) throws IOException {

        HttpSession session = request.getSession();

        session.setAttribute("flashMessage", message);
        session.setAttribute("flashType", type);

        response.sendRedirect(
                request.getContextPath() + URL
        );
    }

    // Parse an integer; return zero if invalid.
    private int toInt(String text) {
        try {
            return Integer.parseInt(text);
        } catch (NumberFormatException | NullPointerException e) {
            return 0;
        }
    }

    // Trim whitespace and safely handle null.
    private String clean(String text) {
        return text == null ? "" : text.trim();
    }

    @Override
    public String getServletInfo() {
        return "Admin court management";
    }
}
