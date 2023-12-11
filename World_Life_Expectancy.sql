SELECT * 
FROM Portfolio_Project.world_life_expectancy;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Cleaning -- 
-- Find duplicates values
SELECT country, year, CONCAT(country, year), COUNT(CONCAT(country, year)) 
FROM Portfolio_Project.world_life_expectancy
GROUP BY country, year, CONCAT(country, year)
HAVING COUNT(CONCAT(country, year))  > 1;

SELECT *
FROM (
SELECT ROW_ID, 
CONCAT(country, year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS row_num
FROM Portfolio_Project.world_life_expectancy
) AS row_table
WHERE row_num >1;

-- Delete duplicates values
DELETE FROM Portfolio_Project.world_life_expectancy
WHERE 
	ROW_ID IN (
    SELECT ROW_ID
FROM (
SELECT ROW_ID, 
CONCAT(country, year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS row_num
FROM Portfolio_Project.world_life_expectancy
) AS row_table
WHERE row_num >1 
);

SELECT DISTINCT(Status)
FROM Portfolio_Project.world_life_expectancy
WHERE status != '';

SELECT DISTINCT(country)
FROM Portfolio_Project.world_life_expectancy
WHERE status = 'Developing';

-- Populate the status column
UPDATE Portfolio_Project.world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (
		SELECT DISTINCT(country)
		FROM Portfolio_Project.world_life_expectancy
		WHERE status = 'Developing');

-- Populate the status column
UPDATE Portfolio_Project.world_life_expectancy t1
JOIN Portfolio_Project.world_life_expectancy t2
	ON t1.Country = t2.Country
    SET t1.Status = 'Developing'
    WHERE t1.Status = ''
    AND t2.Status != ''
    AND t2.Status = 'Developing';

-- Populate the status column
UPDATE Portfolio_Project.world_life_expectancy t1
JOIN Portfolio_Project.world_life_expectancy t2
	ON t1.Country = t2.Country
    SET t1.Status = 'Developed'
    WHERE t1.Status = ''
    AND t2.Status != ''
    AND t2.Status = 'Developed';


SELECT * 
FROM  Portfolio_Project.world_life_expectancy
WHERE Life_expectancy ='';

SELECT t1.country, t1.year, t1.Life_expectancy,
 t2.country, t2.year, t2.Life_expectancy,
  t3.country, t3.year, t3.Life_expectancy,
 ROUND( (t2.Life_expectancy + t3.Life_expectancy) / 2,1)
FROM  Portfolio_Project.world_life_expectancy t1
JOIN Portfolio_Project.world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN Portfolio_Project.world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
WHERE t1.Life_expectancy = '';

-- Populate the Life expectancy column
UPDATE Portfolio_Project.world_life_expectancy t1
JOIN Portfolio_Project.world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN Portfolio_Project.world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1 
SET t1.Life_expectancy = ROUND( (t2.Life_expectancy + t3.Life_expectancy) / 2,1)
WHERE t1.Life_expectancy = '';

SELECT * 
FROM  Portfolio_Project.world_life_expectancy;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Analysis -- 
SELECT *
FROM Portfolio_Project.world_life_expectancy; 

-- Life_expectancy Increase From 2007 - 2022  Per Country (15 Years)
SELECT 
Country,
MIN(Life_expectancy) AS min_Life_expectancy,
MAX(Life_expectancy) AS max_Life_expectancy,
ROUND(MAX(Life_expectancy) - MIN(Life_expectancy),1) AS Life_Increase_15_Years
FROM Portfolio_Project.world_life_expectancy
GROUP BY country
HAVING MIN(Life_expectancy) != 0
AND MAX(Life_expectancy) != 0
ORDER BY Life_Increase_15_Years DESC;

-- Global Life_expectancy Increase From 2007 - 2022  (15 Years)
SELECT year, ROUND(AVG(Life_expectancy), 2)
FROM Portfolio_Project.world_life_expectancy
WHERE  Life_expectancy != 0
GROUP BY year
ORDER BY year; 

-- Checking the correlation between Life Expectancy and GDP
SELECT country, ROUND(AVG(Life_expectancy), 2) AS Life_Exp, ROUND(AVG( gdp), 2) AS GDP
FROM Portfolio_Project.world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0 
AND GDP > 0
ORDER BY GDP DESC;

-- Total Avg GDP
SELECT AVG(GDP)
FROM Portfolio_Project.world_life_expectancy;

-- Checking the correlation between Life Expectancy and GDP
SELECT 
SUM(CASE WHEN GDP >= (SELECT AVG(GDP) FROM Portfolio_Project.world_life_expectancy)
	THEN 1 ELSE 0 END) AS Above_AVG_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= (SELECT AVG(GDP) FROM Portfolio_Project.world_life_expectancy) 
	THEN Life_expectancy ELSE NULL END), 2) AS Above_AVG_GDP_Life_expectancy,
SUM(CASE WHEN GDP <= (SELECT AVG(GDP) FROM Portfolio_Project.world_life_expectancy) 
	THEN 1 ELSE 0 END) AS Below_AVG_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= (SELECT AVG(GDP) FROM Portfolio_Project.world_life_expectancy)
	THEN Life_expectancy ELSE NULL END), 2) AS Below_AVG_GDP_Life_expectancy
FROM Portfolio_Project.world_life_expectancy;


SELECT Status, COUNT(DISTINCT country), ROUND(AVG(Life_expectancy), 2) AS AVG_LIFE_EXP
FROM Portfolio_Project.world_life_expectancy
GROUP BY Status;

-- Checking the correlation between Life Expectancy and BMI
SELECT avg(Life_expectancy), avg(bmi)
FROM Portfolio_Project.world_life_expectancy;

SELECT 
country,
ROUND(AVG(Life_expectancy), 2) AS Life_Exp,
ROUND(AVG( BMI), 2) AS BMI,
CASE
		WHEN ROUND(AVG(Life_expectancy), 2)  > (SELECT AVG(Life_Expectancy) FROM Portfolio_Project.world_life_expectancy) 
			AND ROUND(AVG( BMI), 2) > (SELECT AVG(BMI) FROM Portfolio_Project.world_life_expectancy) 
			THEN 'Both Above Avg'
        WHEN ROUND(AVG(Life_expectancy), 2)  > (SELECT AVG(Life_Expectancy) FROM Portfolio_Project.world_life_expectancy) 
			THEN 'Life_expectancy Above Avg'
        WHEN ROUND(AVG( BMI), 2) > (SELECT AVG(BMI) FROM Portfolio_Project.world_life_expectancy) 
			THEN 'BMI Above Avg'
        ELSE 'Both Below Avg'
END AS Above_Below
FROM Portfolio_Project.world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0 
AND BMI > 0
ORDER BY BMI DESC;

-- Total Adult Mortality RollUp Per Country Using Window Function
SELECT 
country,
year,
Life_expectancy,
Adult_Mortality,
SUM(Adult_Mortality) OVER(PARTITION BY country ORDER BY year) AS Rolling_Total
FROM Portfolio_Project.world_life_expectancy
ORDER BY country;


