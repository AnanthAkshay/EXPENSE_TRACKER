package com.expensetracker.service;

import com.expensetracker.config.DBConnectionManager;
import com.expensetracker.dao.ExpenseDao;
import com.expensetracker.model.Expense;
import com.expensetracker.model.Insight;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.*;

public class AnalyticsService {

    private final ExpenseDao expenseDao = new ExpenseDao();

    public Map<String, Object> getDashboardData(long userId) throws Exception {
        LocalDate now = LocalDate.now();
        LocalDate firstOfThisMonth = now.withDayOfMonth(1);
        LocalDate firstOfLastMonth = firstOfThisMonth.minusMonths(1);
        LocalDate lastOfLastMonth = firstOfThisMonth.minusDays(1);

        Date todaySql = Date.valueOf(now);
        Date firstOfThisMonthSql = Date.valueOf(firstOfThisMonth);
        Date firstOfLastMonthSql = Date.valueOf(firstOfLastMonth);
        Date lastOfLastMonthSql = Date.valueOf(lastOfLastMonth);

        // Totals
        BigDecimal todayTotal = expenseDao.getTotalSpendForPeriod(userId, todaySql, todaySql);
        
        // 7-day total
        Date sevenDaysAgoSql = Date.valueOf(now.minusDays(6));
        BigDecimal weekTotal = expenseDao.getTotalSpendForPeriod(userId, sevenDaysAgoSql, todaySql);

        BigDecimal monthTotal = expenseDao.getTotalSpendForPeriod(userId, firstOfThisMonthSql, todaySql);
        BigDecimal lastMonthTotal = expenseDao.getTotalSpendForPeriod(userId, firstOfLastMonthSql, lastOfLastMonthSql);

        // Delta %
        double monthDeltaPct = 0.0;
        if (lastMonthTotal.compareTo(BigDecimal.ZERO) > 0) {
            monthDeltaPct = monthTotal.subtract(lastMonthTotal)
                    .divide(lastMonthTotal, 4, RoundingMode.HALF_UP)
                    .doubleValue() * 100.0;
        }

        // Daily average
        int daysElapsed = now.getDayOfMonth();
        BigDecimal avgDailySpend = daysElapsed > 0 ? monthTotal.divide(BigDecimal.valueOf(daysElapsed), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO;

        // Highest spending day & largest expense
        Map<String, Object> highestDay = expenseDao.getHighestSpendingDay(userId, firstOfThisMonthSql, todaySql);
        Expense largestExpense = expenseDao.getLargestExpense(userId, firstOfThisMonthSql, todaySql);

        // Category breakdown top 5
        List<Map<String, Object>> categoryBreakdown = expenseDao.getCategoryBreakdown(userId, firstOfThisMonthSql, todaySql, 5);

        // 7-day timeline
        List<Map<String, Object>> timeline7Days = expenseDao.getDailyTimeline(userId, sevenDaysAgoSql, todaySql);

        // Recent transactions (last 5)
        List<Expense> recentTransactions = expenseDao.getExpenses(userId, null, null, null, null, "date_desc", 1, 5);

        // Top insight
        List<Insight> insights = calculateInsights(userId, YearMonth.from(now));
        Insight topInsight = insights.isEmpty() ? null : insights.get(0);

        Map<String, Object> result = new HashMap<>();
        result.put("todayTotal", todayTotal);
        result.put("weekTotal", weekTotal);
        result.put("monthTotal", monthTotal);
        result.put("lastMonthTotal", lastMonthTotal);
        result.put("monthDeltaPct", monthDeltaPct);
        result.put("avgDailySpend", avgDailySpend);
        result.put("highestSpendingDay", highestDay);
        result.put("largestExpense", largestExpense);
        result.put("categoryBreakdown", categoryBreakdown);
        result.put("timeline7Days", timeline7Days);
        result.put("recentTransactions", recentTransactions);
        result.put("topInsight", topInsight);

        return result;
    }

    public List<Map<String, Object>> getTrends(long userId, String period) throws Exception {
        LocalDate now = LocalDate.now();
        LocalDate fromDate;
        if ("week".equalsIgnoreCase(period)) {
            fromDate = now.minusDays(6);
        } else if ("quarter".equalsIgnoreCase(period)) {
            fromDate = now.minusMonths(3);
        } else { // month
            fromDate = now.withDayOfMonth(1);
        }
        return expenseDao.getDailyTimeline(userId, Date.valueOf(fromDate), Date.valueOf(now));
    }

    public List<Map<String, Object>> getCalendarHeatmap(long userId, YearMonth yearMonth) throws Exception {
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        return expenseDao.getDailyTimeline(userId, Date.valueOf(start), Date.valueOf(end));
    }

    public List<Insight> calculateInsights(long userId, YearMonth yearMonth) throws Exception {
        List<Insight> list = new ArrayList<>();
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        Date startSql = Date.valueOf(start);
        Date endSql = Date.valueOf(end);

        // Count expenses this month
        int countThisMonth = expenseDao.countExpenses(userId, startSql, endSql, null, null);
        if (countThisMonth < 5) {
            // Suppress insights when fewer than 5 transactions logged
            return list;
        }

        YearMonth prevMonth = yearMonth.minusMonths(1);
        Date prevStartSql = Date.valueOf(prevMonth.atDay(1));
        Date prevEndSql = Date.valueOf(prevMonth.atEndOfMonth());

        // 1. Weekend vs Weekday Spend Delta
        computeWeekendVsWeekdayInsight(userId, startSql, endSql, list);

        // 2. Category Trend Insight
        computeCategoryTrendInsight(userId, startSql, endSql, prevStartSql, prevEndSql, list);

        // 3. Daily Average Trend
        computeDailyAvgTrendInsight(userId, yearMonth, prevMonth, list);

        // 4. Most Frequent Expense
        computeMostFrequentExpenseInsight(userId, startSql, endSql, list);

        // 5. Pareto Concentration Insight
        computeParetoInsight(userId, startSql, endSql, list);

        // 6. Small Purchases Count (< 200)
        computeSmallPurchasesInsight(userId, startSql, endSql, list);

        // 7. Highest Spending Weekday Pattern
        computeWeekdayPatternInsight(userId, startSql, endSql, list);

        // Sort by surprise score descending
        list.sort((a, b) -> Double.compare(b.getSurpriseScore(), a.getSurpriseScore()));

        return list;
    }

    private void computeWeekendVsWeekdayInsight(long userId, Date startSql, Date endSql, List<Insight> list) {
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
                    if (wkd > 0 && wnd > 0) {
                        double deltaPct = Math.abs((wnd - wkd) / wkd * 100.0);
                        if (wnd > wkd) {
                            list.add(new Insight("WEEKEND_SPEND", "Weekend Spending Pattern",
                                    String.format("You spent %.0f%% more per day on weekends than weekdays this month.", deltaPct),
                                    deltaPct));
                        } else {
                            list.add(new Insight("WEEKDAY_SPEND", "Weekday Spending Focus",
                                    String.format("Your daily weekday spending is %.0f%% higher than weekend spending.", deltaPct),
                                    deltaPct / 2.0));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeCategoryTrendInsight(long userId, Date startSql, Date endSql, Date prevStartSql, Date prevEndSql, List<Insight> list) {
        String sql = "SELECT c.name, " +
                "COALESCE(SUM(CASE WHEN e.expense_date >= ? AND e.expense_date <= ? THEN e.amount ELSE 0 END), 0) AS cur_tot, " +
                "COALESCE(SUM(CASE WHEN e.expense_date >= ? AND e.expense_date <= ? THEN e.amount ELSE 0 END), 0) AS prev_tot " +
                "FROM expenses e JOIN categories c ON e.category_id = c.id " +
                "WHERE e.user_id = ? GROUP BY c.id, c.name HAVING cur_tot > 0 AND prev_tot > 0 " +
                "ORDER BY ABS(cur_tot - prev_tot) DESC LIMIT 1";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, startSql);
            ps.setDate(2, endSql);
            ps.setDate(3, prevStartSql);
            ps.setDate(4, prevEndSql);
            ps.setLong(5, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String catName = rs.getString("name");
                    double cur = rs.getDouble("cur_tot");
                    double prev = rs.getDouble("prev_tot");
                    double deltaPct = ((cur - prev) / prev) * 100.0;
                    if (Math.abs(deltaPct) >= 15) {
                        String direction = deltaPct > 0 ? "increased by" : "decreased by";
                        list.add(new Insight("CATEGORY_TREND", "Category Shift",
                                String.format("%s spending %s %.0f%% compared to last month.", catName, direction, Math.abs(deltaPct)),
                                Math.abs(deltaPct)));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeDailyAvgTrendInsight(long userId, YearMonth ym, YearMonth prevYm, List<Insight> list) {
        try {
            Date startSql = Date.valueOf(ym.atDay(1));
            Date endSql = Date.valueOf(ym.atEndOfMonth());
            Date prevStartSql = Date.valueOf(prevYm.atDay(1));
            Date prevEndSql = Date.valueOf(prevYm.atEndOfMonth());

            BigDecimal curTotal = expenseDao.getTotalSpendForPeriod(userId, startSql, endSql);
            BigDecimal prevTotal = expenseDao.getTotalSpendForPeriod(userId, prevStartSql, prevEndSql);

            int curDays = LocalDate.now().getMonth() == ym.getMonth() ? LocalDate.now().getDayOfMonth() : ym.lengthOfMonth();
            int prevDays = prevYm.lengthOfMonth();

            double curAvg = curTotal.doubleValue() / Math.max(1, curDays);
            double prevAvg = prevTotal.doubleValue() / Math.max(1, prevDays);

            if (prevAvg > 0) {
                double deltaPct = ((curAvg - prevAvg) / prevAvg) * 100.0;
                if (Math.abs(deltaPct) >= 10) {
                    String status = deltaPct > 0 ? "higher" : "lower";
                    list.add(new Insight("DAILY_AVG_TREND", "Daily Pace",
                            String.format("Your daily average spend is %.0f%% %s than last month's pace.", Math.abs(deltaPct), status),
                            Math.abs(deltaPct)));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeMostFrequentExpenseInsight(long userId, Date startSql, Date endSql, List<Insight> list) {
        String sql = "SELECT c.name, ROUND(e.amount, -1) AS approx_amt, COUNT(e.id) AS cnt " +
                "FROM expenses e JOIN categories c ON e.category_id = c.id " +
                "WHERE e.user_id = ? AND e.expense_date >= ? AND e.expense_date <= ? " +
                "GROUP BY c.id, c.name, ROUND(e.amount, -1) " +
                "HAVING cnt >= 3 ORDER BY cnt DESC LIMIT 1";

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
                    list.add(new Insight("FREQUENT_EXPENSE", "Repeat Habit",
                            String.format("You logged ~₹%.0f in %s %d times this month.", amt, catName, cnt),
                            cnt * 10.0));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeParetoInsight(long userId, Date startSql, Date endSql, List<Insight> list) {
        try {
            List<Map<String, Object>> catList = expenseDao.getCategoryBreakdown(userId, startSql, endSql, 0);
            BigDecimal totalMonth = expenseDao.getTotalSpendForPeriod(userId, startSql, endSql);

            if (totalMonth.compareTo(BigDecimal.ZERO) > 0 && !catList.isEmpty()) {
                double cumulative = 0.0;
                int topCount = 0;
                for (Map<String, Object> cat : catList) {
                    topCount++;
                    BigDecimal amt = (BigDecimal) cat.get("amount");
                    cumulative += (amt.doubleValue() / totalMonth.doubleValue()) * 100.0;
                    if (cumulative >= 80.0) {
                        break;
                    }
                }

                if (topCount == 1) {
                    String topName = (String) catList.get(0).get("name");
                    list.add(new Insight("PARETO_CONCENTRATION", "Concentrated Spending",
                            String.format("%s accounts for over 80%% of your total spend this month.", topName),
                            85.0));
                } else if (topCount <= 2 && catList.size() >= 4) {
                    list.add(new Insight("PARETO_CONCENTRATION", "Top Heavy Expenses",
                            String.format("Just %d categories account for over 80%% of your spending.", topCount),
                            75.0));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeSmallPurchasesInsight(long userId, Date startSql, Date endSql, List<Insight> list) {
        String sql = "SELECT COUNT(*) FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? AND amount < 200";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, startSql);
            ps.setDate(3, endSql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    if (count >= 5) {
                        list.add(new Insight("SMALL_PURCHASES", "Micro-Expenses",
                                String.format("You made %d purchases under ₹200 this month.", count),
                                count * 3.0));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void computeWeekdayPatternInsight(long userId, Date startSql, Date endSql, List<Insight> list) {
        String sql = "SELECT DAYOFWEEK(expense_date) AS dow, AVG(amount) AS avg_amt " +
                "FROM expenses WHERE user_id = ? AND expense_date >= ? AND expense_date <= ? " +
                "GROUP BY dow ORDER BY avg_amt DESC LIMIT 1";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setDate(2, startSql);
            ps.setDate(3, endSql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int dow = rs.getInt("dow"); // 1=Sun, 2=Mon... 7=Sat
                    DayOfWeek dayOfWeek = DayOfWeek.of(dow == 1 ? 7 : dow - 1);
                    String dayName = dayOfWeek.getDisplayName(TextStyle.FULL, Locale.ENGLISH);
                    double avgAmt = rs.getDouble("avg_amt");
                    list.add(new Insight("PEAK_WEEKDAY", "Peak Day Trend",
                            String.format("%ss are historically your highest spending day (avg ₹%.0f).", dayName, avgAmt),
                            50.0));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
