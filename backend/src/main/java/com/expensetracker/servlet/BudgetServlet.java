package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.Budget;
import com.expensetracker.service.BudgetService;
import com.expensetracker.util.DateUtil;
import com.expensetracker.util.JsonUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

public class BudgetServlet extends HttpServlet {

    private final BudgetService budgetService = new BudgetService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        String month = req.getParameter("month");
        if (month == null || month.trim().isEmpty()) {
            month = DateUtil.currentMonthYear();
        }

        try {
            Map<String, Object> overview = budgetService.getBudgetOverview(userId, month);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, overview);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            String body = readRequestBody(req);
            Budget budget = JsonUtil.fromJson(body, Budget.class);
            if (budget.getMonthYear() == null || budget.getMonthYear().trim().isEmpty()) {
                budget.setMonthYear(DateUtil.currentMonthYear());
            }
            Budget updated = budgetService.upsertBudget(userId, budget.getCategoryId(), budget.getMonthYear(), budget.getAmount());
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, updated);
        } catch (IllegalArgumentException e) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", e.getMessage());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String readRequestBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }
}
