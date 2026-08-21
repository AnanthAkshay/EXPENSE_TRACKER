package com.expensetracker.filter;

import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class JsonErrorFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        try {
            chain.doFilter(request, response);
        } catch (IllegalArgumentException e) {
            HttpServletResponse resp = (HttpServletResponse) response;
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            HttpServletResponse resp = (HttpServletResponse) response;
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "INTERNAL_SERVER_ERROR",
                    e.getMessage() != null ? e.getMessage() : "An unexpected server error occurred");
        }
    }
}
