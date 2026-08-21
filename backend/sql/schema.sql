-- Personal Expense Tracker Schema & Seed Script

CREATE DATABASE IF NOT EXISTS expense_tracker DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE expense_tracker;

-- Drop tables in order of dependencies if resetting
DROP TABLE IF EXISTS goals;
DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    icon_key VARCHAR(50) NOT NULL,
    color_hex VARCHAR(7) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categories_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_category_name UNIQUE (user_id, name)
);

CREATE TABLE payment_methods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_pm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE expenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    payment_method_id BIGINT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    expense_date DATE NOT NULL,
    note VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_expenses_category FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT fk_expenses_payment FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    INDEX idx_expenses_user_date (user_id, expense_date),
    INDEX idx_expenses_user_category (user_id, category_id)
);

CREATE TABLE budgets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category_id BIGINT NULL, -- NULL = overall monthly budget
    month_year CHAR(7) NOT NULL, -- 'YYYY-MM'
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    CONSTRAINT fk_budgets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_budgets_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    CONSTRAINT uq_budget_scope UNIQUE (user_id, category_id, month_year)
);

CREATE TABLE goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    target_amount DECIMAL(12,2) NOT NULL CHECK (target_amount > 0),
    saved_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (saved_amount >= 0),
    target_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Seed Data for Default User
INSERT INTO users (id, email, display_name) VALUES (1, 'akshay@expensetracker.local', 'Akshay');

-- Seed Default Categories for User 1
INSERT INTO categories (user_id, name, icon_key, color_hex, is_default, is_archived) VALUES
(1, 'Food', 'utensils', '#FF6B6B', TRUE, FALSE),
(1, 'Transport', 'car', '#4D96FF', TRUE, FALSE),
(1, 'Shopping', 'shopping-bag', '#6BCB77', TRUE, FALSE),
(1, 'Bills', 'file-text', '#FFD93D', TRUE, FALSE),
(1, 'Entertainment', 'film', '#9D4EDD', TRUE, FALSE),
(1, 'Education', 'book-open', '#48CAE4', TRUE, FALSE),
(1, 'Health', 'activity', '#FF85A1', TRUE, FALSE),
(1, 'Travel', 'plane', '#00B4D8', TRUE, FALSE),
(1, 'Other', 'grid', '#8D99AE', TRUE, FALSE);

-- Seed Default Payment Methods for User 1
INSERT INTO payment_methods (user_id, name, is_default) VALUES
(1, 'Cash', TRUE),
(1, 'UPI', FALSE),
(1, 'Credit Card', FALSE),
(1, 'Debit Card', FALSE);
