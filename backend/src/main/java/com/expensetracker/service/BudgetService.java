package com.expensetracker.service;

import com.expensetracker.dao.BudgetDao;
import com.expensetracker.dao.CategoryDao;
import com.expensetracker.dao.ExpenseDao;
import com.expensetracker.model.Budget;
import com.expensetracker.model.Category;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BudgetService {

    private final BudgetDao budgetDao = new BudgetDao();
    private final ExpenseDao expenseDao = new ExpenseDao();
    private final CategoryDao categoryDao = new CategoryDao();

    public Map<String, Object> getBudgetOverview(long userId, String monthYear) throws Exception {
        YearMonth ym = YearMonth.parse(monthYear);
        LocalDate start = ym.atDay(1);
        LocalDate end = ym.atEndOfMonth();
        Date startSql = Date.valueOf(start);
        Date endSql = Date.valueOf(end);

        LocalDate now = LocalDate.now();
        int daysLeft;
        int daysElapsed;
        if (now.isBefore(start)) {
            daysLeft = ym.lengthOfMonth();
            daysElapsed = 0;
        } else if (now.isAfter(end)) {
            daysLeft = 0;
            daysElapsed = ym.lengthOfMonth();
        } else {
            daysLeft = ym.lengthOfMonth() - now.getDayOfMonth();
            daysElapsed = now.getDayOfMonth();
        }

        // Fetch user's budgets for this month
        List<Budget> budgets = budgetDao.getBudgetsByMonthYear(userId, monthYear);

        Budget overallBudget = null;
        Map<Long, Budget> categoryBudgetsMap = new HashMap<>();

        for (Budget b : budgets) {
            if (b.getCategoryId() == null) {
                overallBudget = b;
            } else {
                categoryBudgetsMap.put(b.getCategoryId(), b);
            }
        }

        // Overall calculations
        BigDecimal totalSpent = expenseDao.getTotalSpendForPeriod(userId, startSql, endSql);
        Map<String, Object> overallMap = new HashMap<>();

        BigDecimal overallAmount = overallBudget != null ? overallBudget.getAmount() : BigDecimal.ZERO;
        overallMap.put("amount", overallAmount);
        overallMap.put("spent", totalSpent);
        BigDecimal remaining = overallAmount.subtract(totalSpent);
        overallMap.put("remaining", remaining);

        double pctUsed = 0.0;
        if (overallAmount.compareTo(BigDecimal.ZERO) > 0) {
            pctUsed = totalSpent.divide(overallAmount, 4, RoundingMode.HALF_UP).doubleValue() * 100.0;
        }
        overallMap.put("pctUsed", Math.round(pctUsed * 10.0) / 10.0);
        overallMap.put("daysLeft", daysLeft);

        // Projected calculation: linear projection from current daily average
        BigDecimal projected = BigDecimal.ZERO;
        if (daysElapsed > 0) {
            BigDecimal dailyAvg = totalSpent.divide(BigDecimal.valueOf(daysElapsed), 2, RoundingMode.HALF_UP);
            projected = dailyAvg.multiply(BigDecimal.valueOf(ym.lengthOfMonth()));
        }
        overallMap.put("projected", projected);

        // Categories budget list
        List<Category> allCategories = categoryDao.getCategoriesByUserId(userId, false);
        List<Map<String, Object>> catBudgetList = new ArrayList<>();

        var categoryBreakdown = expenseDao.getCategoryBreakdown(userId, startSql, endSql, 0);
        Map<Long, BigDecimal> catSpentMap = new HashMap<>();
        for (var map : categoryBreakdown) {
            catSpentMap.put((Long) map.get("categoryId"), (BigDecimal) map.get("amount"));
        }

        for (Category cat : allCategories) {
            Budget catBudget = categoryBudgetsMap.get(cat.getId());
            BigDecimal catAmount = catBudget != null ? catBudget.getAmount() : BigDecimal.ZERO;
            BigDecimal catSpent = catSpentMap.getOrDefault(cat.getId(), BigDecimal.ZERO);
            BigDecimal catRem = catAmount.subtract(catSpent);

            double catPct = 0.0;
            if (catAmount.compareTo(BigDecimal.ZERO) > 0) {
                catPct = catSpent.divide(catAmount, 4, RoundingMode.HALF_UP).doubleValue() * 100.0;
            }

            Map<String, Object> catMap = new HashMap<>();
            catMap.put("categoryId", cat.getId());
            catMap.put("categoryName", cat.getName());
            catMap.put("categoryIconKey", cat.getIconKey());
            catMap.put("categoryColorHex", cat.getColorHex());
            catMap.put("amount", catAmount);
            catMap.put("spent", catSpent);
            catMap.put("remaining", catRem);
            catMap.put("pctUsed", Math.round(catPct * 10.0) / 10.0);
            catBudgetList.add(catMap);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("overall", overallMap);
        response.put("categories", catBudgetList);
        return response;
    }

    public Budget upsertBudget(long userId, Long categoryId, String monthYear, BigDecimal amount) throws Exception {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("amount must be greater than or equal to 0");
        }
        return budgetDao.upsertBudget(userId, categoryId, monthYear, amount);
    }
}
