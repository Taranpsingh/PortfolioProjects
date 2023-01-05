Select * 
From PortfolioProject..CovidDeaths$
Where continent is NOT NULL
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country.
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'India'
Order by 1,2

--Looking at Total Cases vs Population
--Shows What percentage of population got Covid
Select Location, date,population, total_cases,(total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Where location = 'India'
Order by 1,2


--Looking at countries with Highest infection rate compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Group By Location,Population
Order by InfectedPercentage desc

--Showing the countries with the highest death count per populataion.

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
Group By Location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN  BY CONTINENT

--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
Group By Continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
Group By date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
--Group By date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT NULL
Order by 2,3	

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT NULL
--Order by 2,3	
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac 



--TEMP Table 

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is NOT NULL
--Order by 2,3	

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations


Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
 where dea.continent is NOT NULL
 --Order by 2,3	

 Create View TotalDeathPercentage as
 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
Group By date
--Order by 1,2

Create View ContinentDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'India'
Where continent is NOT NULL
Group By Continent