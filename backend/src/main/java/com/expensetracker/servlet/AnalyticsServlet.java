package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.Insight;
import com.expensetracker.service.AnalyticsService;
import com.expensetracker.util.DateUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

public class AnalyticsServlet extends HttpServlet {

    private final AnalyticsService analyticsService = new AnalyticsService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        String pathInfo = req.getPathInfo();
        String uri = req.getRequestURI();
        if (pathInfo == null || pathInfo.isEmpty()) {
            if (uri.endsWith("/trends")) pathInfo = "/trends";
            else if (uri.endsWith("/calendar")) pathInfo = "/calendar";
            else if (uri.endsWith("/insights")) pathInfo = "/insights";
        }


        try {
            if ("/trends".equalsIgnoreCase(pathInfo)) {
                String period = req.getParameter("period");
                List<Map<String, Object>> trends = analyticsService.getTrends(userId, period);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, trends);
            } else if ("/calendar".equalsIgnoreCase(pathInfo)) {
                String monthStr = req.getParameter("month");
                YearMonth ym = DateUtil.parseMonthYear(monthStr);
                List<Map<String, Object>> heatmap = analyticsService.getCalendarHeatmap(userId, ym);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, heatmap);
            } else if ("/insights".equalsIgnoreCase(pathInfo)) {
                String monthStr = req.getParameter("month");
                YearMonth ym = DateUtil.parseMonthYear(monthStr);
                List<Insight> insights = analyticsService.calculateInsights(userId, ym);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, insights);
            } else {
                ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", "Unknown analytics endpoint");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
