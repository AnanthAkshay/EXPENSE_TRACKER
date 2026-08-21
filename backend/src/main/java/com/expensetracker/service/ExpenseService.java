package com.expensetracker.service;

import com.expensetracker.dao.CategoryDao;
import com.expensetracker.dao.ExpenseDao;
import com.expensetracker.dao.PaymentMethodDao;
import com.expensetracker.model.Category;
import com.expensetracker.model.Expense;
import com.expensetracker.model.PaymentMethod;
import com.expensetracker.util.ValidationUtil;

import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExpenseService {

    private final ExpenseDao expenseDao = new ExpenseDao();
    private final CategoryDao categoryDao = new CategoryDao();
    private final PaymentMethodDao paymentMethodDao = new PaymentMethodDao();

    public Expense createExpense(long userId, Expense expense) throws Exception {
        expense.setUserId(userId);
        ValidationUtil.validateAmount(expense.getAmount());
        ValidationUtil.validateExpenseDate(expense.getExpenseDate());
        ValidationUtil.validateNote(expense.getNote());

        if (expense.getCategoryId() == null) {
            throw new IllegalArgumentException("categoryId is required");
        }

        Category cat = categoryDao.getCategoryById(expense.getCategoryId(), userId);
        if (cat == null) {
            throw new IllegalArgumentException("Category does not exist or belong to user");
        }

        if (expense.getPaymentMethodId() != null) {
            PaymentMethod pm = paymentMethodDao.getPaymentMethodById(expense.getPaymentMethodId(), userId);
            if (pm == null) {
                throw new IllegalArgumentException("Payment method does not exist or belong to user");
            }
        }

        return expenseDao.createExpense(expense);
    }

    public Expense getExpenseById(long userId, long id) throws Exception {
        Expense expense = expenseDao.getExpenseById(id, userId);
        if (expense == null) {
            throw new IllegalArgumentException("Expense not found");
        }
        return expense;
    }

    public Expense updateExpense(long userId, long id, Expense expense) throws Exception {
        Expense existing = expenseDao.getExpenseById(id, userId);
        if (existing == null) {
            throw new IllegalArgumentException("Expense not found");
        }

        expense.setId(id);
        expense.setUserId(userId);
        ValidationUtil.validateAmount(expense.getAmount());
        ValidationUtil.validateExpenseDate(expense.getExpenseDate());
        ValidationUtil.validateNote(expense.getNote());

        if (expense.getCategoryId() == null) {
            throw new IllegalArgumentException("categoryId is required");
        }

        Category cat = categoryDao.getCategoryById(expense.getCategoryId(), userId);
        if (cat == null) {
            throw new IllegalArgumentException("Category does not exist or belong to user");
        }

        if (expense.getPaymentMethodId() != null) {
            PaymentMethod pm = paymentMethodDao.getPaymentMethodById(expense.getPaymentMethodId(), userId);
            if (pm == null) {
                throw new IllegalArgumentException("Payment method does not exist or belong to user");
            }
        }

        return expenseDao.updateExpense(expense);
    }

    public boolean deleteExpense(long userId, long id) throws Exception {
        return expenseDao.deleteExpense(id, userId);
    }

    public Map<String, Object> getExpenses(long userId, Date from, Date to, Long categoryId, String search, String sort, int page, int size) throws Exception {
        if (page < 1) page = 1;
        if (size < 1 || size > 100) size = 20;

        List<Expense> items = expenseDao.getExpenses(userId, from, to, categoryId, search, sort, page, size);
        int total = expenseDao.countExpenses(userId, from, to, categoryId, search);

        Map<String, Object> response = new HashMap<>();
        response.put("items", items);
        response.put("total", total);
        response.put("page", page);
        response.put("size", size);
        return response;
    }
}
