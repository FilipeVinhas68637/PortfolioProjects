Select * From PortfolioProject..CovidDeaths$
order by 3,4

Select * From PortfolioProject..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--LOOKING AT TOTAL CASES VS  TOTAL DEATHS


Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS deathPercentage
From PortfolioProject..CovidDeaths$
order by 1,2

--LOOKING AT TOTAL CASES VS  TOTAL DEATHS IN EUA (likelihood of dying if you get infected)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS deathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION IN PORTUGAL

Select location, date, total_cases, population, (total_cases/population) * 100 AS infectedPopulationPercentage
From PortfolioProject..CovidDeaths$
where location = 'Portugal'
order by 1,2

--LOOKING AT COUNTRYS WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location, population, MAX(total_cases) AS HighetsInfectionCount, Max((total_cases/population)) * 100 AS InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
group by location, population
order by infectedPopulationPercentage Desc


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT

Select location, max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is NOT NULL
group by location
order by TotalDeathCount desc

--SHOWING COONTINENT WITH HIGHEST DEATH COUNT

Select continent, max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is NOT NULL
group by continent
order by TotalDeathCount desc


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location, max(CAST(total_deaths as int)) as TotalDeathCount, population, max((total_deaths/population))*100 as DeathsPerPopulationPercentage
From PortfolioProject..CovidDeaths$
where continent is NOT NULL
group by location, population
order by DeathsPerPopulationPercentage desc


--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is NOT NULL

--GLOBAL NUMBERS BY DATE

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is NOT NULL
group by date
order by 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100    XxX USE CTE  OR TEMP TABLE XxX
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--CTE

With PopvsVAc (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVAc


-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedperPopulationPercentage
From #PercentPopulationVaccinated
order by 1, 2, 3


--Creating view to store data for later visualizations


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
