CREATE DATABASE PortfolioProject;
USE PortfolioProject;

-- Modifying the table attributes
UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%d/%m/%Y');

UPDATE covidvaccinations
SET date = STR_TO_DATE(date, '%d/%m/%Y');

ALTER TABLE coviddeaths
MODIFY date DATE,
MODIFY total_cases INT;

ALTER TABLE covidvaccinations
MODIFY date DATE,
MODIFY new_vaccinations INT;

UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = 'None';

UPDATE covidvaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = 'None';

UPDATE coviddeaths
SET continent = NULL
WHERE continent = 'None';

UPDATE coviddeaths
SET 
population = ROUND(population),
total_cases = ROUND(total_cases),
new_cases = ROUND(new_cases);

UPDATE covidvaccinations
SET new_vaccinations = ROUND(new_vaccinations);

ALTER TABLE coviddeaths
MODIFY total_deaths INT;

-- Entire table data
SELECT * FROM coviddeaths;

-- Select the data we are going to be using 
SELECT location, date , total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract with Covid 19 in your country
SELECT location, date , total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 3) AS death_ratio
FROM PortfolioProject.coviddeaths
WHERE location REGEXP 'Israel' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at the total cases vs population
-- Shows what percentage of population got Covid 19
SELECT location, date , population, total_cases, ROUND((total_cases/population) * 100, 3) AS infection_rate
FROM PortfolioProject.coviddeaths
WHERE location REGEXP 'Israel'  AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population) * 100), 3) AS HigestInfectionRatio
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1, 2
ORDER BY HigestInfectionRatio DESC;

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Lets break things down by continent
-- Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Lets break things down by locations
-- Showing locations with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global numbers 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases) * 100), 3) AS TotalDeathRatio
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccinations
-- Look at Africa, Zimbabwe for a good example of this query (its in the end of the table)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE 
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)

SELECT * , ROUND((RollingPeopleVaccinated/population * 100), 3) AS TotalVaccinatedRatio
FROM PopVsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
continent VARCHAR (255),
location VARCHAR (255),
date DATETIME,
population NUMERIC (65,2),
new_vaccinations NUMERIC (65,2),
RollingPeopleVaccinated NUMERIC (65,2)
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT *, ROUND((RollingPeopleVaccinated/population * 100), 3) AS TotalVaccinatedRatio
FROM PercentPopulationVaccinated;

-- Creating a VIEW to store data for later visualizations (Tableau/Power BI)
CREATE VIEW PercentPopulationVaccinatedView 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT * FROM PercentPopulationVaccinatedView;



