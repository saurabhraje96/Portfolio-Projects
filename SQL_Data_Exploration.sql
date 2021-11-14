


-- Data Exploration Using SQL



Select * 
From CovidProjectData..covid_deaths
Order by 3, 4

Select * 
From CovidProjectData..covid_vaccinations
Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProjectData..covid_deaths
Where continent is not null
Order by 1, 2




-- Looking at total cases vs total deaths in CANADA
-- shows chances of death after getting covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidProjectData..covid_deaths
Where location like '%canada%'
Order by 1, 2




-- Looking at the total cases vs population in CANADA
-- Shows what percentage of people got covid

Select location, date, population,total_cases, (total_cases/population)*100 as infection_rate
From CovidProjectData..covid_deaths
Where location like '%canada%'
Order by 1, 2




-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as total_case_count, MAX((total_cases)/population)*100 as infection_rate
From CovidProjectData..covid_deaths
Where continent is not NULL
Group by location, population
Order by infection_rate DESC




-- Looking at countries with highest death count compared to population
-- We have to convert the data type of total_deaths to integer

Select location, population, MAX(cast(total_deaths as int)) as total_death_count, MAX(cast(total_deaths as int)/population)*100 as death_percentage
From CovidProjectData..covid_deaths
Where continent is not NULL
Group by location, population
Order by death_percentage DESC




-- lets break down the data by continents

Select location, MAX(cast(total_deaths as int)) as total_death_count, MAX(cast(total_deaths as int)/population)*100 as death_percentage
From CovidProjectData..covid_deaths
Where (continent is NULL) AND 
(location not like '%income%')
Group by location
Order by death_percentage DESC




-- Global Data

Select date, SUM(new_cases) as world_new_cases, SUM(cast(new_deaths as int)) as world_new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as world_death_percentage
From CovidProjectData..covid_deaths
Where (continent is not null)
Group by date
Order by 1




-- Looking at total population vs vaccination using CTE

With populationVSvaccination (continent, location, date, population, new_vaccinations, total_vaccinations)
As
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as bigint)) OVER 
(Partition by death.location Order by death.location, death.date) as total_vaccinations
From CovidProjectData..covid_deaths death
Join CovidProjectData..covid_vaccinations vaccine
    On death.location = vaccine.location
	AND death.date = vaccine.date
Where death.continent is not NULL
)
Select *, (total_vaccinations/population)*100 as vaccination_percentage
From populationVSvaccination




-- Looking at total population vs vaccination using Temp Table

Create Table #percent_vaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
Insert into #percent_vaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as bigint)) OVER 
(Partition by death.location Order by death.location, death.date)
From CovidProjectData..covid_deaths death
Join CovidProjectData..covid_vaccinations vaccine
    On death.location = vaccine.location
	AND death.date = vaccine.date
Where death.continent is not NULL

Select *, (total_vaccinations/population)*100 as vaccination_percentage
From #percent_vaccinated




-- Creating view for later visualizations

Create view percent_vaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as bigint)) OVER 
(Partition by death.location Order by death.location, death.date) as total_vaccinations
From CovidProjectData..covid_deaths death
Join CovidProjectData..covid_vaccinations vaccine
    On death.location = vaccine.location
	AND death.date = vaccine.date
Where death.continent is not NULL



-- For visulizations in Tableau

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as world_death_percentage
From CovidProjectData..covid_deaths
Where continent is not NULL

Select continent, SUM(CAST(new_deaths as int)) as total_deaths
From CovidProjectData..covid_deaths
Where (continent not like '%income%') and (continent not like '%world%')
Group by continent
Order by 2 DESC

Select location, population, SUM(new_cases) as total_cases, (SUM(new_cases)/population)*100 as infection_rate
From CovidProjectData..covid_deaths
Where continent is not NULL
Group by location, population
Order by 4 DESC

Select location, population, date, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 as infection_rate
From CovidProjectData..covid_deaths
Group by location, population, date
Order by 5 DESC









