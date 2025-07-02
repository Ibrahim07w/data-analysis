SELECT *
FROM parks_and_recreation.employee_demographics;

SELECT first_name, last_name, age, age+10
FROM parks_and_recreation.employee_demographics;

SELECT DISTINCT gender
from employee_demographics;

SELECT *
from employee_salary
WHERE (salary > 50000 AND dept_id = 1) OR employee_id = 5;

SELECT *
from employee_salary
WHERE first_name LIKE '%er%' OR first_name LIKE'a%';

SELECT *
from employee_demographics
WHERE birth_date LIKE '1985%';

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;

SELECT *
FROM employee_demographics
ORDER BY first_name DESC;

SELECT *
FROM employee_demographics
ORDER BY gender, age DESC;

SELECT occupation, AVG(salary) AS avg_age
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary) > 75000
LIMIT 3;

SELECT dem.employee_id, age
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments AS pd
	ON sal.dept_id = pd.department_id;
    
SELECT first_name, last_name
FROM employee_demographics
UNION 
SELECT first_name, last_name
FROM employee_salary;

SELECT first_name, last_name, 'old' AS label
FROM employee_demographics
WHERE age > 50
UNION 
SELECT first_name, last_name, 'rich' AS label
FROM employee_salary
WHERE salary > 70000;

SELECT first_name, LENGTH(first_name), UPPER(first_name), LOWER(first_name), TRIM(first_name)
, LEFT(first_name, 4), SUBSTRING(first_name,3,2), REPLACE(first_name, 'A', 'Z'), LOCATE('A',first_name),
CONCAT(first_name,' ',last_name)
FROM employee_demographics
ORDER BY 2;

SELECT first_name, age,
CASE 
	WHEN age <= 30 THEN 'young'
    WHEN age BETWEEN 31 AND 50 THEN 'old'
    WHEN age >= 30 THEN 'retired'
END AS age_category
FROM employee_demographics;

SELECT first_name, salary,
CASE
	WHEN salary <= 50000 THEN salary * 1.05
    WHEN salary > 50000 THEN salary * 1.07
END AS new_salary,
CASE 
	WHEN dept_id = 6 THEN salary * 1.1
END AS bonus
FROM employee_salary;

SELECT *
FROM employee_demographics
WHERE employee_id IN
				(SELECT employee_id
                FROM employee_salary
                WHERE dept_id = 1);

SELECT first_name, salary, 
(SELECT AVG(salary)
FROM employee_salary)
FROM employee_salary;

SELECT dem.first_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS running_total,
SUM(salary) OVER(PARTITION BY gender) AS window_fun,
AVG(salary) OVER(PARTITION BY gender) AS window_fun,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary) AS rank_num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary) AS dense_rank_num
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
movie varchar(100)
);
INSERT INTO temp_table
VALUES('i','kh','hp');
SELECT *
FROM temp_table;

CREATE PROCEDURE large()
SELECT * 
FROM employee_salary
WHERE salary >= 50000;
CALL large();

DELIMITER &&
CREATE PROCEDURE large2()
BEGIN 
	SELECT * 
	FROM employee_salary
	WHERE salary >= 50000;
    SELECT * 
	FROM employee_salary
	WHERE salary >= 10000;
END &&
DELIMITER ;
CALL large2();

CREATE PROCEDURE salary(id INT)
SELECT first_name, salary 
FROM employee_salary
WHERE employee_id = id;
CALL salary(4);

DELIMITER &&
CREATE TRIGGER emp_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END &&
DELIMITER ;

DELIMITER &&
CREATE EVENT delete_old
ON SCHEDULE EVERY 1 MONTH
DO 
BEGIN
	DELETE 
    FROM employe_demographics
    WHERE age >= 60;
END &&
DELIMITER ;
