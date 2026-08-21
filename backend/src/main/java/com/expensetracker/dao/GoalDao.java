package com.expensetracker.dao;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.model.Goal;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GoalDao {

    public List<Goal> getGoalsByUserId(long userId) throws SQLException {
        List<Goal> list = new ArrayList<>();
        String sql = "SELECT * FROM goals WHERE user_id = ? ORDER BY target_date ASC, created_at DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        }
        return list;
    }

    public Goal getGoalById(long id, long userId) throws SQLException {
        String sql = "SELECT * FROM goals WHERE id = ? AND user_id = ?";
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

    public Goal createGoal(Goal goal) throws SQLException {
        String sql = "INSERT INTO goals (user_id, name, target_amount, saved_amount, target_date) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, goal.getUserId());
            ps.setString(2, goal.getName());
            ps.setBigDecimal(3, goal.getTargetAmount());
            ps.setBigDecimal(4, goal.getSavedAmount() != null ? goal.getSavedAmount() : BigDecimal.ZERO);
            ps.setDate(5, goal.getTargetDate());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    goal.setId(rs.getLong(1));
                }
            }
        }
        return getGoalById(goal.getId(), goal.getUserId());
    }

    public Goal updateGoal(Goal goal) throws SQLException {
        String sql = "UPDATE goals SET name = ?, target_amount = ?, saved_amount = ?, target_date = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, goal.getName());
            ps.setBigDecimal(2, goal.getTargetAmount());
            ps.setBigDecimal(3, goal.getSavedAmount() != null ? goal.getSavedAmount() : BigDecimal.ZERO);
            ps.setDate(4, goal.getTargetDate());
            ps.setLong(5, goal.getId());
            ps.setLong(6, goal.getUserId());
            ps.executeUpdate();
        }
        return getGoalById(goal.getId(), goal.getUserId());
    }

    public boolean deleteGoal(long id, long userId) throws SQLException {
        String sql = "DELETE FROM goals WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private Goal mapResultSet(ResultSet rs) throws SQLException {
        Goal g = new Goal();
        g.setId(rs.getLong("id"));
        g.setUserId(rs.getLong("user_id"));
        g.setName(rs.getString("name"));
        g.setTargetAmount(rs.getBigDecimal("target_amount"));
        g.setSavedAmount(rs.getBigDecimal("saved_amount"));
        g.setTargetDate(rs.getDate("target_date"));
        g.setCreatedAt(rs.getTimestamp("created_at"));
        return g;
    }
}
