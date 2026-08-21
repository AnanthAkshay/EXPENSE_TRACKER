package com.expensetracker;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.filter.CorsFilter;
import com.expensetracker.filter.JsonErrorFilter;
import com.expensetracker.servlet.*;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.tomcat.util.descriptor.web.FilterDef;
import org.apache.tomcat.util.descriptor.web.FilterMap;

import java.io.File;

public class App {
    public static void main(String[] args) throws Exception {
        int port = 8085;
        String portEnv = System.getenv("PORT");
        if (portEnv != null && !portEnv.isEmpty()) {
            try {
                port = Integer.parseInt(portEnv);
            } catch (NumberFormatException ignored) {}
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector(); // Initialize default connector

        String tempDir = new File("target/tomcat").getAbsolutePath();
        new File(tempDir).mkdirs();
        tomcat.setBaseDir(tempDir);

        Context ctx = tomcat.addContext("", new File(tempDir).getAbsolutePath());
        ctx.setParentClassLoader(App.class.getClassLoader());

        // Register CORS Filter instance
        FilterDef corsDef = new FilterDef();
        corsDef.setFilterName("CorsFilter");
        corsDef.setFilterClass(CorsFilter.class.getName());
        corsDef.setFilter(new CorsFilter());
        ctx.addFilterDef(corsDef);

        FilterMap corsMap = new FilterMap();
        corsMap.setFilterName("CorsFilter");
        corsMap.addURLPattern("/*");
        ctx.addFilterMap(corsMap);

        // Register JsonError Filter instance
        FilterDef jsonErrorDef = new FilterDef();
        jsonErrorDef.setFilterName("JsonErrorFilter");
        jsonErrorDef.setFilterClass(JsonErrorFilter.class.getName());
        jsonErrorDef.setFilter(new JsonErrorFilter());
        ctx.addFilterDef(jsonErrorDef);

        FilterMap jsonErrorMap = new FilterMap();
        jsonErrorMap.setFilterName("JsonErrorFilter");
        jsonErrorMap.addURLPattern("/*");
        ctx.addFilterMap(jsonErrorMap);

        // Register Servlets
        Tomcat.addServlet(ctx, "ExpenseServlet", new ExpenseServlet());
        ctx.addServletMappingDecoded("/api/v1/expenses/*", "ExpenseServlet");
        ctx.addServletMappingDecoded("/api/v1/expenses", "ExpenseServlet");

        Tomcat.addServlet(ctx, "CategoryServlet", new CategoryServlet());
        ctx.addServletMappingDecoded("/api/v1/categories/*", "CategoryServlet");
        ctx.addServletMappingDecoded("/api/v1/categories", "CategoryServlet");
        ctx.addServletMappingDecoded("/api/v1/payment-methods", "CategoryServlet");

        Tomcat.addServlet(ctx, "BudgetServlet", new BudgetServlet());
        ctx.addServletMappingDecoded("/api/v1/budgets/*", "BudgetServlet");
        ctx.addServletMappingDecoded("/api/v1/budgets", "BudgetServlet");

        Tomcat.addServlet(ctx, "GoalServlet", new GoalServlet());
        ctx.addServletMappingDecoded("/api/v1/goals/*", "GoalServlet");
        ctx.addServletMappingDecoded("/api/v1/goals", "GoalServlet");

        Tomcat.addServlet(ctx, "DashboardServlet", new DashboardServlet());
        ctx.addServletMappingDecoded("/api/v1/analytics/dashboard", "DashboardServlet");

        Tomcat.addServlet(ctx, "AnalyticsServlet", new AnalyticsServlet());
        ctx.addServletMappingDecoded("/api/v1/analytics/*", "AnalyticsServlet");


        Tomcat.addServlet(ctx, "WrappedServlet", new WrappedServlet());
        ctx.addServletMappingDecoded("/api/v1/wrapped/*", "WrappedServlet");
        ctx.addServletMappingDecoded("/api/v1/wrapped", "WrappedServlet");

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try {
                System.out.println("Shutting down Embedded Tomcat & DB Connection Pool...");
                DBConnectionManager.closePool();
                tomcat.stop();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }));

        System.out.println("=================================================");
        System.out.println(" Personal Expense Tracker Backend Server");
        System.out.println(" Listening on http://localhost:" + port);
        System.out.println(" REST API Base URL: http://localhost:" + port + "/api/v1");
        System.out.println("=================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}
