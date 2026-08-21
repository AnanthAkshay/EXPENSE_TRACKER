package com.expensetracker.util;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;

public class ValidationUtil {
    public static void validateAmount(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("amount must be greater than 0");
        }
    }

    public static void validateExpenseDate(Date expenseDate) {
        if (expenseDate == null) {
            throw new IllegalArgumentException("expenseDate is required");
        }
        LocalDate date = expenseDate.toLocalDate();
        LocalDate maxAllowed = LocalDate.now().plusYears(1);
        if (date.isAfter(maxAllowed)) {
            throw new IllegalArgumentException("expenseDate cannot be absurdly far in the future");
        }
    }

    public static void validateNote(String note) {
        if (note != null && note.length() > 255) {
            throw new IllegalArgumentException("note cannot exceed 255 characters");
        }
    }

    public static void validateCategoryName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("category name is required");
        }
        if (name.trim().length() > 50) {
            throw new IllegalArgumentException("category name cannot exceed 50 characters");
        }
    }
}
