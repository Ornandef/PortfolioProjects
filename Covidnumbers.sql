SELECT *
FROM PortfolioProject.dbo.covid_deaths
ORDER BY 3,4




SELECT *
FROM PortfolioProject.dbo.covid_vaccinations
ORDER BY 3,4

select location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.covid_deaths
order by 1,2

--looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
where location like '%States%'
order by 1,2

--looking at total cases vs population

select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.covid_deaths
WHERE location like '%States%'
order by 1,2

--looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 FROM PortfolioProject.dbo.covid_deaths
 GROUP BY location, population
order by PercentPopulationInfected desc

--This is showing countries with Highest Death Count per Population


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject.dbo.covid_deaths
 where continent is not null
 GROUP BY location
order by TotalDeathCount desc

--let's break things down by continent


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject.dbo.covid_deaths
 where continent is not null
 GROUP BY continent
order by TotalDeathCount desc



-- Global Numbers

select date, SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
where continent is not null
group by date
order by 1,2

create view  GlobalNumbers as
select date, SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
where continent is not null
group by date
--order by 1,2

select SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
where continent is not null

order by 1,2

--looking at total population  vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date;

create view TotalPopvsVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint))OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (continent, location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating a view to store data for later visualization


Create View PercentPopulationVaccinate as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid_deaths dea
 join PortfolioProject.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
