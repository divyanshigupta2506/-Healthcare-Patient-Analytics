CREATE DATABASE IF NOT EXISTS healthcare;

USE healthcare;


CREATE TABLE patients  (
    patient_id VARCHAR(100),
    Name VARCHAR(100),
    age INT,
    gender VARCHAR(100),
   Blood_Type VARCHAR(100),
    Medical_Condition VARCHAR(100),
    Insurance_Provider VARCHAR(100)
);
	
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    Doctor VARCHAR(100),
    Hospital VARCHAR(150),
    Date_of_Admission DATE,
    Discharge_Date DATE,
    Admission_Type VARCHAR(20),
    Room_Number INT,
    Billing_Amount DECIMAL(12,2),
    Medication VARCHAR(50),
    Test_Results VARCHAR(20)
);

LOAD DATA LOCAL INFILE "C:\\Users\\divya\\Downloads\\patients.csv"
INTO TABLE patients 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:\\Users\\divya\\Downloads\\admissions.csv"
INTO TABLE admissions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT patient_id,Doctor,Hospital,Date_of_Admission	,Admission_Type,Discharge_Date,	Billing_Amount,	Room_Number,Medication,Test_Results
FROM admissions;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

SELECT upper(healthcare.patients.Name) AS Name
FROM healthcare.patients;

UPDATE healthcare.patients
SET healthcare.patients.Name=upper(healthcare.patients.Name);

SET SQL_SAFE_UPDATES = 0;

SELECT Name, Age, Gender, Blood_Type, COUNT(*) AS duplicate_count
FROM healthcare.patients
GROUP BY Name, Age, Gender, Blood_Type
HAVING COUNT(*) > 1;

SELECT Billing_Amount, Discharge_Date, Test_Results
FROM healthcare.admissions
WHERE Billing_Amount IS NULL 
   OR Discharge_Date IS NULL 
   OR Test_Results IS NULL;
   
   SELECT 
    COUNT(CASE WHEN Billing_Amount IS NULL THEN 1 END) AS Null_Billing_Amount,
    COUNT(CASE WHEN Discharge_Date IS NULL THEN 1 END) AS Null_Discharge_Date,
    COUNT(CASE WHEN Test_Results IS NULL THEN 1 END) AS Null_Test_Results
FROM healthcare.admissions;
      
SELECT COUNT(distinct a.Hospital), COUNT(distinct a.Doctor),  COUNT(distinct p.Insurance_Provider)
FROM healthcare.admissions a
INNER JOIN healthcare.patients p
ON a.patient_id=p.patient_id;

SELECT 
    p.patient_id,
    p.Name,
    p.Age,
    p.Gender,
    p.Blood_Type,
    p.Medical_Condition,
    p.Insurance_Provider,
    a.Doctor,
    a.Hospital,
    a.Date_of_Admission,
    a.Discharge_Date,
    a.Admission_Type,
    a.Room_Number,
    a.Billing_Amount,
    a.Medication,
    a.Test_Results
FROM healthcare.patients p
INNER JOIN healthcare.admissions a
    ON p.patient_id = a.patient_id;
    
SELECT a.admission_id, a.patient_id
FROM admissions a
LEFT JOIN patients p ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

SELECT a.Hospital,
       SUM(a.Billing_Amount) AS Total_Billing,
       AVG(a.Billing_Amount) AS Avg_Billing
FROM admissions a
GROUP BY a.Hospital
ORDER BY Total_Billing DESC;

SELECT p.Medical_Condition,
       COUNT(*) AS Patient_Count
FROM patients p
GROUP BY p.Medical_Condition
ORDER BY Patient_Count DESC;

SELECT a.Hospital,
       AVG(DATEDIFF(a.Discharge_Date, a.Date_of_Admission))AS Avg_Length_of_Stay
FROM admissions a
GROUP BY a.Hospital
ORDER BY Avg_Length_of_Stay DESC;

SELECT p.patient_id,p.Name,	p.Age,p.Gender,a.Billing_Amount
FROM healthcare.patients p
INNER JOIN healthcare.admissions a
ON p.patient_id=a.patient_id
WHERE a.Billing_Amount > ( SELECT AVG(a.Billing_Amount) 
FROM healthcare.admissions a)
ORDER BY a.Billing_Amount DESC;

SELECT a.Hospital,
     ROUND(AVG(a.Billing_Amount), 2) AS billing_avg
FROM healthcare.admissions a
 GROUP BY a.Hospital
HAVING  AVG(a.Billing_Amount) > ( SELECT AVG(a.Billing_Amount) 
FROM healthcare.admissions a)
ORDER BY billing_avg DESC;

SELECT p.Name, 
       p.Medical_Condition,
       DATEDIFF(a.Discharge_Date, a.Date_of_Admission) AS Length_of_Stay
FROM healthcare.patients p
INNER JOIN healthcare.admissions a
    ON p.patient_id = a.patient_id
WHERE 
   DATEDIFF(a.Discharge_Date, a.Date_of_Admission)> (
        SELECT AVG(DATEDIFF(a.Discharge_Date, a.Date_of_Admission))
        FROM healthcare.patients p2
        INNER JOIN healthcare.admissions a2
            ON p2.patient_id = a2.patient_id
        WHERE p2.Medical_Condition = p.Medical_Condition
    )
ORDER BY p.Medical_Condition, Length_of_Stay DESC;


WITH  average_billing  AS(
SELECT ROUND(AVG(a.Billing_Amount), 2) AS billing_avg,
      p. Medical_Condition
 FROM healthcare.admissions a
INNER JOIN healthcare.patients p
    ON a.patient_id = p.patient_id
 GROUP BY p. Medical_Condition
 )
 SELECT *
 FROM average_billing 
 WHERE  billing_avg > (SELECT AVG(Billing_Amount) FROM healthcare.admissions a);
 
WITH stay_per_hospital AS (
    SELECT 
        a.Hospital,
        COUNT(*) AS total_admissions,
       AVG(DATEDIFF(a.Discharge_Date, a.Date_of_Admission)) AS Length_of_Stay
    FROM healthcare.admissions a
    GROUP BY a.Hospital
    HAVING COUNT(*) > 5
)
SELECT Hospital, total_admissions, Length_of_Stay,
       RANK() OVER (ORDER BY Length_of_Stay DESC) AS rnk
FROM stay_per_hospital;
 
WITH joined_data AS (
    SELECT 
        a.Hospital,
        p.Name,
        a.Billing_Amount
    FROM healthcare.admissions a
    INNER JOIN healthcare.patients p
        ON a.patient_id = p.patient_id
),
ranked_data AS (
    SELECT 
        Hospital,
        Name,
        Billing_Amount,
        RANK() OVER (PARTITION BY Hospital ORDER BY Billing_Amount DESC) AS rnk
    FROM joined_data
)
SELECT Hospital, Name, Billing_Amount, rnk
FROM ranked_data
WHERE rnk <= 3
ORDER BY Hospital, rnk;

SELECT 
    Doctor,
    Date_of_Admission,
    COUNT(*) OVER (
        PARTITION BY Doctor 
        ORDER BY Date_of_Admission
    ) AS running_admissions
FROM admissions
ORDER BY Doctor, Date_of_Admission;

SELECT 
    Medical_Condition,
    COUNT(*) AS condition_count,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS condition_rank
FROM patients
GROUP BY Medical_Condition
ORDER BY condition_rank;

SELECT 
    CASE 
        WHEN Age <= 18 THEN '0-18' 
        WHEN Age BETWEEN 19 AND 40 THEN '19-40'
        WHEN Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS Age_segment,
    COUNT(*) AS Patient_count
FROM healthcare.patients
GROUP BY Age_segment
ORDER BY Age_segment;

SELECT  
       CASE  
           WHEN Billing_Amount < 15000 THEN 'Low'
           WHEN Billing_Amount BETWEEN 15000 AND 35000 THEN 'Medium'
           ELSE 'High'
       END AS Billing_Amount_categories,
       COUNT(*) AS admissions_per_tier
FROM healthcare.admissions
GROUP BY Billing_Amount_categories
ORDER BY Billing_Amount_categories DESC ;

SELECT MONTHNAME(Date_of_Admission) AS Months,
       YEAR(Date_of_Admission) AS years,
        COUNT(*)AS admissions
FROM healthcare.admissions
GROUP BY Months,years
ORDER BY admissions DESC;

SELECT 
    patient_id,
    Hospital,
    Date_of_Admission,
    Discharge_Date,
    DATEDIFF(Discharge_Date, Date_of_Admission) AS Length_of_Stay
FROM healthcare.admissions
WHERE DATEDIFF(Discharge_Date, Date_of_Admission) = (
    SELECT MAX(DATEDIFF(Discharge_Date, Date_of_Admission))
    FROM healthcare.admissions
);