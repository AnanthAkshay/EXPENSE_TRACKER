package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.Category;
import com.expensetracker.model.PaymentMethod;
import com.expensetracker.service.CategoryService;
import com.expensetracker.util.JsonUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;

public class CategoryServlet extends HttpServlet {

    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        String pathInfo = req.getPathInfo();

        try {
            if ("/payment-methods".equalsIgnoreCase(pathInfo)) {
                List<PaymentMethod> paymentMethods = categoryService.getPaymentMethods(userId);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, paymentMethods);
            } else {
                boolean includeArchived = "true".equalsIgnoreCase(req.getParameter("includeArchived"));
                List<Category> categories = categoryService.getCategories(userId, includeArchived);
                ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, categories);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            String body = readRequestBody(req);
            Category category = JsonUtil.fromJson(body, Category.class);
            Category created = categoryService.createCategory(userId, category);
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
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "BAD_REQUEST", "Category ID is required in URL");
            return;
        }

        try {
            long id = Long.parseLong(pathInfo.substring(1));
            String body = readRequestBody(req);
            Category category = JsonUtil.fromJson(body, Category.class);
            Category updated = categoryService.updateCategory(userId, id, category);
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
