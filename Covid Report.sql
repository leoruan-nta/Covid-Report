Select* 
From CovidDeaths$
where continent is not null
Order by 3,4

Select* 
From CovidVaccinations$
where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
where continent is not null
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidDeaths$
Where location like '%States%' and continent is not null
Order by 1,2

Select location, date, total_cases, total_deaths, (total_cases/population)*100 as infected_percentage
From CovidDeaths$
Where location like '%States%' and continent is not null
Order by 1,2


Select location, population, Max(total_cases) as highest_infected_count, Max(total_cases/population)*100 as highest_infected_percentage
From CovidDeaths$
where continent is not null
Group by location, population
Order by highest_infected_percentage desc

Select location, Max(Cast(total_deaths as int)) as total_death_count
From CovidDeaths$
where continent is not null
Group by location
Order by total_death_count desc

Select location, Max(Cast(total_deaths as int)) as total_death_count
From CovidDeaths$
where continent is null
Group by location
Order by total_death_count desc

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidDeaths$
Where continent is not null
Order by 1,2

Select date, Sum(new_cases) as total_cases, Sum(convert(int, new_deaths)) as total_deaths, Sum(convert(int, new_deaths))/Sum(new_cases)*100 as death_percentage
From CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

Select Sum(new_cases) as total_cases, Sum(convert(int, new_deaths)) as total_deaths, Sum(convert(int, new_deaths))/Sum(new_cases)*100 as death_percentage
From CovidDeaths$
Where continent is not null

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) 
Over(Partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

With Popvsvac (continent, location, date, population, new_vaccinations, rolling_vaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) 
Over(Partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
)
Select*, (rolling_vaccinated/population)*100 as vaccinated_percentage
From Popvsvac

Drop table if exists Percentage_Population_Vaccinated 
Create table Percentage_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric,
)
Insert into Percentage_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) 
Over(Partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
--Where dea.continent is not null
Select*, (rolling_vaccinated/population)*100 as vaccinated_percentage
From Percentage_Population_Vaccinated

