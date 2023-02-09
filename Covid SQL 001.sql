/*
 Data on Covid19 Deaths and Vaccinations
 Source: ourworldindata.org/covid-deaths
 Timeline: 2020-02-04 - 2023-02-01
 
Sample Queries using different commands and functions
Table 1: CovidDeaths
Table 2: CovidVaccinations

*/

-- Show two tables to analyze data

SELECT * FROM PortfolioProjectSQL001..CovidDeaths;
SELECT * FROM PortfolioProjectSQL001..CovidVaccinations;

-- Sample Queries on CovidDeaths Table

SELECT
	location,
	date,
	population,
	total_cases,
	total_deaths
FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent IS NOT NULL                 -- continent column with null values shows location name as continent name
ORDER BY 1,2;								-- can use order number by column instead of column name

-- Total Cases VS Total Deaths by Continent
-- Show the continent, total cases and total deaths

SELECT
	continent,
	SUM(CAST(new_cases as bigint)) as total_cases,				-- use SUM function to add up the data and be able to use GROUP BY function
	SUM(CAST(new_deaths as bigint)) as total_deaths				-- change data type NVARCHAR to BIGINT to use the SUM aggregate function
FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent													-- will collapse rows by unique continent name
ORDER BY total_cases DESC;											-- arrange total cases in descending DESC order

-- Check if the table has data on 'Antarctica'

SELECT * FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent LIKE '%ntarc%'										-- use LIKE operator and/or WILDCARDS to find a character string
	OR location LIKE LOWER('antarctica');							-- use LOWER to change string to lower case

-- What is the percentage of dying if infected with covid in your country?

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectSQL001..CovidDeaths	
WHERE continent = 'Asia'
	AND location = 'Philippines';

-- What is the percentage of population infected with covid?
-- Round to 2 decimal places

SELECT 
	location,
	date,
	population,
	total_cases,
	ROUND((total_cases/population)*100, 2) as PopulationInfectedPercentage			-- use ROUND function to round to (any) decimal places *data type must be float
FROM PortfolioProjectSQL001..CovidDeaths	
WHERE continent IS NOT NULL;

-- Show the Population Infected Percentage in each location and order from the highest to the lowest

SELECT
	location,
	(LocationTotalCases/population) * 100 as PopulationInfectedPercentage
FROM (
SELECT
	location,
	population,
	MAX(total_cases) as LocationTotalCases											-- use MAX to get the latest total cases count in each location
FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent <> location
	and location NOT IN (																-- SELECT statement can also be used in WHERE clause as subquery
			SELECT location FROM PortfolioProjectSQL001..CovidDeaths
			WHERE location LIKE '%income%')
GROUP BY location, population) a													-- SELECT statement in FROM clause must have an ALIAS
ORDER BY PopulationInfectedPercentage DESC;

-- Show the locations where there is no covid cases

SELECT DISTINCT																		-- use distinct to group by location as there is no aggregate function used
	location,
	date,
	total_cases
FROM PortfolioProjectSQL001..CovidDeaths
WHERE total_cases IS NULL
	AND location NOT IN (																
			SELECT location FROM PortfolioProjectSQL001..CovidDeaths
			WHERE location LIKE '%income%')
	AND location != continent														-- location has duplicate name with continent
ORDER BY location, date;

-- Show the total death count of each continent

SELECT
	continent,
	SUM(CONVERT(bigint,new_deaths)) as TotalDeathCount										-- CONVERT can be used instead of CAST
FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent IS NOT NULL
	AND location != continent
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- What are the Total Death Percentage of each continent compared to population?

SELECT
	continent,
	SUM(CAST(new_deaths as bigint)) as total_deaths,
	ROUND(SUM(CAST(new_deaths as bigint))/MAX(population) * 100 , 2) as DeathToPopulationPercentage
FROM PortfolioProjectSQL001..CovidDeaths
WHERE continent IS NOT NULL
	AND location != continent
GROUP BY continent
ORDER BY DeathToPopulationPercentage DESC;

-- What is the running total cases count in your country by year?

SELECT
	location,
	YEAR(date) as Year,									-- use YEAR to extract 'year' from datetimestamp
	MAX(total_cases) as RunningTotalCases
FROM PortfolioProjectSQL001..CovidDeaths
WHERE location = 'Philippines'
GROUP BY location, YEAR(date)

-- How many new cases are there in your country each year?

SELECT
	location,
	YEAR(date) as Year,									
	SUM(new_cases) as NewCases
FROM PortfolioProjectSQL001..CovidDeaths
WHERE location = 'Philippines'
GROUP BY location, YEAR(date)

-- What is the total death count vs total cases count in your country by year?

SELECT
	location,
	YEAR(date) as Year,									
	MAX(total_cases) as RunningTotalCases,
	MAX(total_deaths) as RunningTotalDeaths
FROM PortfolioProjectSQL001..CovidDeaths
WHERE location = 'Philippines'
GROUP BY location, YEAR(date)

-- Show location, population, date and total vaccinations

SELECT
	dea.location,
	dea.population,
	dea.date,
	vac.total_vaccinations
FROM PortfolioProjectSQL001..CovidDeaths dea
JOIN PortfolioProjectSQL001..CovidVaccinations vac						-- use INNER JOIN to combine the two tables
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 3

-- Show People Vaccinated VS Population Percentage

WITH VaccinationPopulationPercentage AS									-- use CTE for multiple queries 
(
SELECT
	dea.continent,
	dea.location,
	dea.population,
	dea.date,
	vac.people_vaccinated
FROM PortfolioProjectSQL001..CovidDeaths dea
JOIN PortfolioProjectSQL001..CovidVaccinations vac					
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT
	continent,
	location,
	population,
	date,
	people_vaccinated,
	(people_vaccinated/population) * 100 as VaccinationByPopulationPercentage
FROM VaccinationPopulationPercentage
ORDER BY 2,4

-- Show VaccinationByPopulationPercentage in your country by year

WITH VaccinationPopulationPercentage AS							
(
SELECT
	dea.continent,
	dea.location,
	dea.population,
	dea.date,
	vac.people_vaccinated
FROM PortfolioProjectSQL001..CovidDeaths dea
JOIN PortfolioProjectSQL001..CovidVaccinations vac					
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location = 'Philippines')
SELECT 
	continent,
	location,
	population,
	YEAR(date) as Year,
	MAX(people_vaccinated) as PeopleVaccinated,
	MAX(people_vaccinated)/population * 100 as VaccinationByPopulationPercentage
FROM VaccinationPopulationPercentage
GROUP BY continent, location, population, YEAR(date)
