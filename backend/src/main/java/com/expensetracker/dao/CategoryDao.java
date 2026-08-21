package com.expensetracker.dao;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDao {

    public List<Category> getCategoriesByUserId(long userId, boolean includeArchived) throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE user_id = ? " +
                (includeArchived ? "" : "AND is_archived = FALSE ") +
                "ORDER BY is_default DESC, name ASC";

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

    public Category getCategoryById(long id, long userId) throws SQLException {
        String sql = "SELECT * FROM categories WHERE id = ? AND user_id = ?";
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

    public Category createCategory(Category category) throws SQLException {
        String sql = "INSERT INTO categories (user_id, name, icon_key, color_hex, is_default, is_archived) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, category.getUserId());
            ps.setString(2, category.getName());
            ps.setString(3, category.getIconKey());
            ps.setString(4, category.getColorHex());
            ps.setBoolean(5, category.getIsDefault() != null ? category.getIsDefault() : false);
            ps.setBoolean(6, category.getIsArchived() != null ? category.getIsArchived() : false);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    category.setId(rs.getLong(1));
                }
            }
        }
        return category;
    }

    public Category updateCategory(Category category) throws SQLException {
        String sql = "UPDATE categories SET name = ?, icon_key = ?, color_hex = ?, is_archived = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getIconKey());
            ps.setString(3, category.getColorHex());
            ps.setBoolean(4, category.getIsArchived() != null ? category.getIsArchived() : false);
            ps.setLong(5, category.getId());
            ps.setLong(6, category.getUserId());
            ps.executeUpdate();
        }
        return getCategoryById(category.getId(), category.getUserId());
    }

    private Category mapResultSet(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setId(rs.getLong("id"));
        c.setUserId(rs.getLong("user_id"));
        c.setName(rs.getString("name"));
        c.setIconKey(rs.getString("icon_key"));
        c.setColorHex(rs.getString("color_hex"));
        c.setIsDefault(rs.getBoolean("is_default"));
        c.setIsArchived(rs.getBoolean("is_archived"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
