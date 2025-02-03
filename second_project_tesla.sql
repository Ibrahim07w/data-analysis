SELECT DISTINCT State, 
FROM apple_sales_2024
ORDER BY State;

ALTER TABLE apple_sales_2024
CHANGE COLUMN `Services Revenue (in billion $)` revenue DOUBLE;
ALTER TABLE apple_sales_2024
CHANGE COLUMN `Wearables (in million units)` wearables DOUBLE;
ALTER TABLE apple_sales_2024
CHANGE COLUMN `Mac Sales (in million units)` max DOUBLE;
ALTER TABLE apple_sales_2024
CHANGE COLUMN `iPad Sales (in million units)` ipad DOUBLE;
ALTER TABLE apple_sales_2024
CHANGE COLUMN `iPhone Sales (in million units)` iphone DOUBLE;

SELECT Region, ROUND(SUM(revenue), 2) AS revenue_by_region
FROM apple_sales_2024
GROUP BY Region
ORDER BY revenue_by_region DESC;

SELECT State, ROUND(SUM(revenue), 2) AS revenue_by_state
FROM apple_sales_2024
GROUP BY State
ORDER BY revenue_by_state DESC;

SELECT *
FROM apple_sales_2024
WHERE state = 'UK';

SELECT LENGTH('SELECT DISTINCT State
FROM apple_sales_2024
ORDER BY State') AS no_of_unique_values;

SELECT Region, revenue, 'R' AS label
FROM apple_sales_2024
WHERE revenue > 15
UNION
SELECT '' AS region, '' AS revenue, '' AS label
UNION
SELECT State, iphone, 'I' AS label
FROM apple_sales_2024
WHERE iphone > 20;

SELECT State, revenue,
Case
	WHEN revenue > 15 THEN 'rich'
    WHEN revenue BETWEEN 7 AND 15 THEN 'middle'
    WHEN revenue < 7 THEN 'poor'
END AS jjj
FROM apple_sales_2024;

SELECT *, ROW_NUMBER() OVER (ORDER BY State) AS row_index
FROM apple_sales_2024;
ALTER TABLE apple_sales_2024 ADD COLUMN row_index INT;
SET @row_number = 0;
UPDATE apple_sales_2024
SET row_index = (@row_number := @row_number + 1);

SELECT *
FROM apple_sales_2024;

SELECT State, revenue, row_index,
ROUND(SUM(revenue) OVER(PARTITION BY State ORDER BY row_index)) AS running_total,
ROUND(AVG(revenue) OVER(PARTITION BY State ORDER BY row_index)) AS running_avg,
ROUND(SUM(revenue) OVER(PARTITION BY State)) AS window_sum
FROM apple_sales_2024
ORDER BY State, row_index;


