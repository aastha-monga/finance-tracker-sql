CREATE DATABASE finance_tracker;
USE finance_tracker;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    budget_limit DECIMAL(10,2)
);

CREATE TABLE transactions(
transaction_id INT AUTO_INCREMENT PRIMARY KEY,
category_id INT NOT NULL,
amount DECIMAL(9,2),
payment_mode VARCHAR(10) NOT NULL,
transaction_date DATE,
discription VARCHAR(50),
FOREIGN KEY(category_id) REFERENCES categories(category_id)
);

CREATE TABLE budgets(
budget_id INT AUTO_INCREMENT PRIMARY KEY,
category_id INT NOT NULL,
budget_amount DECIMAL(10,2),
month VARCHAR(7),
FOREIGN KEY(category_id) REFERENCES categories(category_id) 
);

SHOW TABLES;

INSERT INTO categories (category_name,budget_limit)
VALUES
('Clothes', 20000.00 ),
('Stationary' , 1000.00),
('Fast Food', 10000.00),
('Grocery', 3000.00),
('Travel', 3000.00),
('Bills', 9000.00),
('other',2000.00);
SELECT * FROM categories;

INSERT INTO transactions (category_id, amount, payment_mode, transaction_date, discription)
VALUES
(1, 2000.00, 'cash', '2026-4-10', 'bought party dress'),
(3, 450.00, 'upi', '2026-6-3', 'bought oreo shake with momos'),
(4, 900.00, 'cash', '2026-4-10', 'kitchen and diet items'),
(5, 500.00, 'upi', '2026-5-10', 'went to hometown using cab'),
(3, 200.00, 'upi', '2026-4-18', 'bought noodles');
SELECT * FROM transactions;
delete FROM transactions;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM transactions;
SET SQL_SAFE_UPDATES = 1;

INSERT INTO budgets (category_id, budget_amount, month)
VALUES
(4, 2500.00, '2026-5'),
(3, 7600.00, '2026-6');
SELECT * FROM budgets;

SELECT 
	t.transaction_id,
	c.category_name,
	t.amount,
	t.payment_mode,
	t.discription
From transactions t
INNER JOIN categories c
ON t.category_id = c.category_id;

SELECT
	b.budget_id,
    c.category_name,
    c.budget_limit,
    b.budget_amount
FROM budgets b
INNER JOIN categories c 
ON b.category_id = c.category_id;

/*"How much did I spend on each category this month?" ..rollup-subtotal */

CREATE VIEW spending_by_category AS
SELECT category_name, SUM(amount) AS Total_spent
FROM transactions t
INNER JOIN categories c 
ON t.category_id = c.category_id
GROUP BY category_name WITH ROLLUP;

/* "Which payment mode do I use the most?" */

CREATE VIEW payment_mode_summary AS
SELECT payment_mode, COUNT(payment_mode) AS pay_mode_count
FROM transactions 
GROUP BY payment_mode
ORDER BY pay_mode_count DESC;

/* "Did I overspend my budget this month?" */

CREATE VIEW budget_vs_actual AS
SELECT c.category_name, 
	   b.budget_amount,
	SUM(t.amount) AS Actual_spent, 
    b.budget_amount - SUM(t.amount) AS remaining
FROM transactions t 
INNER JOIN categories c ON t.category_id = c.category_id
INNER JOIN budgets b ON b.category_id = c.category_id
GROUP BY c.category_name, b.budget_amount
HAVING SUM(t.amount) > b.budget_amount;

/* "How much did I spend in total this month?"  */

CREATE VIEW monthly_total AS
SELECT SUM(amount) AS total_spent
FROM transactions
WHERE MONTH(transaction_date) = MONTH(curdate())
AND YEAR(transaction_date) = YEAR(curdate());

/* "Which day did I spend the most?"*/

CREATE VIEW highest_spending_day AS
SELECT SUM(amount) as total_spent,transaction_date
FROM transactions
GROUP BY transaction_date
ORDER BY total_spent DESC
LIMIT 1;

/*  "Monthly spending summary" */

CREATE VIEW monthly_summary AS
SELECT SUM(amount) AS total_spent, MONTH(transaction_date) AS month, YEAR(transaction_date) AS year
FROM transactions
GROUP BY month,year
ORDER BY month,year;

SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';






