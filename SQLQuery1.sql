select *
from PORTFOLIODATABASE..CovidDeaths
order by 3,4


--select *
--from PORTFOLIODATABASE..CovidVaccinations$
--order by 3,4
---we are going to use the data now
select Location,date,total_cases, new_cases, total_deaths,population
from PORTFOLIODATABASE..CovidDeaths
order by 1,2
 --total cases  vs total deaths
select Location,date,total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PORTFOLIODATABASE..CovidDeaths
where location like '%India%'
order by 1,2

--Total cases vs Population, what %of population got covid
select Location,date,total_cases, Population,(total_cases/population)*100 as PercentagepopulationInfected
from PORTFOLIODATABASE..CovidDeaths
--where location like '%India%'
order by 1,2

--highest infection rates vs population
select Location,MAX(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as percentagepopulationInfected
from PORTFOLIODATABASE..CovidDeaths
--where location like '%India%'
group by location,population
order by  percentagepopulationInfected desc

--countries with highest count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PORTFOLIODATABASE..CovidDeaths
--where location like '%India%'
where continent is not null
group by location,population
order by TotalDeathCount 
--break thingd=s by continent

--continents with highest death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PORTFOLIODATABASE..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

--------global number
select SUM(new_cases) as TOTALCASES ,SUM(cast(new_deaths as int))as TOTAL_DEATHS,Sum(cast(New_deaths as int))/SUM(New_cases)*100
as DeathPercentage
from PORTFOLIODATABASE..CovidDeaths
--where continent like '%India%'
where continent is not null
--group by date
order by 1,2
--vacination
--population vs vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PORTFOLIODATABASE..CovidDeaths dea
join PORTFOLIODATABASE..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--use cte
with PopvsVac (Continent, Location, date, population, New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PORTFOLIODATABASE..CovidDeaths dea
join PORTFOLIODATABASE..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PORTFOLIODATABASE..CovidDeaths dea
join PORTFOLIODATABASE..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--view to store data

create View PercentagePopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PORTFOLIODATABASE..CovidDeaths dea
join PORTFOLIODATABASE..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select *
from PercentagePopulationVaccinated
