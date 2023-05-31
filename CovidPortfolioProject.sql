SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



-- Total Cases VS Total Deaths
-- Shows Likelihood of dying by Covid according to County

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Nepal'
ORDER BY 1,2


--CONVERTING DATATYPES TO FLOAT FROM NVARCHAR TO PERFORM CALCULATIONS

--SELECT * 
--FROM CovidDeaths

--EXEC sp_help 'dbo.CovidDeaths';

--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN total_deaths float


-- Total Cases VS Total Population 
-- Percentage of population  who got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Nepal'
ORDER BY 1,2


-- Countries with Highest Infection rate compared to Population

SELECT location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY InfectedPopulationPercentage desc

-- Showing Countries with Highest Death Count Per Population

SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc


-- Breaking Table by Continent
-- Continents with Highest Death Counts

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLobal Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(total_deaths)/SUM(total_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as VaccinatedPeopleCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location= vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, VaccinatedPeopleCount) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as VaccinatedPeopleCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location= vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
)
SELECT *, ( VaccinatedPeopleCount/population)*100 as VacinatedPercentage
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #VacinatedPercentage
CREATE TABLE #VacinatedPercentage
(
continent nvarchar(155),
location nvarchar(155),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedPeopleCount numeric
)

INSERT INTO #VacinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as VaccinatedPeopleCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location= vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null

SELECT *, ( VaccinatedPeopleCount/population)*100 as VacinatedPercentage
FROM #VacinatedPercentage


-- CREATING VIEW TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW VacinatedPercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as VaccinatedPeopleCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location= vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null

