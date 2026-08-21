package com.expensetracker.util;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class ResponseUtil {
    public static void sendJsonResponse(HttpServletResponse resp, int status, Object data) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(JsonUtil.toJson(data));
    }

    public static void sendErrorResponse(HttpServletResponse resp, int status, String errorCode, String message) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("code", errorCode);
        errorDetails.put("message", message);

        Map<String, Object> body = new HashMap<>();
        body.put("error", errorDetails);

        resp.getWriter().write(JsonUtil.toJson(body));
    }
}
