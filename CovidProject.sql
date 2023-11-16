CREATE DATABASE PortfolioProject;
USE PortfolioProject;

-- Modifying the table attributes
ALTER TABLE coviddeaths
MODIFY date DATE;

ALTER TABLE coviddeaths
MODIFY total_deaths INT;

UPDATE coviddeaths
SET date = DATE_FORMAT(date, '%Y-%m-%d');

UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '';

-- Select the data we are going to be using 
SELECT location, date , total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract with Covid 19 in your country
SELECT location, date , total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 2) AS death_ratio
FROM PortfolioProject.coviddeaths
WHERE location REGEXP 'Mexico' AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at the total cases vs population
-- Shows what percentage of population got Covid 19
SELECT location, date , population, total_cases, ROUND((total_cases/population) * 100, 2) AS infection_rate
FROM PortfolioProject.coviddeaths
WHERE location REGEXP 'Mexico'  AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population) * 100), 2) AS infection_ratio
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_ratio DESC;

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS Total_death_count
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC;

-- Lets break things down by continent
-- Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) AS Total_death_count
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC;

-- Global numbers 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases) * 100), 2) AS death_ratio
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccinations
-- Look at Africa, Zimbabwe for a good example of this query (its in the end of the table)
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
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
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)

SELECT * , (RollingPeopleVaccinated/population) * 100
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
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_vaccinations,
    SUM(CASE WHEN vac.new_vaccinations REGEXP '^[0-9]+$' THEN CAST(vac.new_vaccinations AS SIGNED) ELSE 0 END) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject.coviddeaths dea 
JOIN 
    PortfolioProject.covidvaccinations vac 
ON 
    dea.location = vac.location AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
    AND vac.new_vaccinations REGEXP '^[0-9]+$' -- Filter only numeric values
ORDER BY 
    dea.location, dea.date;

SELECT * , (RollingPeopleVaccinated/population) * 100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM percent_population_vaccinated;



