package com.expensetracker.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnectionManager {
    private static HikariDataSource dataSource;
    private static Throwable initException;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Properties props = new Properties();
            try (InputStream input = DBConnectionManager.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    props.load(input);
                }
            } catch (Exception e) {
                System.err.println("Warning: Could not load db.properties: " + e.getMessage());
            }

            String dbUrl = props.getProperty("db.url", "jdbc:mysql://localhost:3306/expense_tracker?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
            String dbUser = props.getProperty("db.user", "root");
            String dbPassword = props.getProperty("db.password", "Akshay@2006");

            // Allow explicit environment override only if EXPENSE_TRACKER_DB_URL is passed
            String envDbUrl = System.getenv("EXPENSE_TRACKER_DB_URL");
            if (envDbUrl != null && !envDbUrl.isEmpty()) {
                dbUrl = envDbUrl;
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(dbUrl);
            config.setUsername(dbUser);
            config.setPassword(dbPassword);
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(10000);

            dataSource = new HikariDataSource(config);
            System.out.println("HikariCP DataSource initialized successfully for: " + dbUrl);
        } catch (Throwable t) {
            initException = t;
            System.err.println("Failed to initialize HikariCP DataSource: " + t.getMessage());
            t.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            if (initException != null) {
                throw new SQLException("DataSource init failed: " + initException.getMessage(), initException);
            }
            throw new SQLException("DataSource is not initialized");
        }
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
