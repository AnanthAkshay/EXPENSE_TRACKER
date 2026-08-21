package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.Expense;
import com.expensetracker.service.ExpenseService;
import com.expensetracker.util.JsonUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Date;
import java.util.Map;

public class ExpenseServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        long userId = AppConfig.DEFAULT_USER_ID;

        try {
            if (pathInfo != null && pathInfo.length() > 1) {
                // GET /expenses/{id}
                long id = Long.parseLong(pathInfo.substring(1));
                Expense expense = expenseService.getExpenseById(userId, id);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, expense);
            } else {
                // GET /expenses?from=&to=&categoryId=&search=&sort=&page=&size=
                String fromStr = req.getParameter("from");
                String toStr = req.getParameter("to");
                String catIdStr = req.getParameter("categoryId");
                String search = req.getParameter("search");
                String sort = req.getParameter("sort");
                String pageStr = req.getParameter("page");
                String sizeStr = req.getParameter("size");

                Date from = (fromStr != null && !fromStr.isEmpty()) ? Date.valueOf(fromStr) : null;
                Date to = (toStr != null && !toStr.isEmpty()) ? Date.valueOf(toStr) : null;
                Long categoryId = (catIdStr != null && !catIdStr.isEmpty()) ? Long.parseLong(catIdStr) : null;
                int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
                int size = (sizeStr != null && !sizeStr.isEmpty()) ? Integer.parseInt(sizeStr) : AppConfig.DEFAULT_PAGE_SIZE;

                Map<String, Object> response = expenseService.getExpenses(userId, from, to, categoryId, search, sort, page, size);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, response);
            }
        } catch (IllegalArgumentException e) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", e.getMessage());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            String body = readRequestBody(req);
            Expense expense = JsonUtil.fromJson(body, Expense.class);
            Expense created = expenseService.createExpense(userId, expense);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_CREATED, created);
        } catch (IllegalArgumentException e) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", e.getMessage());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        long userId = AppConfig.DEFAULT_USER_ID;

        if (pathInfo == null || pathInfo.length() <= 1) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "BAD_REQUEST", "Expense ID is required in URL");
            return;
        }

        try {
            long id = Long.parseLong(pathInfo.substring(1));
            String body = readRequestBody(req);
            Expense expense = JsonUtil.fromJson(body, Expense.class);
            Expense updated = expenseService.updateExpense(userId, id, expense);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, updated);
        } catch (IllegalArgumentException e) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", e.getMessage());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        long userId = AppConfig.DEFAULT_USER_ID;

        if (pathInfo == null || pathInfo.length() <= 1) {
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "BAD_REQUEST", "Expense ID is required in URL");
            return;
        }

        try {
            long id = Long.parseLong(pathInfo.substring(1));
            boolean deleted = expenseService.deleteExpense(userId, id);
            if (deleted) {
                resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", "Expense not found");
            }
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
