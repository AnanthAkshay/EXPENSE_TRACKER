package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.service.AnalyticsService;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

public class DashboardServlet extends HttpServlet {

    private final AnalyticsService analyticsService = new AnalyticsService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            Map<String, Object> data = analyticsService.getDashboardData(userId);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, data);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
