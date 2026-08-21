package com.expensetracker.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Goal {
    private Long id;
    private Long userId;
    private String name;
    private BigDecimal targetAmount;
    private BigDecimal savedAmount;
    private Date targetDate;
    private Timestamp createdAt;

    // Calculated helper
    private BigDecimal suggestedMonthlyContribution;

    public Goal() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getTargetAmount() { return targetAmount; }
    public void setTargetAmount(BigDecimal targetAmount) { this.targetAmount = targetAmount; }

    public BigDecimal getSavedAmount() { return savedAmount; }
    public void setSavedAmount(BigDecimal savedAmount) { this.savedAmount = savedAmount; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public BigDecimal getSuggestedMonthlyContribution() { return suggestedMonthlyContribution; }
    public void setSuggestedMonthlyContribution(BigDecimal suggestedMonthlyContribution) { this.suggestedMonthlyContribution = suggestedMonthlyContribution; }
}
