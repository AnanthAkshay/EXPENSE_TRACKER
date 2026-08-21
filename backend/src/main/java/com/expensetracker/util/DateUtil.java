package com.expensetracker.util;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;

public class DateUtil {
    private static final DateTimeFormatter MONTH_YEAR_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM");

    public static String currentMonthYear() {
        return LocalDate.now().format(MONTH_YEAR_FORMATTER);
    }

    public static YearMonth parseMonthYear(String monthYearStr) {
        if (monthYearStr == null || monthYearStr.trim().isEmpty()) {
            return YearMonth.now();
        }
        try {
            return YearMonth.parse(monthYearStr, MONTH_YEAR_FORMATTER);
        } catch (Exception e) {
            return YearMonth.now();
        }
    }

    public static String formatMonthYear(YearMonth ym) {
        return ym.format(MONTH_YEAR_FORMATTER);
    }
}
