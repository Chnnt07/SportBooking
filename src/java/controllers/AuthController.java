package controllers;

import dal.PasswordUtil;
import dao.UserDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

@WebServlet(name = "AuthController",
            urlPatterns = {"/login", "/register"})
public class AuthController extends HttpServlet {

            @Override
        protected void doGet(HttpServletRequest request,
                             HttpServletResponse response)
                throws ServletException, IOException {

            String path = request.getServletPath();

            if ("/register".equals(path)) {
                request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp"
                ).forward(request, response);

            } else {
                // Default page: login
                request.getRequestDispatcher(
                    "/WEB-INF/views/login.jsp"
                ).forward(request, response);
            }
        }

        @Override
        protected void doPost(HttpServletRequest request,
                              HttpServletResponse response)
                throws ServletException, IOException {

            String action = request.getParameter("action");

            if ("login".equals(action)) {
                // Call your login handling logic
            } else if ("register".equals(action)) {
                // Call your registration handling logic
            } else {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
                );
            }
        }

    private void login(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.isBlank()
                || password == null || password.isEmpty()) {

            request.setAttribute("error",
                    "Please enter username and password.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/login.jsp")
                    .forward(request, response);
            return;
        }

        try {
            User user = new UserDAO().findByUsername(
                    username.trim());

            if (user == null
                    || !PasswordUtil.verifyPassword(
                            password, user.getPasswordHash())) {

                request.setAttribute("error",
                        "Invalid username or password.");

                request.getRequestDispatcher(
                        "/WEB-INF/views/login.jsp")
                        .forward(request, response);
                return;
            }

            // Prevent session fixation after login.
            HttpSession oldSession = request.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);

            // Store only the information needed by the application.
            session.setAttribute("userID", user.getUserID());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());

            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/AdminBookingController");
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/CourtController");
            }

        } catch (Exception e) {
            log("Login failed", e);

            request.setAttribute("error",
                    "Unable to log in. Please try again.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/login.jsp")
                    .forward(request, response);
        }
    }

    private void register(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword =
                request.getParameter("confirmPassword");

        if (fullName == null || fullName.isBlank()
                || username == null || username.isBlank()
                || password == null || password.isEmpty()
                || confirmPassword == null
                || confirmPassword.isEmpty()) {

            request.setAttribute("error",
                    "Please complete all fields.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);
            return;
        }

        fullName = fullName.trim();
        username = username.trim();

        if (username.length() > 50 || fullName.length() > 100) {
            request.setAttribute("error",
                    "Name or username is too long.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error",
                    "Passwords do not match.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);
            return;
        }

        if (password.length() < 8) {
            request.setAttribute("error",
                    "Password must contain at least 8 characters.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);
            return;
        }

        try {
            String passwordHash =
                    PasswordUtil.hashPassword(password);

            boolean created = new UserDAO().createCustomer(
                    fullName, username, passwordHash);

            if (!created) {
                request.setAttribute("error",
                        "That username is already taken.");

                request.getRequestDispatcher(
                        "/WEB-INF/views/register.jsp")
                        .forward(request, response);
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/AuthController?registered=1");

        } catch (SQLException e) {
            log("Registration database error", e);

            request.setAttribute("error",
                    "Unable to register. Please try again.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            log("Password hashing error", e);

            request.setAttribute("error",
                    "Unable to register. Please try again.");

            request.getRequestDispatcher(
                    "/WEB-INF/views/register.jsp")
                    .forward(request, response);
        }
    }

    private void logout(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(
                request.getContextPath()
                + "/AuthController");
    }
}