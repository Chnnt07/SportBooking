/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt
 * to change this license
 */
package filters;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Prevent protected pages from being restored from browser cache.
        res.setHeader("Cache-Control",
                "no-store, no-cache, must-revalidate, max-age=0");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        HttpSession session = req.getSession(false);

        // Require the user to be logged in.
        if (session == null
                || session.getAttribute("userID") == null) {

            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getRequestURI().substring(
                req.getContextPath().length());

        String role = (String) session.getAttribute("role");

        // Admin-only pages.
        boolean adminPage =
                path.equals("/AdminBookingController")
                || path.equals("/AdminCourtController");

        // Customer-only pages.
        boolean userPage =
                path.equals("/CourtController")
                || path.equals("/BookingController")
                || path.equals("/MyBookingController");

        // Prevent normal users from accessing admin pages.
        if (adminPage && !"ADMIN".equalsIgnoreCase(role)) {
            res.sendRedirect(req.getContextPath() + "/CourtController");
            return;
        }

        // Prevent admins from accessing customer booking pages.
        if (userPage && "ADMIN".equalsIgnoreCase(role)) {
            res.sendRedirect(
                    req.getContextPath() + "/AdminBookingController");
            return;
        }

        // Allow the request if access is permitted.
        chain.doFilter(request, response);
    }
}