select *
from CovidProject..CovidDeaths
where continent is not null
ORDER BY 3, 4

select *
from CovidProject..CovidVaccinations
ORDER BY 3, 4


select Location, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
where continent is not null
order by 1,2


--total cases vs total deaths

select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidProject..CovidDeaths
where location like '%state%',continent is not null
order by 1,2


--total cases vs population

select Location, population, total_cases, (total_cases/population)*100 as case_percentage
from CovidProject..CovidDeaths
where location like '%state%', continent is not null
order by 1,2


--countries with highest infection rate

select Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_percentage
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by Location, population
order by infection_percentage desc


--highest death count per population

select Location, MAX(cast(total_deaths as INT)) as total_death_count
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by Location
order by total_death_count desc


--highest death count per continent

select continent, MAX(cast(total_deaths as INT)) as total_death_count
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by total_death_count desc


--global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from CovidProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--total population vs vaccination
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vacc)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rolling_people_vacc
from CovidProject..CovidDeaths dea
join  CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (rolling_people_vacc / population) *100
from PopvsVac


--temp table

drop table if exists #PercentPopulationVacc
create table #PercentPopulationVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vacc numeric
)


insert into #PercentPopulationVacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rolling_people_vacc
from CovidProject..CovidDeaths dea
join  CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (rolling_people_vacc / population) *100
from #PercentPopulationVacc


--view to store data for visualizations

create view PercentPopulationVacc as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rolling_people_vacc
from CovidProject..CovidDeaths dea
join  CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVacc











