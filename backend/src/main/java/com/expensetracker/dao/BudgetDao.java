package com.expensetracker.dao;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.model.Budget;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BudgetDao {

    public List<Budget> getBudgetsByMonthYear(long userId, String monthYear) throws SQLException {
        List<Budget> list = new ArrayList<>();
        String sql = "SELECT b.*, c.name AS category_name, c.icon_key AS category_icon_key, c.color_hex AS category_color_hex " +
                "FROM budgets b " +
                "LEFT JOIN categories c ON b.category_id = c.id " +
                "WHERE b.user_id = ? AND b.month_year = ?";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, monthYear);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public Budget upsertBudget(long userId, Long categoryId, String monthYear, BigDecimal amount) throws SQLException {
        String sql = "INSERT INTO budgets (user_id, category_id, month_year, amount) VALUES (?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE amount = VALUES(amount)";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            if (categoryId != null && categoryId > 0) {
                ps.setLong(2, categoryId);
            } else {
                ps.setNull(2, Types.BIGINT);
            }
            ps.setString(3, monthYear);
            ps.setBigDecimal(4, amount);
            ps.executeUpdate();
        }

        // Return upserted budget
        return getBudgetByScope(userId, categoryId, monthYear);
    }

    public Budget getBudgetByScope(long userId, Long categoryId, String monthYear) throws SQLException {
        String sql;
        if (categoryId != null && categoryId > 0) {
            sql = "SELECT b.*, c.name AS category_name, c.icon_key AS category_icon_key, c.color_hex AS category_color_hex " +
                    "FROM budgets b LEFT JOIN categories c ON b.category_id = c.id " +
                    "WHERE b.user_id = ? AND b.category_id = ? AND b.month_year = ?";
        } else {
            sql = "SELECT b.*, NULL AS category_name, NULL AS category_icon_key, NULL AS category_color_hex " +
                    "FROM budgets b " +
                    "WHERE b.user_id = ? AND b.category_id IS NULL AND b.month_year = ?";
        }

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            if (categoryId != null && categoryId > 0) {
                ps.setLong(2, categoryId);
                ps.setString(3, monthYear);
            } else {
                ps.setString(2, monthYear);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    private Budget mapResultSet(ResultSet rs) throws SQLException {
        Budget b = new Budget();
        b.setId(rs.getLong("id"));
        b.setUserId(rs.getLong("user_id"));
        long catId = rs.getLong("category_id");
        if (!rs.wasNull()) {
            b.setCategoryId(catId);
        }
        b.setMonthYear(rs.getString("month_year"));
        b.setAmount(rs.getBigDecimal("amount"));
        b.setCategoryName(rs.getString("category_name"));
        b.setCategoryIconKey(rs.getString("category_icon_key"));
        b.setCategoryColorHex(rs.getString("category_color_hex"));
        return b;
    }
}
