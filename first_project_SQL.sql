SELECT *
FROM ecommerce_data
WHERE profit_per_order >= 200
AND
customer_first_name LIKE 'm%' OR customer_first_name LIKE 's___';

SELECT *
FROM ecommerce_data
WHERE order_date LIKE '%2021';

SELECT customer_region, AVG(profit_per_order), SUM(profit_per_order), COUNT(profit_per_order) AS countt
FROM ecommerce_data
GROUP BY customer_region
HAVING AVG(profit_per_order) > 20
ORDER BY customer_region DESC
LIMIT 1;

UPDATE ecommerce_data SET order_date = REPLACE (order_date, '/' , '-');
UPDATE ecommerce_data SET ship_date = REPLACE (ship_date, '/' , '-');

SELECT *,
CASE
	WHEN order_date LIKE '%2020' THEN '2020'
	WHEN order_date LIKE '%2021' THEN '2021'
	WHEN order_date LIKE '%2022' THEN '2022'
END AS year_of_order
FROM ecommerce_data;

SELECT *,
SUM(profit_per_order) OVER(PARTITION BY customer_segment ORDER BY customer_first_name) AS running_total,
SUM(profit_per_order) OVER(PARTITION BY customer_segment) AS total,
AVG(profit_per_order) OVER(PARTITION BY customer_segment) AS average,
RANK() OVER(PARTITION BY profit_per_order) AS rankk
FROM ecommerce_data
ORDER BY customer_segment;

DELIMITER $$
CREATE PROCEDURE region2(region_par text)
	SELECT customer_first_name, customer_region
    FROM ecommerce_data
    WHERE customer_region = region_par;
END $$
DELIMITER ;
CALL region2('East');

DELIMITER $$
CREATE EVENT del_date
ON SCHEDULE EVERY 2 WEEK
DO
BEGIN
	DELETE
    FROM ecommerce_data
    WHERE order_date > '1-1-2025';
END $$
DELIMITER ;


SET SQL_SAFE_UPDATES = 0;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ship_date, shipping_type, days_for_shipment_scheduled,
days_for_shipment_real, order_item_discount, sales_per_order, order_quantity, profit_per_order)
AS row_num
FROM ecommerce_data
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `staging2` (
  `ï»¿customer_id` text,
  `customer_first_name` text,
  `customer_last_name` text,
  `category_name` text,
  `product_name` text,
  `customer_segment` text,
  `customer_city` text,
  `customer_state` text,
  `customer_country` text,
  `customer_region` text,
  `delivery_status` text,
  `order_date` text,
  `order_id` text,
  `ship_date` text,
  `shipping_type` text,
  `days_for_shipment_scheduled` int DEFAULT NULL,
  `days_for_shipment_real` int DEFAULT NULL,
  `order_item_discount` int DEFAULT NULL,
  `sales_per_order` int DEFAULT NULL,
  `order_quantity` int DEFAULT NULL,
  `profit_per_order` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ship_date, shipping_type, days_for_shipment_scheduled,
days_for_shipment_real, order_item_discount, sales_per_order, order_quantity, profit_per_order)
AS row_num
FROM ecommerce_data;

DELETE 
FROM staging2
WHERE row_num > 1;

UPDATE staging2 SET product_name = TRIM(product_name);
SELECT DISTINCT(customer_first_name)
FROM staging2
ORDER BY customer_first_name;


	
    

SELECT *
FROM ecommerce_data;



