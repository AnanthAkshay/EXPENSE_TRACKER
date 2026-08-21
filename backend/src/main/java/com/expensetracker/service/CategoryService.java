package com.expensetracker.service;

import com.expensetracker.dao.CategoryDao;
import com.expensetracker.dao.PaymentMethodDao;
import com.expensetracker.model.Category;
import com.expensetracker.model.PaymentMethod;
import com.expensetracker.util.ValidationUtil;

import java.util.List;

public class CategoryService {

    private final CategoryDao categoryDao = new CategoryDao();
    private final PaymentMethodDao paymentMethodDao = new PaymentMethodDao();

    public List<Category> getCategories(long userId, boolean includeArchived) throws Exception {
        return categoryDao.getCategoriesByUserId(userId, includeArchived);
    }

    public Category createCategory(long userId, Category category) throws Exception {
        category.setUserId(userId);
        ValidationUtil.validateCategoryName(category.getName());
        if (category.getIconKey() == null || category.getIconKey().trim().isEmpty()) {
            category.setIconKey("tag");
        }
        if (category.getColorHex() == null || category.getColorHex().trim().isEmpty()) {
            category.setColorHex("#4A90E2");
        }
        return categoryDao.createCategory(category);
    }

    public Category updateCategory(long userId, long id, Category category) throws Exception {
        Category existing = categoryDao.getCategoryById(id, userId);
        if (existing == null) {
            throw new IllegalArgumentException("Category not found");
        }
        category.setId(id);
        category.setUserId(userId);
        ValidationUtil.validateCategoryName(category.getName());
        if (category.getIconKey() == null || category.getIconKey().trim().isEmpty()) {
            category.setIconKey(existing.getIconKey());
        }
        if (category.getColorHex() == null || category.getColorHex().trim().isEmpty()) {
            category.setColorHex(existing.getColorHex());
        }
        return categoryDao.updateCategory(category);
    }

    public List<PaymentMethod> getPaymentMethods(long userId) throws Exception {
        return paymentMethodDao.getPaymentMethodsByUserId(userId);
    }
}
