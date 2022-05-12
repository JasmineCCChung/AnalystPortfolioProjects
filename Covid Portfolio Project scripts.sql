select *
From PortfolioProject..CovidDeaths 
Order by total_cases desc

select *
From PortfolioProject..CovidVaccinations
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths (shows the likelihood of dying if you contract Covid in the States)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at total cases vs population (shows the percentage of people contracting Covid in Taiwan)
Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%taiwan%' and continent is not null
Order by 1,2

--Looking at country with the highest infection rate
Select Location, population, Max(total_cases) as HighestInfection, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected DESC

-- Look at continents with the highest death count
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%income'
Group by location
Order by TotalDeathCount DESC

-- Look at continents using continent column
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Looking at country with the highest death count
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC

-- Looking at Global numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
-- Group by date
Order by 1,2

-- Look at total population vs vaccinations using CTE
With PopvsVax (continent, location, date, population, new_vaccinations, RollingVaxxed)
as
(
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(cast(Vac.new_vaccinations as int)) over (Partition by Dea.location Order by Dea.location, Dea.date) as RollingVaxxed
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location = Vac.location and Dea.date = Vac.date
Where Dea.continent is not null
)
Select *, (RollingVaxxed/population)*100
From PopvsVax

-- Look at total population vs vaccinations using temp table
Drop Table if exists #PercentPopulationVaxxed
Create Table #PercentPopulationVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaxxed numeric
)

Insert into #PercentPopulationVaxxed
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(bigint,Vac.new_vaccinations)) over (Partition by Dea.location Order by Dea.location, Dea.date) as RollingVaxxed
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location = Vac.location and Dea.date = Vac.date
Where Dea.continent is not null

Select *, (RollingVaxxed/population)*100
From #PercentPopulationVaxxed


-- Create view to store data for visualizations
Create View PercentPopulationVaxxed as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(bigint,Vac.new_vaccinations)) over (Partition by Dea.location Order by Dea.location, Dea.date) as RollingVaxxed
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location = Vac.location and Dea.date = Vac.date
Where Dea.continent is not null

select *
From PercentPopulationVaxxed
