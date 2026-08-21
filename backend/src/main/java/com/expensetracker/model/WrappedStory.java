package com.expensetracker.model;

import java.math.BigDecimal;

public class WrappedStory {
    private String monthYear;
    private boolean sufficientData;
    private boolean isCurrentMonth;
    private int totalTransactions;
    
    private BigDecimal totalSpend;
    private String topCategoryName;
    private BigDecimal topCategoryAmount;
    private double topCategoryPercentage;
    
    private double weekendVsWeekdayDeltaPct; // positive means spent X% more on weekends
    private boolean weekendSpentMore;
    
    private String peakDate;
    private BigDecimal peakAmount;
    private int peakTransactionCount;
    
    private String mostFrequentExpenseName;
    private int mostFrequentCount;
    
    private BigDecimal momDeltaAmount;
    private boolean spentLessMoM;
    
    private BigDecimal projectedNextMonthSpend;
    
    private String personalityTag; // e.g. "The Foodie", "The Weekend Warrior", "The Grazer", "The Saver", "The Explorer", "The Big Spender", "The Steady Tracker"
    private String personalityDescription;

    public WrappedStory() {}

    public String getMonthYear() { return monthYear; }
    public void setMonthYear(String monthYear) { this.monthYear = monthYear; }

    public boolean isSufficientData() { return sufficientData; }
    public void setSufficientData(boolean sufficientData) { this.sufficientData = sufficientData; }

    public boolean isCurrentMonth() { return isCurrentMonth; }
    public void setCurrentMonth(boolean currentMonth) { isCurrentMonth = currentMonth; }

    public int getTotalTransactions() { return totalTransactions; }
    public void setTotalTransactions(int totalTransactions) { this.totalTransactions = totalTransactions; }

    public BigDecimal getTotalSpend() { return totalSpend; }
    public void setTotalSpend(BigDecimal totalSpend) { this.totalSpend = totalSpend; }

    public String getTopCategoryName() { return topCategoryName; }
    public void setTopCategoryName(String topCategoryName) { this.topCategoryName = topCategoryName; }

    public BigDecimal getTopCategoryAmount() { return topCategoryAmount; }
    public void setTopCategoryAmount(BigDecimal topCategoryAmount) { this.topCategoryAmount = topCategoryAmount; }

    public double getTopCategoryPercentage() { return topCategoryPercentage; }
    public void setTopCategoryPercentage(double topCategoryPercentage) { this.topCategoryPercentage = topCategoryPercentage; }

    public double getWeekendVsWeekdayDeltaPct() { return weekendVsWeekdayDeltaPct; }
    public void setWeekendVsWeekdayDeltaPct(double weekendVsWeekdayDeltaPct) { this.weekendVsWeekdayDeltaPct = weekendVsWeekdayDeltaPct; }

    public boolean isWeekendSpentMore() { return weekendSpentMore; }
    public void setWeekendSpentMore(boolean weekendSpentMore) { this.weekendSpentMore = weekendSpentMore; }

    public String getPeakDate() { return peakDate; }
    public void setPeakDate(String peakDate) { this.peakDate = peakDate; }

    public BigDecimal getPeakAmount() { return peakAmount; }
    public void setPeakAmount(BigDecimal peakAmount) { this.peakAmount = peakAmount; }

    public int getPeakTransactionCount() { return peakTransactionCount; }
    public void setPeakTransactionCount(int peakTransactionCount) { this.peakTransactionCount = peakTransactionCount; }

    public String getMostFrequentExpenseName() { return mostFrequentExpenseName; }
    public void setMostFrequentExpenseName(String mostFrequentExpenseName) { this.mostFrequentExpenseName = mostFrequentExpenseName; }

    public int getMostFrequentCount() { return mostFrequentCount; }
    public void setMostFrequentCount(int mostFrequentCount) { this.mostFrequentCount = mostFrequentCount; }

    public BigDecimal getMomDeltaAmount() { return momDeltaAmount; }
    public void setMomDeltaAmount(BigDecimal momDeltaAmount) { this.momDeltaAmount = momDeltaAmount; }

    public boolean isSpentLessMoM() { return spentLessMoM; }
    public void setSpentLessMoM(boolean spentLessMoM) { this.spentLessMoM = spentLessMoM; }

    public BigDecimal getProjectedNextMonthSpend() { return projectedNextMonthSpend; }
    public void setProjectedNextMonthSpend(BigDecimal projectedNextMonthSpend) { this.projectedNextMonthSpend = projectedNextMonthSpend; }

    public String getPersonalityTag() { return personalityTag; }
    public void setPersonalityTag(String personalityTag) { this.personalityTag = personalityTag; }

    public String getPersonalityDescription() { return personalityDescription; }
    public void setPersonalityDescription(String personalityDescription) { this.personalityDescription = personalityDescription; }
}
