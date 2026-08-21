package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.WrappedStory;
import com.expensetracker.service.WrappedService;
import com.expensetracker.util.DateUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class WrappedServlet extends HttpServlet {

    private final WrappedService wrappedService = new WrappedService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        String pathInfo = req.getPathInfo();

        String monthYearStr = DateUtil.currentMonthYear();
        if (pathInfo != null && pathInfo.length() > 1) {
            monthYearStr = pathInfo.substring(1);
        }

        try {
            WrappedStory story = wrappedService.generateWrappedStory(userId, monthYearStr);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, story);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
