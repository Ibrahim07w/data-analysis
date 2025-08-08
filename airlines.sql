CREATE TABLE airways3(
	airline VARCHAR(15),
    flight VARCHAR(15),
    origin VARCHAR(15),
    departure_time VARCHAR(15),
    stops VARCHAR(15),
    arrival_time VARCHAR(15),
    destination VARCHAR(15),
    class VARCHAR(15),
    duration DECIMAL(4,2),
    days_left INT,
    price INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airlines_flights_data2.csv'
INTO TABLE airways3
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM airways3 ORDER BY price LIMIT 5;

-- available airlines
SELECT DISTINCT airline FROM airways3;

-- delete duplicates
DELETE FROM airways3
WHERE flight IN(
	SELECT flight FROM (
		SELECT flight, ROW_NUMBER() OVER(PARTITION BY flight, airline, destination, days_left, origin, stops, departure_time, price, duration, class, arrival_time ORDER BY flight) AS rnk
        FROM airways3
    ) AS ranked
    WHERE rnk > 1
);

-- checking null or invaid values
SELECT 
SUM(CASE WHEN price IS NULL OR price <= 0 THEN 1 ELSE 0 END) AS invalid_prices,
SUM(CASE WHEN flight IS NULL OR flight = '' THEN 1 ELSE 0 END) AS invalid_flights
FROM airways3;

CREATE VIEW number_of_stops AS
SELECT flight, airline, stops 
FROM airways3
ORDER BY days_left;

-- most common origin destination couples
SELECT origin, destination, COUNT(*) AS countt
FROM airways3
GROUP BY origin, destination
ORDER BY countt DESC;

-- most associated airline with each class
SELECT airline, class, COUNT(*) AS countt
FROM airways3
GROUP BY airline, class
ORDER BY countt DESC;

-- most expensive 5 flights
SELECT flight, airline, price
FROM airways3 
ORDER BY price DESC
LIMIT 5;

-- revenue of each airline from each class
SELECT airline, class, SUM(price) AS revenue
FROM airways3
GROUP BY airline, class
ORDER BY airline;

-- averarge price of each time 
SELECT departure_time, AVG(price) AS average
FROM airways3
GROUP BY departure_time
ORDER BY average;

-- longest 10 flights
SELECT flight, airline, duration
FROM airways3 
ORDER BY duration DESC
LIMIT 5;










