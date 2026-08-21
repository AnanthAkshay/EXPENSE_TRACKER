package com.expensetracker.model;

public class Insight {
    private String key;
    private String title;
    private String message;
    private double surpriseScore;

    public Insight() {}

    public Insight(String key, String title, String message, double surpriseScore) {
        this.key = key;
        this.title = title;
        this.message = message;
        this.surpriseScore = surpriseScore;
    }

    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public double getSurpriseScore() { return surpriseScore; }
    public void setSurpriseScore(double surpriseScore) { this.surpriseScore = surpriseScore; }
}
