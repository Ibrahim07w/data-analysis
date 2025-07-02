CREATE TABLE cars8 (
	Sales_ID INT,	
    `name` VARCHAR(20),	
    `year` INT,	
    selling_price INT,	
    km_driven INT,	
    Region VARCHAR(20),	
    State VARCHAR(30),	
    City VARCHAR(30),	
    fuel VARCHAR(20),
	seller_type VARCHAR(20),
	transmission VARCHAR(20),
	`owner` VARCHAR(20),
	mileage DECIMAL(4,2),
	`engine` INT,
	max_power DECIMAL(8,4),
	torque VARCHAR(50),
	seats INT,
	sold VARCHAR(10)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/UserCarData.csv'
INTO TABLE cars8
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWs;

SELECT *
FROM cars8;

-- to remove duplicates
DELETE FROM cars8
WHERE Sales_ID IN (
	SELECT Sales_ID FROM (
		SELECT Sales_ID, 
        ROW_NUMBER() OVER(PARTITION BY Sales_ID, torque, km_driven, `year` ORDER BY Sales_ID ) AS row_num
    ) AS ranked
    WHERE row_num > 1
);

-- checking number of empty values
SELECT 
    SUM(CASE WHEN name IS NULL OR TRIM(name) = '' OR UPPER(TRIM(name)) IN ('NULL', 'NONE', 'N/A', 'NA') THEN 1 ELSE 0 END) as missing_name,
    SUM(CASE WHEN year IS NULL OR year = 0 OR TRIM(CAST(year AS CHAR)) IN ('NULL', 'NONE', 'N/A', 'NA', '') THEN 1 ELSE 0 END) as missing_year,
    SUM(CASE WHEN selling_price IS NULL OR selling_price = 0 OR TRIM(CAST(selling_price AS CHAR)) IN ('NULL', 'NONE', 'N/A', 'NA', '') THEN 1 ELSE 0 END) as missing_price,
    SUM(CASE WHEN km_driven IS NULL OR TRIM(CAST(km_driven AS CHAR)) IN ('NULL', 'NONE', 'N/A', 'NA', '') THEN 1 ELSE 0 END) as missing_km,
    SUM(CASE WHEN fuel IS NULL OR TRIM(fuel) = '' OR UPPER(TRIM(fuel)) IN ('NULL', 'NONE', 'N/A', 'NA') THEN 1 ELSE 0 END) as missing_fuel
FROM cars8;

-- average car price by year
SELECT `year`, COUNT(*) AS cars_sold, MAX(selling_price) AS max_price,
	   MIN(selling_price) AS min_price, ROUND(AVG(selling_price),2) AS average,
       ROUND(STDDEV(selling_price),2) AS stdv
FROM cars8
GROUP BY `year`
ORDER BY `year`;

-- Depreciation Rate of cars
SELECT 
    year,
    AVG(selling_price) as avg_price,
    LAG(AVG(selling_price)) OVER (ORDER BY year) as prev_year_price,
    ROUND(
        ((LAG(AVG(selling_price)) OVER (ORDER BY year) - AVG(selling_price)) / 
         LAG(AVG(selling_price)) OVER (ORDER BY year)) * 100, 2
    ) as depreciation_rate_percent
FROM cars8
GROUP BY year
ORDER BY year;

SELECT Region, COUNT(*) as total_listings, ROUND(AVG(selling_price),2) as avg_selling_price
FROM cars8
GROUP BY Region;

SELECT City, State, Region, COUNT(*) as total_sales, AVG(selling_price) as avg_price,
	   MIN(selling_price) as cheapest_car, MAX(selling_price) as most_expensive_car
FROM cars8
GROUP BY City, State, Region
HAVING COUNT(*) >= 10
ORDER BY Region;

SELECT transmission, COUNT(*) as total_cars, AVG(selling_price) as avg_price,
	   AVG(km_driven) as avg_mileage, AVG(year) as avg_year
FROM cars8
GROUP BY transmission
ORDER BY avg_price DESC;

SELECT `owner`, COUNT(*) as total_cars, AVG(selling_price) as avg_price,
	    AVG(km_driven) as avg_km_driven, ROUND(STD(selling_price), 2) as price_variance
FROM cars8
GROUP BY owner
ORDER BY avg_price DESC;

-- Price segments analysis
SELECT 
    CASE 
        WHEN selling_price < 200000 THEN 'Budget (< 2L)'
        WHEN selling_price < 500000 THEN 'Mid-range (2-5L)'
        WHEN selling_price < 1000000 THEN 'Premium (5-10L)'
        ELSE 'Luxury (10L+)'
    END as price_segment, COUNT(*) as total_cars, AVG(year) as avg_year,
    AVG(km_driven) as avg_km_driven, ROUND(AVG(mileage), 2) as avg_mileage_kmpl, 
    ROUND(AVG(engine), 0) as avg_engine_cc
FROM cars8
GROUP BY 
    CASE 
        WHEN selling_price < 200000 THEN 'Budget (< 2L)'
        WHEN selling_price < 500000 THEN 'Mid-range (2-5L)'
        WHEN selling_price < 1000000 THEN 'Premium (5-10L)'
        ELSE 'Luxury (10L+)'
    END
ORDER BY AVG(selling_price);

-- Best performing combinations
SELECT fuel, transmission, ROUND(AVG(selling_price), 2) as avg_price, COUNT(*) as sample_size
FROM cars8
GROUP BY fuel, transmission
HAVING COUNT(*) >= 20
ORDER BY conversion_rate DESC, avg_price DESC;

-- Underperforming segments (low conversion rates)
SELECT `name`, fuel, COUNT(*) as inventory, SUM( 1 ) as sold,
    ROUND((SUM( 1 ) * 100.0 / COUNT(*)), 2) as conversion_rate
FROM cars8
GROUP BY `name`, fuel
ORDER BY conversion_rate ASC;

-- Regional summary view
CREATE VIEW regional_summary AS
SELECT 
    Region,
    COUNT(*) as total_inventory,
    SUM(1 ) as units_sold,
    ROUND(AVG(selling_price ), 2) as avg_price,
    ROUND((SUM(1 ) * 100.0 / COUNT(*)), 2) as conversion_rate
FROM cars8
GROUP BY Region;

-- Brand performance view
CREATE VIEW brand_performance AS
SELECT 
   `name`,
    COUNT(*) as inventory_count,
    SUM(1) as sales_count,
    AVG(selling_price ) as avg_selling_price,
    AVG(km_driven) as avg_mileage,
    ROUND((SUM( 1) * 100.0 / COUNT(*)), 2) as success_rate
FROM cars8
GROUP BY `name`
HAVING COUNT(*) >= 10;

-- Which car brands have the highest price premium for low-mileage vehicles?
SELECT 
    `name`,
    ROUND(AVG(CASE WHEN km_driven <= 30000 THEN selling_price END),2) as avg_price_low_km,
    ROUND(AVG(CASE WHEN km_driven > 30000 THEN selling_price END),2) as avg_price_high_km,
    ROUND((AVG(CASE WHEN km_driven <= 30000 THEN selling_price END) - 
     AVG(CASE WHEN km_driven > 30000 THEN selling_price END)),2) as price_premium,
    ROUND(((AVG(CASE WHEN km_driven <= 30000 THEN selling_price END) - 
            AVG(CASE WHEN km_driven > 30000 THEN selling_price END)) / 
           AVG(CASE WHEN km_driven > 30000 THEN selling_price END) * 100), 2) as premium_percentage
FROM cars8
GROUP BY `name`
HAVING COUNT(CASE WHEN km_driven <= 30000 THEN 1 END) >= 5 
   AND COUNT(CASE WHEN km_driven > 30000 THEN 1 END) >= 5
ORDER BY premium_percentage DESC
LIMIT 10;

SELECT 
    CASE 
        WHEN selling_price < 300000 THEN 'Budget (< 3L)'
        WHEN selling_price < 800000 THEN 'Mid-range (3-8L)'
        WHEN selling_price < 1500000 THEN 'Premium (8-15L)'
        ELSE 'Luxury (15L+)'
    END as price_segment,
    fuel,
    COUNT(*) as car_count,
    AVG(mileage) as avg_mileage_kmpl,
    AVG(selling_price) as avg_price,
    ROUND(AVG(selling_price) / AVG(mileage), 2) as price_per_kmpl_ratio,
    RANK() OVER (PARTITION BY 
        CASE 
            WHEN selling_price < 300000 THEN 'Budget (< 3L)'
            WHEN selling_price < 800000 THEN 'Mid-range (3-8L)'
            WHEN selling_price < 1500000 THEN 'Premium (8-15L)'
            ELSE 'Luxury (15L+)'
        END 
        ORDER BY AVG(mileage) DESC) as mileage_rank
FROM cars8
GROUP BY 
    CASE 
        WHEN selling_price < 300000 THEN 'Budget (< 3L)'
        WHEN selling_price < 800000 THEN 'Mid-range (3-8L)'
        WHEN selling_price < 1500000 THEN 'Premium (8-15L)'
        ELSE 'Luxury (15L+)'
    END,
    fuel
HAVING COUNT(*) >= 10
ORDER BY price_segment, mileage_rank;

-- Which cities have the highest price appreciation for older cars (10+ years)?
SELECT City, State, Region, COUNT(*) AS num_of_cars, ROUND(AVG(selling_price)) AS average, ROUND(AVG(2024 - `year`),2) AS avg_age
FROM cars8
WHERE 2024 - `year` >= 10
GROUP BY City, State, Region
HAVING COUNT(*) >= 15
ORDER BY average;

WITH RECURSIVE car_chain AS (
  SELECT Sales_ID, name, year, seller_type, 1 AS step
  FROM (
    SELECT * FROM cars8
    WHERE seller_type = 'Dealer'
    ORDER BY year
    LIMIT 1
  ) AS first_car  
  UNION ALL
  SELECT cs.Sales_ID, cs.name, cs.year, cs.seller_type, cc.step + 1
  FROM car_chain cc
  JOIN cars8 cs
    ON cs.seller_type = cc.seller_type
   AND cs.year > cc.year
  WHERE cc.step < 5
)
SELECT * FROM car_chain;

