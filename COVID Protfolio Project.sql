Select *
From  ProtfolioProject..CovidDeaths$
order by 3,4

Select *
From  ProtfolioProject..CovidVaccinations$
order by 3,4

 Select Data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject..CovidDeaths$
where continent is not null
order by 1,2


---- Looking at Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From ProtfolioProject..CovidDeaths$
where location like '%canada%'
order by 1,2

----Looking at Total cases vs Population

Select Location, date, Population, total_cases,  (total_cases/population) *100 as CasePercentage
From ProtfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

---- Looking at Countries with highest infection rate compared to Populatiin

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max(total_cases/population) *100 as CasePercentage
From ProtfolioProject..CovidDeaths$
where location like '%canada'
Group by Location, population
--order by CasePercentage desc

---- Showing Countires with Highest Death Count per Population

Select Location, MAX( cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths$
where location like '%canada'
where continent is not null 
Group by Location
order by TotalDeathCount desc

---- Grouping by Continent

Select continent, MAX( cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths$
---where location like '%canada'
where continent is not null 
Group by continent
order by TotalDeathCount desc


---- Global Numbers across the country grouped by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)* 100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2


-- Overall Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)* 100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location , Date , Population , new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations




Create VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated



