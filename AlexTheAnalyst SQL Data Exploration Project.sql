SELECT *
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..covidvaccinations
--ORDER BY 3, 4; 

-- Select Data I Will Be Using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1, 2; 

--Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying with covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2; 

-- Looking at Total Cases vs. Population
-- Shows percentage of people who got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2; 

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS total_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..coviddeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing Countries with Highest DeathCount Per Population
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Break Down By Continent
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing Continents With Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2; 

--Looking At Total Population vs. Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM PortfolioProject..coviddeaths deaths
JOIN PortfolioProject..covidvaccinations vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM PortfolioProject..coviddeaths deaths
JOIN PortfolioProject..covidvaccinations vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM PortfolioProject..coviddeaths deaths
JOIN PortfolioProject..covidvaccinations vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Creating Views for Visualizations

CREATE VIEW PercentPopVac2 AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM PortfolioProject..coviddeaths deaths
JOIN PortfolioProject..covidvaccinations vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL;

