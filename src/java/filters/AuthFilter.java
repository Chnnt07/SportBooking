/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filters;

/**
 *
 * @author ADMIN
 */

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = {
    "/AdminBookingController",
    "/AdminCourtController",
    "/BookingController",
    "/MyBookingController"
})
public class AuthFilter implements Filter {
        @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        if (session == null
                || session.getAttribute("userID") == null) {

            res.sendRedirect(
                    req.getContextPath() + "/AuthController");
            return;
        }

        String path = req.getRequestURI().substring(
                req.getContextPath().length());

        boolean adminPage =
                path.equals("/AdminBookingController")
                || path.equals("/AdminCourtController");

        String role = (String) session.getAttribute("role");

        if (adminPage && !"ADMIN".equals(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(request, response);
    }
}
