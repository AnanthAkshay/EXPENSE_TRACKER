package com.expensetracker.servlet;

import com.expensetracker.config.AppConfig;
import com.expensetracker.model.Goal;
import com.expensetracker.service.GoalService;
import com.expensetracker.util.JsonUtil;
import com.expensetracker.util.ResponseUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;

public class GoalServlet extends HttpServlet {

    private final GoalService goalService = new GoalService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            List<Goal> goals = goalService.getGoals(userId);
            ResponseUtil.sendJsonResponse(resp, HttpServletResponse.SC_OK, goals);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long userId = AppConfig.DEFAULT_USER_ID;
        try {
            String body = readRequestBody(req);
            Goal goal = JsonUtil.fromJson(body, Goal.class);
            Goal created = goalService.createGoal(userId, goal);
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
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "BAD_REQUEST", "Goal ID is required in URL");
            return;
        }

        try {
            long id = Long.parseLong(pathInfo.substring(1));
            String body = readRequestBody(req);
            Goal goal = JsonUtil.fromJson(body, Goal.class);
            Goal updated = goalService.updateGoal(userId, id, goal);
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
            ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "BAD_REQUEST", "Goal ID is required in URL");
            return;
        }

        try {
            long id = Long.parseLong(pathInfo.substring(1));
            boolean deleted = goalService.deleteGoal(userId, id);
            if (deleted) {
                resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                ResponseUtil.sendErrorResponse(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", "Goal not found");
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
