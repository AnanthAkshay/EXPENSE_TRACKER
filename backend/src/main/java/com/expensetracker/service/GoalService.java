package com.expensetracker.service;

import com.expensetracker.dao.GoalDao;
import com.expensetracker.model.Goal;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

import java.util.List;

public class GoalService {

    private final GoalDao goalDao = new GoalDao();

    public List<Goal> getGoals(long userId) throws Exception {
        List<Goal> goals = goalDao.getGoalsByUserId(userId);
        LocalDate now = LocalDate.now();

        for (Goal g : goals) {
            BigDecimal target = g.getTargetAmount() != null ? g.getTargetAmount() : BigDecimal.ZERO;
            BigDecimal saved = g.getSavedAmount() != null ? g.getSavedAmount() : BigDecimal.ZERO;
            BigDecimal remaining = target.subtract(saved);

            if (remaining.compareTo(BigDecimal.ZERO) <= 0 || g.getTargetDate() == null) {
                g.setSuggestedMonthlyContribution(BigDecimal.ZERO);
            } else {
                LocalDate targetDate = g.getTargetDate().toLocalDate();
                long monthsLeft = java.time.temporal.ChronoUnit.MONTHS.between(now.withDayOfMonth(1), targetDate.withDayOfMonth(1));
                if (monthsLeft <= 0) {
                    g.setSuggestedMonthlyContribution(remaining);
                } else {
                    g.setSuggestedMonthlyContribution(remaining.divide(BigDecimal.valueOf(monthsLeft), 2, RoundingMode.HALF_UP));
                }
            }
        }
        return goals;
    }

    public Goal createGoal(long userId, Goal goal) throws Exception {
        goal.setUserId(userId);
        if (goal.getName() == null || goal.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("goal name is required");
        }
        if (goal.getTargetAmount() == null || goal.getTargetAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("targetAmount must be greater than 0");
        }
        return goalDao.createGoal(goal);
    }

    public Goal updateGoal(long userId, long id, Goal goal) throws Exception {
        Goal existing = goalDao.getGoalById(id, userId);
        if (existing == null) {
            throw new IllegalArgumentException("Goal not found");
        }
        goal.setId(id);
        goal.setUserId(userId);
        if (goal.getName() == null || goal.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("goal name is required");
        }
        if (goal.getTargetAmount() == null || goal.getTargetAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("targetAmount must be greater than 0");
        }
        return goalDao.updateGoal(goal);
    }

    public boolean deleteGoal(long userId, long id) throws Exception {
        return goalDao.deleteGoal(id, userId);
    }
}
