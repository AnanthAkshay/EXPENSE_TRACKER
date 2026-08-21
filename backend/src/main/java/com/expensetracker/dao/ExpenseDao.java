package com.expensetracker.dao;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.model.Expense;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExpenseDao {

    public Expense createExpense(Expense expense) throws SQLException {
        String sql = "INSERT INTO expenses (user_id, category_id, payment_method_id, amount, expense_date, note) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, expense.getUserId());
            ps.setLong(2, expense.getCategoryId());
            if (expense.getPaymentMethodId() != null) {
                ps.setLong(3, expense.getPaymentMethodId());
            } else {
                ps.setNull(3, Types.BIGINT);
            }
            ps.setBigDecimal(4, expense.getAmount());
            ps.setDate(5, expense.getExpenseDate());
            ps.setString(6, expense.getNote());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    expense.setId(rs.getLong(1));
                }
            }
        }
        return getExpenseById(expense.getId(), expense.getUserId());
    }

    public Expense getExpenseById(long id, long userId) throws SQLException {
        String sql = "SELECT e.*, c.name AS category_name, c.icon_key AS category_icon_key, c.color_hex AS category_color_hex, " +
                "pm.name AS payment_method_name " +
                "FROM expenses e " +
                "JOIN categories c ON e.category_id = c.id " +
                "LEFT JOIN payment_methods pm ON e.payment_method_id = pm.id " +
                "WHERE e.id = ? AND e.user_id = ?";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    public Expense updateExpense(Expense expense) throws SQLException {
        String sql = "UPDATE expenses SET category_id = ?, payment_method_id = ?, amount = ?, expense_date = ?, note = ? " +
                "WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, expense.getCategoryId());
            if (expense.getPaymentMethodId() != null) {
                ps.setLong(2, expense.getPaymentMethodId());
            } else {
                ps.setNull(2, Types.BIGINT);
            }
            ps.setBigDecimal(3, expense.getAmount());
            ps.setDate(4, expense.getExpenseDate());
            ps.setString(5, expense.getNote());
            ps.setLong(6, expense.getId());
            ps.setLong(7, expense.getUserId());
            ps.executeUpdate();
        }
        return getExpenseById(expense.getId(), expense.getUserId());
    }

    public boolean deleteExpense(long id, long userId) throws SQLException {
        String sql = "DELETE FROM expenses WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, userId);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    public List<Expense> getExpenses(long userId, Date from, Date to, Long categoryId, String search, String sort, int page, int size) throws SQLException {
        List<Expense> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT e.*, c.name AS category_name, c.icon_key AS category_icon_key, c.color_hex AS category_color_hex, " +
                        "pm.name AS payment_method_name " +
                        "FROM expenses e " +
                        "JOIN categories c ON e.category_id = c.id " +
                        "LEFT JOIN payment_methods pm ON e.payment_method_id = pm.id " +
                        "WHERE e.user_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (from != null) {
            sql.append("AND e.expense_date >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append("AND e.expense_date <= ? ");
            params.add(to);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND e.category_id = ? ");
            params.add(categoryId);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (e.note LIKE ? OR c.name LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
        }

        // Sorting
        if ("amount_asc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY e.amount ASC, e.expense_date DESC ");
        } else if ("amount_desc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY e.amount DESC, e.expense_date DESC ");
        } else if ("date_asc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY e.expense_date ASC, e.id ASC ");
        } else {
            sql.append("ORDER BY e.expense_date DESC, e.id DESC ");
        }

        // Pagination
        sql.append("LIMIT ? OFFSET ?");
        params.add(size);
        params.add((page - 1) * size);

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public int countExpenses(long userId, Date from, Date to, Long categoryId, String search) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM expenses e JOIN categories c ON e.category_id = c.id WHERE e.user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (from != null) {
            sql.append("AND e.expense_date >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append("AND e.expense_date <= ? ");
            params.add(to);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND e.category_id = ? ");
            params.add(categoryId);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (e.note LIKE ? OR c.name LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
        }

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public BigDecimal getTotalSpendForPeriod(long userId, Date from, Date to) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, from);
            ps.setDate(3, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        }
        return BigDecimal.ZERO;
    }

    public List<Map<String, Object>> getCategoryBreakdown(long userId, Date from, Date to, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.id, c.name, c.icon_key, c.color_hex, SUM(e.amount) AS total_amount, COUNT(e.id) AS cnt " +
                "FROM expenses e " +
                "JOIN categories c ON e.category_id = c.id " +
                "WHERE e.user_id = ? AND e.expense_date >= ? AND e.expense_date <= ? " +
                "GROUP BY c.id, c.name, c.icon_key, c.color_hex " +
                "ORDER BY total_amount DESC " +
                (limit > 0 ? "LIMIT " + limit : "");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, from);
            ps.setDate(3, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryId", rs.getLong("id"));
                    map.put("name", rs.getString("name"));
                    map.put("iconKey", rs.getString("icon_key"));
                    map.put("colorHex", rs.getString("color_hex"));
                    map.put("amount", rs.getBigDecimal("total_amount"));
                    map.put("count", rs.getInt("cnt"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public List<Map<String, Object>> getDailyTimeline(long userId, Date from, Date to) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT expense_date, SUM(amount) AS total_amount, COUNT(id) AS cnt " +
                "FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? " +
                "GROUP BY expense_date ORDER BY expense_date ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, from);
            ps.setDate(3, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getDate("expense_date").toString());
                    map.put("amount", rs.getBigDecimal("total_amount"));
                    map.put("count", rs.getInt("cnt"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public Map<String, Object> getHighestSpendingDay(long userId, Date from, Date to) throws SQLException {
        String sql = "SELECT expense_date, SUM(amount) AS total_amount, COUNT(id) AS cnt " +
                "FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? " +
                "GROUP BY expense_date ORDER BY total_amount DESC LIMIT 1";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, from);
            ps.setDate(3, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getDate("expense_date").toString());
                    map.put("amount", rs.getBigDecimal("total_amount"));
                    map.put("count", rs.getInt("cnt"));
                    return map;
                }
            }
        }
        return null;
    }

    public Expense getLargestExpense(long userId, Date from, Date to) throws SQLException {
        String sql = "SELECT e.*, c.name AS category_name, c.icon_key AS category_icon_key, c.color_hex AS category_color_hex, " +
                "pm.name AS payment_method_name " +
                "FROM expenses e " +
                "JOIN categories c ON e.category_id = c.id " +
                "LEFT JOIN payment_methods pm ON e.payment_method_id = pm.id " +
                "WHERE e.user_id = ? AND e.expense_date >= ? AND e.expense_date <= ? " +
                "ORDER BY e.amount DESC LIMIT 1";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, from);
            ps.setDate(3, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    private Expense mapResultSet(ResultSet rs) throws SQLException {
        Expense e = new Expense();
        e.setId(rs.getLong("id"));
        e.setUserId(rs.getLong("user_id"));
        e.setCategoryId(rs.getLong("category_id"));
        long pmId = rs.getLong("payment_method_id");
        if (!rs.wasNull()) {
            e.setPaymentMethodId(pmId);
        }
        e.setAmount(rs.getBigDecimal("amount"));
        e.setExpenseDate(rs.getDate("expense_date"));
        e.setNote(rs.getString("note"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        e.setUpdatedAt(rs.getTimestamp("updated_at"));

        e.setCategoryName(rs.getString("category_name"));
        e.setCategoryIconKey(rs.getString("category_icon_key"));
        e.setCategoryColorHex(rs.getString("category_color_hex"));
        e.setPaymentMethodName(rs.getString("payment_method_name"));
        return e;
    }
}
