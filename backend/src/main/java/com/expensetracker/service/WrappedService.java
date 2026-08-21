package com.expensetracker.service;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.dao.BudgetDao;
import com.expensetracker.dao.ExpenseDao;
import com.expensetracker.model.Budget;
import com.expensetracker.model.Expense;
import com.expensetracker.model.WrappedStory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;

public class WrappedService {

    private final ExpenseDao expenseDao = new ExpenseDao();
    private final BudgetDao budgetDao = new BudgetDao();

    public WrappedStory generateWrappedStory(long userId, String monthYearStr) throws Exception {
        YearMonth targetYm = YearMonth.parse(monthYearStr, DateTimeFormatter.ofPattern("yyyy-MM"));
        YearMonth currentYm = YearMonth.now();

        LocalDate startDate = targetYm.atDay(1);
        LocalDate endDate = targetYm.atEndOfMonth();
        Date startSql = Date.valueOf(startDate);
        Date endSql = Date.valueOf(endDate);

        WrappedStory story = new WrappedStory();
        story.setMonthYear(monthYearStr);
        story.setCurrentMonth(targetYm.equals(currentYm));

        int totalTxCount = expenseDao.countExpenses(userId, startSql, endSql, null, null);
        story.setTotalTransactions(totalTxCount);

        if (totalTxCount < 5) {
            story.setSufficientData(false);
            BigDecimal total = expenseDao.getTotalSpendForPeriod(userId, startSql, endSql);
            story.setTotalSpend(total);
            var catBreakdown = expenseDao.getCategoryBreakdown(userId, startSql, endSql, 1);
            if (!catBreakdown.isEmpty()) {
                story.setTopCategoryName((String) catBreakdown.get(0).get("name"));
                story.setTopCategoryAmount((BigDecimal) catBreakdown.get(0).get("amount"));
            }
            story.setPersonalityTag("The Beginner");
            story.setPersonalityDescription("Log at least 5 expenses to unlock your full monthly story!");
            return story;
        }

        story.setSufficientData(true);

        // Slide 2: Total spend
        BigDecimal totalSpend = expenseDao.getTotalSpendForPeriod(userId, startSql, endSql);
        story.setTotalSpend(totalSpend);

        // Slide 3: Top category
        var catBreakdown = expenseDao.getCategoryBreakdown(userId, startSql, endSql, 1);
        if (!catBreakdown.isEmpty()) {
            var topCat = catBreakdown.get(0);
            story.setTopCategoryName((String) topCat.get("name"));
            BigDecimal topAmt = (BigDecimal) topCat.get("amount");
            story.setTopCategoryAmount(topAmt);
            if (totalSpend.compareTo(BigDecimal.ZERO) > 0) {
                double pct = (topAmt.doubleValue() / totalSpend.doubleValue()) * 100.0;
                story.setTopCategoryPercentage(Math.round(pct * 10.0) / 10.0);
            }
        }

        // Slide 4: Weekend vs Weekday
        calculateWeekendVsWeekday(userId, startSql, endSql, story);

        // Slide 5: Peak Day
        var peakDayMap = expenseDao.getHighestSpendingDay(userId, startSql, endSql);
        if (peakDayMap != null) {
            story.setPeakDate((String) peakDayMap.get("date"));
            story.setPeakAmount((BigDecimal) peakDayMap.get("amount"));
            story.setPeakTransactionCount((int) peakDayMap.get("count"));
        }

        // Slide 6: Most Frequent Expense
        calculateMostFrequent(userId, startSql, endSql, story);

        // Slide 7: Month-over-Month Delta
        YearMonth prevYm = targetYm.minusMonths(1);
        Date prevStartSql = Date.valueOf(prevYm.atDay(1));
        Date prevEndSql = Date.valueOf(prevYm.atEndOfMonth());
        BigDecimal prevTotal = expenseDao.getTotalSpendForPeriod(userId, prevStartSql, prevEndSql);
        if (prevTotal.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal delta = totalSpend.subtract(prevTotal);
            story.setMomDeltaAmount(delta.abs());
            story.setSpentLessMoM(delta.compareTo(BigDecimal.ZERO) <= 0);
        }

        // Slide 8: Next Month Projection (if >= 10 transactions)
        if (totalTxCount >= 10) {
            int days = targetYm.lengthOfMonth();
            BigDecimal dailyAvg = totalSpend.divide(BigDecimal.valueOf(days), 2, RoundingMode.HALF_UP);
            YearMonth nextYm = targetYm.plusMonths(1);
            BigDecimal projNextMonth = dailyAvg.multiply(BigDecimal.valueOf(nextYm.lengthOfMonth()));
            story.setProjectedNextMonthSpend(projNextMonth);
        }

        // Slide 9: Spending Personality Tag Calculation
        computePersonalityTag(userId, story, totalSpend, startSql, endSql, monthYearStr);

        return story;
    }

    private void calculateWeekendVsWeekday(long userId, Date startSql, Date endSql, WrappedStory story) {
        String sql = "SELECT " +
                "AVG(CASE WHEN DAYOFWEEK(expense_date) IN (1, 7) THEN day_total END) AS wnd_avg, " +
                "AVG(CASE WHEN DAYOFWEEK(expense_date) NOT IN (1, 7) THEN day_total END) AS wkd_avg " +
                "FROM (SELECT expense_date, SUM(amount) AS day_total FROM expenses " +
                "WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? GROUP BY expense_date) t";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, startSql);
            ps.setDate(3, endSql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double wnd = rs.getDouble("wnd_avg");
                    double wkd = rs.getDouble("wkd_avg");
                    if (wkd > 0) {
                        double deltaPct = ((wnd - wkd) / wkd) * 100.0;
                        story.setWeekendVsWeekdayDeltaPct(Math.round(Math.abs(deltaPct) * 10.0) / 10.0);
                        story.setWeekendSpentMore(deltaPct > 0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void calculateMostFrequent(long userId, Date startSql, Date endSql, WrappedStory story) {
        String sql = "SELECT c.name, ROUND(e.amount, -1) AS approx_amt, COUNT(e.id) AS cnt " +
                "FROM expenses e JOIN categories c ON e.category_id = c.id " +
                "WHERE e.user_id = ? AND e.expense_date >= ? AND e.expense_date <= ? " +
                "GROUP BY c.id, c.name, ROUND(e.amount, -1) ORDER BY cnt DESC LIMIT 1";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, startSql);
            ps.setDate(3, endSql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String catName = rs.getString("name");
                    double amt = rs.getDouble("approx_amt");
                    int cnt = rs.getInt("cnt");
                    story.setMostFrequentExpenseName(String.format("~₹%.0f in %s", amt, catName));
                    story.setMostFrequentCount(cnt);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computePersonalityTag(long userId, WrappedStory story, BigDecimal totalSpend, Date startSql, Date endSql, String monthYearStr) throws Exception {
        // Rule 1: Top category > 40% AND Food
        if (story.getTopCategoryPercentage() > 40.0 && "Food".equalsIgnoreCase(story.getTopCategoryName())) {
            story.setPersonalityTag("The Foodie");
            story.setPersonalityDescription("Flavors over savings — culinary expenses dominated your monthly budget.");
            return;
        }

        // Rule 2: Weekend spend > 50% higher than weekday
        if (story.isWeekendSpentMore() && story.getWeekendVsWeekdayDeltaPct() > 50.0) {
            story.setPersonalityTag("The Weekend Warrior");
            story.setPersonalityDescription("Frugal weekdays made way for high-energy weekend spending.");
            return;
        }

        // Rule 3: Small purchase count > 20
        int smallCount = 0;
        String smallSql = "SELECT COUNT(*) FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? AND amount < 200";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(smallSql)) {
            ps.setLong(1, userId);
            ps.setDate(2, startSql);
            ps.setDate(3, endSql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    smallCount = rs.getInt(1);
                }
            }
        }
        if (smallCount > 20) {
            story.setPersonalityTag("The Grazer");
            story.setPersonalityDescription("A high frequency of micro-purchases added up across your month.");
            return;
        }

        // Rule 4: Month total <= overall budget by > 15%
        Budget overallBudget = budgetDao.getBudgetByScope(userId, null, monthYearStr);
        if (overallBudget != null && overallBudget.getAmount().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal budgetAmt = overallBudget.getAmount();
            if (totalSpend.compareTo(budgetAmt) <= 0) {
                BigDecimal remaining = budgetAmt.subtract(totalSpend);
                double underPct = (remaining.doubleValue() / budgetAmt.doubleValue()) * 100.0;
                if (underPct > 15.0) {
                    story.setPersonalityTag("The Saver");
                    story.setPersonalityDescription("Impressive discipline — you finished well below your overall budget threshold.");
                    return;
                }
            }
        }

        // Rule 5: Category diversity high (no single category > 25%)
        if (story.getTopCategoryPercentage() > 0 && story.getTopCategoryPercentage() <= 25.0) {
            story.setPersonalityTag("The Explorer");
            story.setPersonalityDescription("Well-rounded spending spread evenly across your life categories.");
            return;
        }

        // Rule 6: Largest single expense > 30% of total month spend
        Expense largest = expenseDao.getLargestExpense(userId, startSql, endSql);
        if (largest != null && totalSpend.compareTo(BigDecimal.ZERO) > 0) {
            double largestPct = (largest.getAmount().doubleValue() / totalSpend.doubleValue()) * 100.0;
            if (largestPct > 30.0) {
                story.setPersonalityTag("The Big Spender");
                story.setPersonalityDescription("One major purchase anchor defined your month's finances.");
                return;
            }
        }

        // Default Rule
        story.setPersonalityTag("The Steady Tracker");
        story.setPersonalityDescription("Consistent, mindful, and deliberate expense tracking all month long.");
    }
}
