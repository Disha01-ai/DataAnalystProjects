Select * From Covid..CovidDeaths$
where continent is not null
order by 3,4 

Select * From Covid..CovidVaccinations$
order by 3,4

Select Location,date, total_cases, new_cases,total_deaths,population  
From Covid..CovidDeaths$
where continent is not null
order by 1,2

Select Location,date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as death_percentage
From Covid..CovidDeaths$
Where location like 'India'
and continent is not null
order by 1,2

Select Location,date, population, total_cases,(total_cases/population)* 100 as Covid_Affected
From Covid..CovidDeaths$
Where location like 'India'
order by 1,2

Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as Covid_Affected
From Covid..CovidDeaths$
--Where location like 'India'
Group by location,population
order by Covid_Affected desc

Select Continent,MAX(cast(total_deaths as int)) as HighestDeathCount
From Covid..CovidDeaths$
--Where location like 'India'
where continent is not null
Group by continent
order by HighestDeathCount desc


Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From Covid..CovidDeaths$
--Where location like 'India'
where continent is null
Group by location
order by HighestDeathCount desc

Select date, SUM(new_cases)as toal_cases,SUM(cast(new_deaths as int))as toal_deaths, Sum(cast(new_deaths as int))/SUM
(New_cases)* 100 as Covid_Affected
From Covid..CovidDeaths$
--Where location like 'India'
where continent is not null
Group by date
order by 1,2



With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
From Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
From Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
Select * , (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated

Create View PopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
From Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null

Select * from PopulationVaccinated
