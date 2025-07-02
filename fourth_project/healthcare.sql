CREATE TABLE healthcare(
	`Name` VARCHAR(50),
	Age INT,
	Gender VARCHAR(10),
	Blood_type VARCHAR(5),
	Medical_Condition VARCHAR(25),
	Date_of_Admission DATE,
	Doctor VARCHAR(30),
	Hospital VARCHAR(100),
	Insurance_Provider VARCHAR(20),
	Billing_Amount DECIMAL(9,3),
	Room_Number INT,
	Admission_Type VARCHAR(20),
	Discharge_Date DATE,
	Medication VARCHAR(20),
	Test_Results VARCHAR(20),
	Length_of_Stay INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/healthcare.csv'
INTO TABLE healthcare
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM healthcare;
SELECT * FROM healthcare LIMIT 5;

ALTER TABLE healthcare
ADD COLUMN Age_Category VARCHAR(20);

UPDATE healthcare
SET Age_Category = CASE
    WHEN Age < 13 THEN 'Child'
    WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
    WHEN Age BETWEEN 20 AND 39 THEN 'Young Adult'
    WHEN Age BETWEEN 40 AND 59 THEN 'Adult'
    ELSE 'Senior'
END;

-- check that number of days is correct 
SELECT Date_of_Admission, Discharge_Date, Length_of_Stay, DATEDIFF(Date_of_Admission, Discharge_Date)
FROM healthcare
WHERE Length_of_Stay != ABS(DATEDIFF(Date_of_Admission, Discharge_Date));
-- the length_of_stay column is all correct

-- check if any error that the Discharge_date is before admission date 
SELECT *
FROM healthcare
WHERE Discharge_Date < Date_of_Admission;
-- no such errors

-- to get rid of preciding titles like dr and Mr
UPDATE healthcare
SET Name = REGEXP_REPLACE(Name, '^(Mr\.|Mrs\.|Dr\.)\s*', '');

-- show which blood type is the most abundunt among patients
SELECT Blood_type, COUNT(*) AS number_of_patients
FROM healthcare
GROUP BY Blood_type
ORDER BY number_of_patients DESC;
-- O+ and A+ have approximatly the same number and are the highest category

-- show which blood type and disease combination is the most common
with combination AS(
	SELECT Blood_type, Medical_Condition, COUNT(*) AS number_of_patients
    FROM healthcare
    GROUP BY Blood_type, Medical_Condition
),
ranked AS(
	SELECT *, RANK() OVER(ORDER BY number_of_patients DESC) AS rnk
    FROM combination
)
SELECT *
FROM ranked
WHERE rnk <= 10
ORDER BY number_of_patients DESC;
-- O+ with diabetes is the most common combinations then with Obesity and Cancer
-- A+ is associated with heart disease and asthma

SELECT Hospital, COUNT(*) AS number_of_patients
FROM healthcare
GROUP BY Hospital
ORDER BY number_of_patients DESC;

-- show which pair of insurance provider and hospitals deal with each other the most
with pairs AS(
	SELECT Hospital, Insurance_Provider, COUNT(*) AS deals
    FROM healthcare
    GROUP BY Hospital, Insurance_Provider
),
ranked AS(
	SELECT *, RANK() OVER(ORDER BY deals DESC) AS rnk
    FROM pairs
)
SELECT *
FROM ranked
ORDER BY deals DESC;
-- NWM hospitals deal with unitedHealthCare the most often then come Coigna
-- the least operations are done in loyola university center 

-- show the patient that stayed at the hospital the longest
SELECT `Name`, Age, Gender, Medical_Condition, Hospital, Length_of_Stay
FROM healthcare
ORDER BY Length_of_Stay DESC
LIMIT 1;
-- what a pity he stayed for approximatly 3 months in hospital because of ALzheimer

-- doctors associated with emergency operations
SELECT Doctor, Admission_Type, COUNT(*) AS number_of_operations
FROM healthcare
WHERE Admission_Type = 'Emergency'
GROUP BY Admission_Type, Doctor
ORDER BY number_of_operations DESC;
-- doctors John Smith and David Smith have done the largest number of emergency operations 

-- running total of each hospital
SELECT Hospital, Billing_Amount, Discharge_Date,
SUM(Billing_amount) OVER(PARTITION BY Hospital ORDER BY Discharge_Date 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM healthcare
ORDER BY Discharge_Date;

-- EDA by age category
SELECT Age_Category, COUNT(*), MIN(Length_of_Stay), MAX(Length_of_Stay), ROUND(AVG(Age),2)
FROM healthcare
GROUP BY Age_category;

CREATE OR REPLACE VIEW Monthly_income_by_hospital AS
SELECT Hospital, DATE_FORMAT(Discharge_Date, '%m/%y') AS `month`, SUM(Billing_Amount) AS total
FROM healthcare
GROUP BY Hospital,  `month`
ORDER BY `month`, Hospital;
SELECT * FROM Monthly_income_by_hospital;

DELIMITER $$

CREATE PROCEDURE AddPatient(
    IN p_Name VARCHAR(50),
    IN p_Age INT,
    IN p_Gender VARCHAR(10),
    IN p_Blood_type VARCHAR(5),
    IN p_Medical_Condition VARCHAR(25),
    IN p_Date_of_Admission DATE,
    IN p_Doctor VARCHAR(30),
    IN p_Hospital VARCHAR(100),
    IN p_Insurance_Provider VARCHAR(20),
    IN p_Billing_Amount DECIMAL(9,3),
    IN p_Room_Number INT,
    IN p_Admission_Type VARCHAR(20),
    IN p_Discharge_Date DATE,
    IN p_Medication VARCHAR(20),
    IN p_Test_Results VARCHAR(20)
)
BEGIN
    -- Declare all variables at the top
    DECLARE v_Length_of_Stay INT;
    DECLARE v_Age_Category VARCHAR(20);
    -- Calculate length of stay
    SET v_Length_of_Stay = DATEDIFF(p_Discharge_Date, p_Date_of_Admission);
    -- Determine age category
    SET v_Age_Category = CASE
        WHEN p_Age < 13 THEN 'Child'
        WHEN p_Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN p_Age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN p_Age BETWEEN 40 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END;
    -- Insert the record
    INSERT INTO healthcare (
        Name, Age, Gender, Blood_type, Medical_Condition,
        Date_of_Admission, Doctor, Hospital, Insurance_Provider,
        Billing_Amount, Room_Number, Admission_Type, Discharge_Date,
        Medication, Test_Results, Length_of_Stay, Age_Category
    ) VALUES (
        p_Name, p_Age, p_Gender, p_Blood_type, p_Medical_Condition,
        p_Date_of_Admission, p_Doctor, p_Hospital, p_Insurance_Provider,
        p_Billing_Amount, p_Room_Number, p_Admission_Type, p_Discharge_Date,
        p_Medication, p_Test_Results, v_Length_of_Stay, v_Age_Category
    );
END$$
DELIMITER ;

