Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

-- Selecting the Data

Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths (Likelihood of Dying )

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths in INDIA

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location='INDIA'
Order by 1,2

--Avg Death Percentage in India

Select AVG(total_deaths/total_cases * 100) AS AvgDeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location='India' 
Order by 1,2

--Total Cases vs Population (% of Population got Covid)

Select Location, date, total_cases, population, (total_cases/population * 100) AS InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
where location = 'India'
Order by 1,2 

--Countries with Highest Infection Rate compared to population


Select Location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population * 100)) AS InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
Group By Location, Population
Order by 5 DESC

-- Showing the countries with Highest Death Count per population 

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By Location, Population
Order by TotalDeathCount DESC

-- BY CONTINENT
-- Continents with highest death counts per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is  not null
Group By continent
Order by TotalDeathCount DESC

-- GLOBAL NUMBERS

Select SUM (new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
--Group by date
Order by 1,2

-- Population vs Vaccination

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM( cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject.dbo.CovidDeaths dea

Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location= vac.location and dea.date = vac.date
where dea.continent is not null
Order by Location,date

--Using Common Table Expression

With PopvsVac (Continent, Location, Date, Population, new_vacciantions, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM( cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject.dbo.CovidDeaths dea

Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location= vac.location and dea.date = vac.date
where dea.continent is not null
--Order by Location,date
)

Select * ,(RollingPeopleVaccinated/Population * 100)
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM( cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject.dbo.CovidDeaths dea

Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location= vac.location and dea.date = vac.date
where dea.continent is not null
--Order by Location,date

Select * ,(RollingpeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- STORING DATA For VISUALISATION

Create View PercentPopultionVaccinated as

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM( cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject.dbo.CovidDeaths dea

Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location= vac.location and dea.date = vac.date
where dea.continent is not null
--Order by Location,date

Select *
From PercentPopultionVaccinated

