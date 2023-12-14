-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING
SELECT * 
FROM Portfolio_Project.us_household_income_statistics;

SELECT * 
FROM Portfolio_Project.us_household_income;

-- Identify Duplicates Values In The Dataset
SELECT id, COUNT(id)
FROM Portfolio_Project.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1;

-- Identify Duplicates Values In The Dataset
SELECT id, COUNT(id)
FROM Portfolio_Project.us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

-- Identify Duplicates Values In The Dataset Using Subquery
SELECT * 
FROM (
SELECT row_id,
 id,
 ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
 FROM Portfolio_Project.us_household_income
 ORDER BY row_id
 ) AS row_n
 WHERE row_num > 1;

-- Delete The Duplicates Values In The Dataset Using Subquery
DELETE FROM Portfolio_Project.us_household_income
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		 id,
		 ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		 FROM Portfolio_Project.us_household_income
		 ORDER BY row_id ) AS row_n
	WHERE row_num > 1
 );

-- Checking for misspelling in the state name column
SELECT DISTINCT(State_Name)
FROM Portfolio_Project.us_household_income
GROUP BY State_Name
ORDER BY 1;

-- Update state_name column
UPDATE Portfolio_Project.us_household_income
SET state_name = 'Georgia'
WHERE state_name = 'georia';
 
 -- Update state_name column
UPDATE Portfolio_Project.us_household_income
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

-- Checking for NULL/empty values in the 'place' column
SELECT *
FROM Portfolio_Project.us_household_income
WHERE place = '';

SELECT *
FROM Portfolio_Project.us_household_income
WHERE County = 'Autauga County';

-- Update the empty cell we found to the correct value
UPDATE Portfolio_Project.us_household_income
SET place = 'Autaugaville'
WHERE row_id = 32;


SELECT Type, COUNT(Type)
FROM Portfolio_Project.us_household_income
GROUP BY Type;

 -- Update Type column
UPDATE  Portfolio_Project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

SELECT DISTINCT(ALand)
FROM Portfolio_Project.us_household_income
WHERE ALand IN (0, '', NULL);

SELECT DISTINCT(AWater)
FROM Portfolio_Project.us_household_income
WHERE AWater IN (0, '', NULL);

SELECT AWater, ALand
FROM Portfolio_Project.us_household_income
WHERE AWater IN (0, '', NULL) AND ALand IN (0, '', NULL);
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA ANALYSIS
SELECT * 
FROM Portfolio_Project.us_household_income_statistics;

SELECT * 
FROM Portfolio_Project.us_household_income;

-- Top 10 Largest States By Land
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM Portfolio_Project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;


-- Top 10 Largest States By Water
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM Portfolio_Project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;


-- Join the tables
SELECT u.State_Name, County, Type, `Primary`, mean, median 
FROM Portfolio_Project.us_household_income u
JOIN Portfolio_Project.us_household_income_statistics us
USING (id)
WHERE mean !=  0;

-- 5 States With Lowest Average Income For An Entire Household
SELECT u.State_Name, ROUND(AVG(mean),2), ROUND(AVG(median),2)
FROM Portfolio_Project.us_household_income u
JOIN Portfolio_Project.us_household_income_statistics us
		USING (id)
WHERE mean !=  0
GROUP BY u.State_Name
ORDER BY 2
LIMIT 5;

-- 5 States With Highest Average Income For An Entire Household
SELECT u.State_Name, ROUND(AVG(mean),2), ROUND(AVG(median),2)
FROM Portfolio_Project.us_household_income u
JOIN Portfolio_Project.us_household_income_statistics us
		USING (id)
WHERE mean !=  0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 5;


SELECT Type, COUNT(Type), ROUND(AVG(mean),2), ROUND(AVG(median),2)
FROM Portfolio_Project.us_household_income u
JOIN Portfolio_Project.us_household_income_statistics us
		USING (id)
WHERE mean !=  0
GROUP BY 1
HAVING COUNT(Type) > 20
ORDER BY 3 DESC;


SELECT u.State_Name, City, ROUND(AVG(mean), 2), ROUND(AVG(median), 2)
FROM Portfolio_Project.us_household_income u
JOIN Portfolio_Project.us_household_income_statistics us
USING (id)
GROUP BY 1, 2
ORDER BY 3 DESC;





