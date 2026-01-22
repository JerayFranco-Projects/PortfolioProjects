SELECT *
FROM PortfolioProject.dbo.CovidDeaths

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4

--Select data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

UPDATE PortfolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = '';

-- Replace 0 with NULL in total_cases
UPDATE PortfolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

-- Replace 0 with NULL in total_deaths
UPDATE PortfolioProject.dbo.CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = 0;

-- Replace 0 with NULL in new_cases
UPDATE PortfolioProject.dbo.CovidDeaths
SET new_cases = NULL
WHERE new_cases = 0;

-- Replace 0 with NULL in new_deaths
UPDATE PortfolioProject.dbo.CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = 0;

-- Replace 0 with NULL in population (optional, only if some rows have 0)
UPDATE PortfolioProject.dbo.CovidDeaths
SET population = NULL
WHERE population = 0;


UPDATE PortfolioProject.dbo.CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = '';

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_deaths FLOAT;



ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN date DATE;

-- Convert empty total_cases to NULL
UPDATE PortfolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = '';

-- Convert empty population to NULL
UPDATE PortfolioProject.dbo.CovidDeaths
SET population = NULL
WHERE population = '';

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN population FLOAT;

UPDATE PortfolioProject.dbo.CovidDeaths
SET Location = NULL
WHERE Location = '';

UPDATE PortfolioProject.dbo.CovidDeaths
SET Continent = NULL
WHERE Continent = '';

UPDATE PortfolioProject.dbo.CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';




SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / NULLIF(Population,0) * 100) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected;  -- smallest to largest







-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_rate
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY Location, date;

SELECT 
    Location, 
    date, 
    CASE WHEN total_cases = '' THEN NULL ELSE CAST(total_cases AS FLOAT) END AS total_cases_num,
    CASE WHEN total_deaths = '' THEN NULL ELSE CAST(total_deaths AS FLOAT) END AS total_deaths_num,
    CASE 
        WHEN total_cases = '' OR total_deaths = '' THEN NULL
        ELSE CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)
    END AS death_rate
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY Location, date;

UPDATE PortfolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = '';

UPDATE PortfolioProject.dbo.CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = '';



-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY DeathPercentage ASC, date ASC;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (Total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
Group by Location
order by TotalDeathCount desc




-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 AS DeathPercentage -- total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date)
    as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE FOR THIS PORTION

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date)
    as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as GrandTotal
From PopvsVac


-- CREATING A TEMP TABLE INSTEAD OF CTE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date)
    as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as GrandTotal
From #PercentPopulationVaccinated

-- Creating a view to store data for my visualizations in Tableau

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date)
    as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3