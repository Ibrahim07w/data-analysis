SELECT *
FROM consumption
ORDER BY Year DESC;

SELECT *
FROM gdp
ORDER BY Year;

CREATE TABLE big_table2 AS
SELECT c.country, c.Year, c.Poultry, c.Beef, c.Sheep_goat, c.Pork, c.other_meats, c.fish, 
g.continent, g.gdp
FROM consumption AS c
LEFT JOIN gdp AS g
	ON c.country = g.country AND c.Year = g.Year;

ALTER TABLE gdp 
CHANGE COLUMN `ï»¿Entity` country TEXT;
ALTER TABLE gdp 
CHANGE COLUMN `Ð¡ontinent` continent TEXT;
ALTER TABLE gdp 
CHANGE COLUMN `GDP per capita, PPP (constant 2017 international $)` gdp TEXT;

ALTER TABLE consumption 
CHANGE COLUMN `ï»¿Entity` country TEXT;
ALTER TABLE consumption 
CHANGE COLUMN `Sheep and goat` sheep_goat TEXT;
ALTER TABLE consumption 
CHANGE COLUMN `Other meats` other_meats TEXT;
ALTER TABLE consumption 
CHANGE COLUMN `Fish and seafood` fish TEXT;

ALTER TABLE big_table2 ADD COLUMN row_index INT;
SET @row_number = 0;
UPDATE big_table2 SET row_index = (@row_number := @row_number + 1);

ALTER TABLE big_table2
MODIFY COLUMN row_index INT FIRST;
ALTER TABLE big_table2
MODIFY COLUMN continent TEXT AFTER country;

ALTER TABLE big_table2
MODIFY COLUMN Sheep_goat DOUBLE,
MODIFY COLUMN Pork DOUBLE,
MODIFY COLUMN other_meats DOUBLE,
MODIFY COLUMN fish DOUBLE,
MODIFY COLUMN gdp DOUBLE;

CREATE PROCEDURE get_gdp2 (country_par TEXT, YEAR_par INT)
SELECT country, Year, gdp
FROM big_table2
WHERE country = country_par AND `Year` = Year_par;
CALL get_gdp2('Egypt', 2012);

DELIMITER &&
CREATE EVENT delete_old 
ON SCHEDULE EVERY 1 YEAR
DO
BEGIN
	DELETE
    FROM big_table2
    WHERE MAX(Year) - Year >= 100;
END &&
DELIMITER ;

SELECT *
FROM big_table2
WHERE country = 'Cuba';

SELECT country, AVG(gdp), MAX(gdp), MIN(gdp)
FROM big_table2
GROUP BY country;

UPDATE big_table2 SET gdp = NULL WHERE gdp = '';
UPDATE big_table2 SET Pork = NULL WHERE Pork = '';
UPDATE big_table2 SET country = TRIM(country);

SELECT *
FROM big_table2;

ALTER TABLE big_table2 ADD COLUMN rich TEXT;
UPDATE big_table2
SET rich = 
	CASE
		WHEN gdp > 20000 THEN 'rich'
		WHEN gdp < 20000 THEN 'poor'
	END;
    
UPDATE big_table2 SET Poultry = ROUND(Poultry, 2);
UPDATE big_table2 SET Beef = ROUND(Beef, 2);
UPDATE big_table2 SET Sheep_goat = ROUND(Sheep_goat, 2);
UPDATE big_table2 SET Pork = ROUND(Pork, 2);
UPDATE big_table2 SET other_meats = ROUND(other_meats, 2);
UPDATE big_table2 SET fish = ROUND(fish, 2);

SELECT * 
FROM big_table2;

SELECT country,`Year`, gdp,
SUM(gdp) OVER(PARTITION BY country ORDER BY `Year`) AS rolling_sum,
AVG(gdp) OVER(PARTITION BY country ORDER BY `Year`) AS rolling_avg,
SUM(gdp) OVER(PARTITION BY country) AS window_sum,
RANK() OVER(PARTITION BY country ORDER BY gdp) AS rank_num
FROM big_table2;







