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


-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2
    
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_rate
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY Location, date;

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
-- Using Join function

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date)
    as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

--  CTE USE FOR THIS PORTION

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

