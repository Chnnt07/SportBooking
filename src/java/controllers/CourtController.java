
package controllers;

import dao.CourtDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CourtController", urlPatterns = {"/CourtController"})
public class CourtController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        String sportType = request.getParameter("sportType");

        if (keyword == null) keyword = "";
        if (sportType == null) sportType = "";

        keyword = keyword.trim();
        sportType = sportType.trim();

        CourtDAO dao = new CourtDAO();

        try {
            request.setAttribute(
                "courts",
                dao.searchCourts(keyword, sportType)
            );
            request.setAttribute("keyword", keyword);
            request.setAttribute("sportType", sportType);

            request.getRequestDispatcher(
                "/WEB-INF/views/courts.jsp"
            ).forward(request, response);

        } finally {
            dao.close();
        }
    }
}
