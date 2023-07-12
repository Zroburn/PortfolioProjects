Select *
From master.dbo.CovidVaccinations$
order by 3,4

--Had to explore the data further to get to this code. Need to remove null values for time being.
Select *
From master.dbo.CovidVaccinations$
Where continent is not null
order by 3,4


--Select *
--From master.dbo.CovidDeaths$
--order by 3,4

--Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From master.dbo.CovidDeaths$
order by 1,2

--Ordered by Location. Than by date. Looking at total case vs total deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From master.dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, population,total_cases,  (total_cases/population)*100 as Percentage PercentPopulationInfected
From master.dbo.CovidDeaths$
--Where location like '%states%'
order by 1,2

Select location, population,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From master.dbo.CovidDeaths$
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries highest death per population
--To "CAST" is to temporarily change the data type to the data type of choice
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THIS DOWN BY CONTINENT

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From master.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccinations
---
Select *
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location)
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--use "Convert" to change the data type

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location)
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Organizing the data
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 THIS DOES NOT WORK. CAN'T USE A TEMP COLOMN FOR THIS FUNCTION
from master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location =  vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
 --If the number of columns in the CTE is different than the number of columns in the code. You're going to have a bad time.
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
order by 2,3


--Temp Table
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
order by 2,3



--Creating visual to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



select * 
from PercentPopulationVaccinated