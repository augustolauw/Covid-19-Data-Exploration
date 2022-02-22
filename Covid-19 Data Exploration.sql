-- Covid-19 Data Exploration by Augusto Jonathan Lauw-------------------------------------------------------------------------------------

SELECT *
FROM ProjectSQL..CovidCases

-- The Highest Percentage of Cases in Every Country------------------------------------------------------------------------------------------

SELECT location, MAX(total_cases) as HighestCumulativeCases, population, MAX((total_cases/population))*100 AS TotalCasesPercentage
FROM ProjectSQL..CovidCases cases
GROUP BY location, population
ORDER BY 4 desc;

-- The Highest Percentage of Fully Vaccinated in Every Country-------------------------------------------------------------------------------

SELECT cases.continent ,cases.location, (MAX(vaccination.people_fully_vaccinated)/cases.population)*100 AS VaccinationPercentage
FROM ProjectSQL..CovidCases cases JOIN ProjectSQL..CovidVaccination vaccination
ON cases.date=vaccination.date AND cases.location=vaccination.location
WHERE vaccination.people_fully_vaccinated is not null and cases.continent is not null
GROUP BY cases.continent ,cases.location, cases.population
ORDER BY 3 desc

-- The Highest Percentage of Fully Vaccinated in Every Continent-----------------------------------------------------------------------------

SELECT cases.continent ,MAX(vaccination.people_fully_vaccinated/cases.population)*100 AS VaccinationPercentage
FROM ProjectSQL..CovidCases cases JOIN ProjectSQL..CovidVaccination vaccination
ON cases.date=vaccination.date AND cases.location=vaccination.location
WHERE vaccination.people_fully_vaccinated is not null and cases.continent is not null
GROUP BY cases.continent
ORDER BY 2 desc

-- The Highest Death Percentage in Asia (2022)----------------------------------------------------------------------------------------------

SELECT cases.location, MAX(cases.total_deaths/cases.total_cases)*100 AS DeathPercentage
FROM ProjectSQL..CovidCases cases JOIN ProjectSQL..CovidVaccination vaccination
ON cases.date=vaccination.date AND cases.location=vaccination.location
WHERE vaccination.people_fully_vaccinated is not null AND cases.continent='Asia' AND cases.date >='2022-01-01'
GROUP BY cases.location
ORDER BY 2 desc

-- CTE Usage to Count Cumulative Test in Every Country Everyday -----------------------------------------------------------------------------

WITH CTE(Continent, Location, Date, Total_Deaths, Population, New_Tests, CumulativeTests)
AS
(
SELECT cases.continent ,cases.location,cases.date, cases.total_deaths, cases.population, vaccination.new_tests, 
SUM(CONVERT(bigint,vaccination.new_tests)) OVER (PARTITION BY cases.location ORDER BY cases.location,cases.date) as CumulativeTests
FROM ProjectSQL..CovidCases cases JOIN ProjectSQL..CovidVaccination vaccination
ON cases.date=vaccination.date AND cases.location=vaccination.location
WHERE vaccination.people_fully_vaccinated is not null and cases.continent is not null and vaccination.new_tests is not null
)
SELECT *, (CumulativeTests/Population)*100 AS CumulativeTestsPercentage
FROM CTE

-- Create View------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW CumulativeTest as
SELECT cases.continent ,cases.location,cases.date, cases.total_deaths, cases.population, vaccination.new_tests, 
SUM(CONVERT(bigint,vaccination.new_tests)) OVER (Partition by cases.location ORDER BY cases.location, cases.date) as CumulativeTests
FROM ProjectSQL..CovidCases cases JOIN ProjectSQL..CovidVaccination vaccination
ON cases.date=vaccination.date AND cases.location=vaccination.location
WHERE vaccination.people_fully_vaccinated is not null and cases.continent is not null and vaccination.new_tests is not null

--Thank You-----------------------------------------------------------------------------------------------------------------------------------