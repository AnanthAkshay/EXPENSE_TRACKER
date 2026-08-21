package com.expensetracker.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Expense {
    private Long id;
    private Long userId;
    private Long categoryId;
    private Long paymentMethodId;
    private BigDecimal amount;
    private Date expenseDate;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined fields for easy presentation
    private String categoryName;
    private String categoryIconKey;
    private String categoryColorHex;
    private String paymentMethodName;

    public Expense() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }

    public Long getPaymentMethodId() { return paymentMethodId; }
    public void setPaymentMethodId(Long paymentMethodId) { this.paymentMethodId = paymentMethodId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public Date getExpenseDate() { return expenseDate; }
    public void setExpenseDate(Date expenseDate) { this.expenseDate = expenseDate; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategoryIconKey() { return categoryIconKey; }
    public void setCategoryIconKey(String categoryIconKey) { this.categoryIconKey = categoryIconKey; }

    public String getCategoryColorHex() { return categoryColorHex; }
    public void setCategoryColorHex(String categoryColorHex) { this.categoryColorHex = categoryColorHex; }

    public String getPaymentMethodName() { return paymentMethodName; }
    public void setPaymentMethodName(String paymentMethodName) { this.paymentMethodName = paymentMethodName; }
}
