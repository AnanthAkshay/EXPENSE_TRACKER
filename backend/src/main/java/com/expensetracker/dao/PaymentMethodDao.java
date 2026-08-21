package com.expensetracker.dao;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.model.PaymentMethod;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentMethodDao {

    public List<PaymentMethod> getPaymentMethodsByUserId(long userId) throws SQLException {
        List<PaymentMethod> list = new ArrayList<>();
        String sql = "SELECT * FROM payment_methods WHERE user_id = ? ORDER BY is_default DESC, name ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentMethod pm = new PaymentMethod();
                    pm.setId(rs.getLong("id"));
                    pm.setUserId(rs.getLong("user_id"));
                    pm.setName(rs.getString("name"));
                    pm.setIsDefault(rs.getBoolean("is_default"));
                    list.add(pm);
                }
            }
        }
        return list;
    }

    public PaymentMethod getPaymentMethodById(long id, long userId) throws SQLException {
        String sql = "SELECT * FROM payment_methods WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PaymentMethod pm = new PaymentMethod();
                    pm.setId(rs.getLong("id"));
                    pm.setUserId(rs.getLong("user_id"));
                    pm.setName(rs.getString("name"));
                    pm.setIsDefault(rs.getBoolean("is_default"));
                    return pm;
                }
            }
        }
        return null;
    }
}
