CREATE TABLE transactions(
	transaction_id VARCHAR(25),
	`date` DATE,
    `time` TIME,
 	transaction_type VARCHAR(30),
	merchant_category VARCHAR(30) ,
	amount INT,
	transaction_status VARCHAR(30),
	sender_cat VARCHAR(30),
	reciver_cat VARCHAR(30),
	sender_state VARCHAR(30),
	sender_bank VARCHAR(30),
	receiver_bank VARCHAR(30),
	device_type VARCHAR(30),
	network_type VARCHAR(30),
	fraud_flag INT,
	day_of_week VARCHAR(20),
	is_weekend INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions_csv.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM transactions LIMIT 10;

-- to delete duplicates but i have cleaned the data using excel before importing
DELETE FROM transactions
WHERE transaction_id IN (
    SELECT transaction_id FROM (
        SELECT transaction_id,
		ROW_NUMBER() OVER(PARTITION BY transaction_id, `date`, amount ORDER BY transaction_id) AS rnk
        FROM transactions
    ) AS ranked
    WHERE rnk > 1
);

SELECT SUM(CASE WHEN amount IS NULL OR amount <= 0 THEN 1 ELSE 0 END) AS invalid_transactions,
SUM(CASE WHEN fraud_flag NOT IN (0,1) THEN 1 ELSE 0 END) AS invalid_fraud_flags,
MIN(date) AS earliest_date, MAX(date) AS latest, 
SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_transactions
FROM transactions;

-- Overall Fraud Statistics
SELECT SUM(fraud_flag) AS total_fraud_transactions,
ROUND(AVG(fraud_flag)*100,2) AS fraud_rate_percentage,
ROUND(AVG(CASE WHEN fraud_flag = 1 THEN amount END), 2) AS average_fraud_amount,
ROUND(AVG(CASE WHEN fraud_flag = 0 THEN amount END), 2) AS average_legit_amount,
SUM(CASE WHEN fraud_flag = 1 THEN amount END) AS total_fraud_loss
FROM transactions;

-- Fraud Rate by Transaction Characteristics
SELECT transaction_type, merchant_category, COUNT(*) AS total_transactions, SUM(fraud_flag) AS fraud_count,
ROUND(AVG(fraud_flag) * 100 ,2) AS fraud_percentage, ROUND(AVG(amount),2) AS average_amount
FROM transactions
GROUP BY transaction_type, merchant_category
HAVING COUNT(*) > 70
ORDER BY fraud_percentage DESC;

-- do fraud rate increase in weekend 
SELECT is_weekend, SUM(fraud_flag) AS fraud_count, ROUND(AVG(fraud_flag) * 100 ,2) AS fraud_percentage
FROM transactions
GROUP BY is_weekend
ORDER BY fraud_percentage DESC;

-- fraud analysis by day of the week 
SELECT day_of_week, COUNT(*) AS total_transactions, SUM(fraud_flag) AS fraud_count, 
ROUND(AVG(fraud_flag) * 100 ,2) AS fraud_percentage
FROM transactions
GROUP BY day_of_week
ORDER BY fraud_percentage DESC;

-- hourly fraud analysis
WITH hourly_fraud AS (
    SELECT HOUR(time) as hour, COUNT(*) as transactions, SUM(fraud_flag) as fraud_count,
        ROUND(AVG(fraud_flag) * 100, 2) as fraud_rate, ROUND(AVG(amount), 2) as avg_amount
    FROM transactions
    GROUP BY HOUR(time)
)
SELECT *,
    CASE 
        WHEN fraud_rate > (SELECT AVG(fraud_rate) + STDDEV(fraud_rate) FROM hourly_fraud) 
        THEN 'High Risk Hour'
        ELSE 'Normal'
    END as risk_level
FROM hourly_fraud
ORDER BY fraud_rate DESC;

-- by sender state and bank
WITH geographic AS (
    SELECT sender_state, sender_bank, COUNT(*) as transactions, SUM(fraud_flag) as fraud_count,
        ROUND(AVG(fraud_flag) * 100, 2) as fraud_rate, ROUND(AVG(amount), 2) as avg_amount
    FROM transactions
    GROUP BY sender_state, sender_bank
)
SELECT *,
    CASE 
        WHEN fraud_rate > (SELECT AVG(fraud_rate) + STDDEV(fraud_rate) FROM geographic) 
        THEN 'High Risk Hour'
        ELSE 'Normal'
    END as risk_level
FROM geographic
ORDER BY fraud_rate DESC;

-- view for risk score
CREATE VIEW transaction_risk_scores AS
SELECT transaction_id, date, amount, merchant_category, sender_state, device_type, fraud_flag,
    (CASE 
        WHEN amount > 50000 THEN 3
        WHEN amount > 10000 THEN 2
        WHEN amount > 1000 THEN 1
        ELSE 0
    END +
    CASE 
        WHEN HOUR(time) BETWEEN 22 AND 6 THEN 2
        WHEN is_weekend = 1 THEN 1
        ELSE 0
    END +
    CASE 
        WHEN device_type = 'Mobile' AND network_type = 'Public WiFi' THEN 2
        WHEN device_type = 'Mobile' THEN 1
        ELSE 0
    END) as calculated_risk_score,
    CASE 
        WHEN fraud_flag = 1 THEN 'ACTUAL FRAUD'
        WHEN (amount > 50000 AND HOUR(time) BETWEEN 22 AND 6) THEN 'HIGH RISK'
        WHEN (amount > 10000 OR is_weekend = 1) THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as risk_category
FROM transactions;

WITH bank_stats AS (
    SELECT sender_bank, receiver_bank, `date`, COUNT(*) AS total_txns, SUM(fraud_flag) AS fraud_txns,
        ROUND(SUM(fraud_flag)/COUNT(*) * 100, 2) AS fraud_rate
    FROM transactions
    GROUP BY sender_bank, receiver_bank, `date`
    HAVING total_txns >= 5
)
SELECT *
FROM bank_stats
WHERE fraud_rate >= (SELECT AVG(fraud_rate) + STDDEV(fraud_rate) FROM bank_stats)
ORDER BY fraud_rate DESC, total_txns DESC;

SELECT device_type, network_type, ROUND(SUM(fraud_flag)/COUNT(*) * 100, 2) AS fraud_rate
FROM transactions
GROUP BY device_type, network_type
ORDER BY fraud_rate DESC;

-- customer Category Performance Analysis
SELECT sender_cat,reciver_cat, COUNT(*) as transaction_count, ROUND(AVG(amount), 2) as avg_amount,
    SUM(amount) as total_volume, ROUND(AVG(fraud_flag) * 100, 2) as fraud_rate,
    ROUND(AVG(CASE WHEN transaction_status = 'SUCCESS' THEN 1.0 ELSE 0.0 END) * 100, 2) as completion_rate,
    COUNT(DISTINCT sender_bank) as unique_sender_banks, COUNT(DISTINCT receiver_bank) as unique_receiver_banks
FROM transactions
GROUP BY sender_cat, reciver_cat
HAVING COUNT(*) >= 50
ORDER BY total_volume DESC;
