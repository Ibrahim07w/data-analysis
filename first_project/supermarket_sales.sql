CREATE TABLE sales (
	Invoice_ID VARCHAR(50),
	Branch VARCHAR(50),
	City VARCHAR(50),
	Customer_type VARCHAR(50),
	Gender VARCHAR(50),
	Product_line VARCHAR(50),
	Unit_price DECIMAL(10,2),         
	Quantity INT,
	Tax_5 DECIMAL(10,4),               
	Total DECIMAL(10,4),
	`Date` VARCHAR(50),
	`Time` TIME,
	Payment VARCHAR(50),
	cogs DECIMAL(10,2),
	gross_margin_percentage DECIMAL(10,5),
	gross_income DECIMAL(10,3),
	Rating DECIMAL(5,2)
);

UPDATE sales
SET `Date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/supermarket_sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT COUNT(*)
FROM sales;

-- to remove duplicates --
DELETE FROM sales
WHERE Invoice_ID in (
	SELECT Invoice_ID FROM (
		SELECT Invoice_ID,
        ROW_NUMBER () OVER (PARTITION BY Invoice_ID, Unit_price, Rating ORDER BY Invoice_ID) AS row_num
    ) AS ranked
    WHERE row_num > 1
);

SELECT Branch, SUM(total) AS branch_total
FROM sales
GROUP BY Branch
ORDER BY Branch_total DESC;

SELECT Product_line, SUM(total) AS line_income
FROM sales
GROUP BY Product_line
ORDER BY line_income DESC
LIMIT 5;

SELECT city, ROUND(AVG(Rating), 2) AS avg_ratings
FROM sales
GROUP BY city;

SELECT Gender, ROUND(SUM(total), 2) AS total_by_gender
FROM sales
GROUP BY Gender;

SELECT Gender, COUNT(Invoice_ID) AS total_by_gender
FROM sales
GROUP BY Gender;

SELECT Payment, COUNT(Payment) AS countt
FROM sales
GROUP BY Payment;

SELECT Product_line, ROUND(AVG(Quantity)) AS avg_quantity
FROM sales
GROUP BY Product_line;

SELECT `DATE`, ROUND(SUM(total)) AS total_by_day
FROM sales
GROUP BY `Date`
ORDER BY total_by_day DESC 
LIMIT 3;

SELECT Payment, COUNT(Invoice_ID) AS count_invoice, ROUND(SUM(Total)) AS total 
FROM sales
GROUP BY Payment;

SELECT Product_line, City, ROUND(AVG(Rating), 2) AS Avg_Rating
FROM sales
GROUP BY Product_line, City
ORDER BY Avg_Rating DESC;

SELECT DATE_FORMAT(`Date`, '%m/%Y') AS monthh, ROUND(SUM(gross_income)) AS gross, ROUND(SUM(Total)) AS total
FROM sales
GROUP BY monthh
ORDER BY monthh;

SELECT Branch, ROUND((SUM(Total) / (SELECT SUM(Total) FROM sales)) * 100, 2) AS Sales_Percentage
FROM sales
GROUP BY Branch
ORDER BY Sales_Percentage DESC;

SELECT Customer_type, COUNT(Invoice_ID), COUNT(Gender), SUM(Total)
FROM sales
GROUP BY Customer_type;

-- Product line with the most consistent daily sales volume (lowest stddev)
WITH daily_sales AS(
	SELECT Product_line, `Date`, SUM(Quantity) AS daily_quantity
    FROM sales
    GROUP BY Product_line, `Date`
),
line_stddev AS(
	SELECT Product_line, STDDEV(daily_quantity) AS stdv
    FROM daily_sales
    GROUP BY Product_line
)
SELECT Product_line, stdv
FROM line_stddev
ORDER BY stdv 
LIMIT 1;

CREATE OR REPLACE VIEW daily_income AS
SELECT Branch, `Date`, SUM(Total) AS daily_total
FROM sales
GROUP BY Branch, `Date`;

SELECT * 
FROM daily_income
WHERE Branch = 'A' AND daily_total > 100;

-- Top 3 invoices with highest gross income per unit sold
WITH grosss AS (
	SELECT Invoice_ID, ROUND((gross_income / Quantity),3) AS unit_gross
    FROM sales
)
SELECT Invoice_ID, unit_gross
FROM grosss
ORDER BY unit_gross DESC
LIMIT 3;

-- Branch with largest difference in avg gross income between male and female customers
WITH male AS (
	SELECT Gender, Branch, AVG(gross_income) as male_avg
    FROM sales
    WHERE Gender = 'Male'
    GROUP BY Branch
),
female AS (
	SELECT Gender, Branch, AVG(gross_income) as female_avg
    FROM sales
    WHERE Gender = 'Female'
    GROUP BY Branch
),
difference AS (
	SELECT M.Branch, m.male_avg, f.female_avg, ABS(m.male_avg - f.female_avg) AS diff
    FROM male m
    JOIN female f ON m.Branch = f.Branch
)
SELECT *
FROM difference
ORDER BY diff DESC
LIMIT 1;

-- 7-day moving average of total daily revenue for each branch
WITH daily_revenue AS(
	SELECT Branch, `Date`, SUM(Total) AS daily_total
    FROM sales
    GROUP BY Branch, `Date`
)
SELECT Branch, `Date`, AVG(daily_total) OVER(PARTITION BY Branch ORDER BY `Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg
FROM daily_revenue;

-- Peak shopping hour for each payment method (by avg total)
with hourly_sales as(
	select Payment, Total, hour(`Time`) as hourr
    from sales
),
avg_total as(
	select Payment, hourr, avg(Total) as average
    from hourly_sales
    group by Payment, hourr
), 
ranked as(
	select Payment, hourr, average, rank() over(partition by Payment order by average) as rankk
    from avg_total
)
select Payment, hourr, average
from ranked
where rankk = 1;

--  Top 5 invoices by total per city
with ranked as (
	select City, Total, Invoice_ID, rank() over(partition by City order by Total) as rankk
    from sales
)
select City, Total, Invoice_ID
from ranked
where rankk <= 5;

-- Day of the week with lowest average rating per branch
WITH rated_days AS (
  SELECT Branch, DAYNAME(`Date`) AS day_of_week, Rating
  FROM sales
),
avg_ratings AS (
  SELECT Branch, day_of_week, ROUND(AVG(Rating),3) AS avg_rating
  FROM rated_days
  GROUP BY Branch, day_of_week
),
ranked AS (
  SELECT Branch, day_of_week, avg_rating, RANK() OVER (PARTITION BY Branch ORDER BY avg_rating DESC) AS rnk
  FROM avg_ratings
)
SELECT Branch, day_of_week, avg_rating
FROM ranked
WHERE rnk = 1;

--  Which product line has the highest total sales in each city
WITH product_city_sales AS (
  SELECT City, `Product_line`, SUM(Total) AS total_sales
  FROM sales
  GROUP BY City, `Product_line`
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY City ORDER BY total_sales DESC) AS rnk
  FROM product_city_sales
)
SELECT City, `Product_line`, total_sales
FROM ranked
WHERE rnk = 1;

-- Calculate the average rating per customer type 
-- and find the one with the greatest variation between cities.
WITH avg_rating AS(
	SELECT Customer_type, City, AVG(Rating) AS average
    FROM sales
    GROUP BY Customer_type, City
),
variation AS(
	SELECT Customer_type, STDDEV(average) AS stdv
    FROM avg_rating
    GROUP BY Customer_type
)
SELECT * 
FROM variation
ORDER BY stdv DESC
LIMIT 1;

--  Find the date on which each branch had its maximum daily gross income.
WITH daily_income AS(
	SELECT `Date`, Branch, SUM(gross_income) AS gross
    FROM sales
    GROUP BY `Date`, Branch
),
ranked AS(
	SELECT `Date`, Branch, gross, RANK() OVER(PARTITION BY Branch ORDER BY gross DESC) AS rankk
    FROM daily_income
)
SELECT *
FROM ranked
WHERE rankk = 1;

-- Identify any days where a branch's revenue dropped by more than 50% compared to the previous day
WITH daily_revenue AS(
	SELECT Branch, `Date`, SUM(Total) AS revenue
    FROM sales
    GROUP BY Branch, `Date`
),
lagg AS(
	SELECT Branch, `Date`,revenue , LAG(revenue) OVER(PARTITION BY Branch ORDER BY `Date`) AS prev_revenue
    FROM daily_revenue
)
SELECT *, dayname(`Date`)
FROM lagg
WHERE revenue < 0.5 * prev_revenue AND prev_revenue IS NOT NULL;

-- Which branch has the highest average tax collected per product line
WITH tax_data AS (
  SELECT Branch, `Product_line`, AVG(`Tax_5`) AS avg_tax
  FROM sales
  GROUP BY Branch, `Product_line`
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY `Product_line` ORDER BY avg_tax DESC) AS rnk
  FROM tax_data
)
SELECT Branch, `Product_line`, avg_tax
FROM ranked
WHERE rnk = 1;

-- Which combination of gender and customer type has the highest average number of items per invoice?
WITH invoice_data AS (
  SELECT `Invoice_ID`, Gender, `Customer_type`, SUM(Quantity) AS items
  FROM sales
  GROUP BY `Invoice_ID`, Gender, `Customer_type`
),
grouped_avg AS (
  SELECT Gender, `Customer_type`, AVG(items) AS avg_items
  FROM invoice_data
  GROUP BY Gender, `Customer_type`
)
SELECT *
FROM grouped_avg
ORDER BY avg_items DESC
LIMIT 1;

-- create Procedure for Top-N Product Lines by City
DELIMITER //
CREATE PROCEDURE top_product_lines_by_city(IN N INT)
BEGIN
  WITH product_sales AS (
    SELECT City, Product_line, SUM(Total) AS total_sales
    FROM sales
    GROUP BY City, Product_line
  ),
  ranked AS (
    SELECT *, RANK() OVER (PARTITION BY City ORDER BY total_sales DESC) AS rnk
    FROM product_sales
  )
  SELECT City, Product_line, total_sales
  FROM ranked
  WHERE rnk <= N;
END //
DELIMITER ;

CALL top_product_lines_by_city(3);

