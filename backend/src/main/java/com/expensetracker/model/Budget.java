package com.expensetracker.model;

import java.math.BigDecimal;

public class Budget {
    private Long id;
    private Long userId;
    private Long categoryId; // null = overall monthly budget
    private String monthYear; // 'YYYY-MM'
    private BigDecimal amount;

    // Joined / calculated fields
    private String categoryName;
    private String categoryIconKey;
    private String categoryColorHex;
    private BigDecimal spent;
    private BigDecimal remaining;
    private Double pctUsed;
    private Integer daysLeft;
    private BigDecimal projected;

    public Budget() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }

    public String getMonthYear() { return monthYear; }
    public void setMonthYear(String monthYear) { this.monthYear = monthYear; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategoryIconKey() { return categoryIconKey; }
    public void setCategoryIconKey(String categoryIconKey) { this.categoryIconKey = categoryIconKey; }

    public String getCategoryColorHex() { return categoryColorHex; }
    public void setCategoryColorHex(String categoryColorHex) { this.categoryColorHex = categoryColorHex; }

    public BigDecimal getSpent() { return spent; }
    public void setSpent(BigDecimal spent) { this.spent = spent; }

    public BigDecimal getRemaining() { return remaining; }
    public void setRemaining(BigDecimal remaining) { this.remaining = remaining; }

    public Double getPctUsed() { return pctUsed; }
    public void setPctUsed(Double pctUsed) { this.pctUsed = pctUsed; }

    public Integer getDaysLeft() { return daysLeft; }
    public void setDaysLeft(Integer daysLeft) { this.daysLeft = daysLeft; }

    public BigDecimal getProjected() { return projected; }
    public void setProjected(BigDecimal projected) { this.projected = projected; }
}
