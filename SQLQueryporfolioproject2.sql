select *
from portfolioproject.dbo.CovidDeaths
order by 3,4
select *
from portfolioproject.dbo.Covidvaccinations
order by 3,4

-- select columns that we are using

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location =  'United States'
order by 1,2

-- Looking at the Total Cases vs Population
-- Show what percentage of  population got covid
select Location, date, population,total_cases , (total_cases/population)*100 as Percentofpopulationinfected
from portfolioproject..CovidDeaths
where location =  'Nigeria'
order by 1,2

--Looking at Countries with the  highest infection rate  compared to population
select Location, population,max(total_cases) as HighestInfectioncount, max(total_cases/population)*100 as Percentofpopulationinfected
from portfolioproject..CovidDeaths
group by Location, population
order by  Percentofpopulationinfected desc

--To check for Nigeria specifically
select Location, population,max(total_cases) as HighestInfectioncount, max(total_cases/population)*100 as Percentofpopulationinfected
from portfolioproject..CovidDeaths
where location =  'Nigeria'
group by Location, population
order by 1,2

--Show the Countries with highest death count per population
select Location, max(cast(Total_deaths as int))as TotalDeathscount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by TotalDeathscount desc

--By Continent with the highest deathcount
select continent, max(cast(Total_deaths as int))as TotalDeathscount
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathscount desc

-- Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where continent is not null

order by 1,2

select *
from portfolioproject..CovidDeaths

select location, date, total_cases,new_cases, sum(new_cases) as Snm, total_deaths
from portfolioproject..CovidDeaths
where continent is not null
group by total_cases, location,date, new_cases,total_deaths

-- join tables together
select *
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date

  --looking at Total Population vs Vaccination
 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  -- Check earliest date of vaccinations

Select dea.continent, dea.location, dea.date, vac.new_vaccinations
 from portfolioproject..CovidDeaths dea
   join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  and vac.new_vaccinations is not null
  order by 2,3

  -- --looking at Total Population vs Vaccination
 --rolling count of people vaccinated using partition by

 select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location Order by dea.location, dea.date)
as rollingPeoplevaccinated
 from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  -- to calculate percentage of people vaccinated to population using 
  -- rollingPoepleVaccinate, we have to create a temp table or CTE

  --CTE
  with PopvsVac (Continent, Location,Date, Population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location Order by dea.location, dea.date)
as rollingPeoplevaccinated
 from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 --order by 2,3
)
Select *, (rollingPeoplevaccinated/Population)*100 as VacvsPopPercentage
from PopvsVac




  --Using Temp table instead of CTE
  drop table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location Order by dea.location, dea.date)
as rollingPeoplevaccinated
 from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 --order by 2,3

 Select *, (rollingPeoplevaccinated/Population)*100 as VacvsPopPercentage
from #PercentPopulationVaccinated


--creating view to s tore data for later visualizations


Create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location Order by dea.location, dea.date)
as rollingPeoplevaccinated
 from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccinations vac 
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 --order by 2,3

 Create view totalcaseVsDeathUSA as
 select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location =  'United States'
--order by 1,2

select *
from totalcaseVsDeathUSA
