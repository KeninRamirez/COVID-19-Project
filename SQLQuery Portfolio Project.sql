Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Total Cases vs Total Deaths (USA)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Total Cases vs Population (USA)

Select location, date, total_cases, population, (total_cases/population) * 100 as PercentOfPopulation
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Infection vs Population (Countries)

Select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population)) * 100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths$
group by location, population
order by PercentOfPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by HighestDeathCount desc

--Total Death Count by Continent

Select continent, sum(cast(new_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeaths desc

--Global

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Total Population vs Vaccinations (CTE)

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinations)
as(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition By cd.Location 
	Order By cd.Location,cd.Date) as RollingVaccinations
	--,(RollingVaccinations/population)*100
From PortfolioProject..CovidVaccinations$ cv
join PortfolioProject..CovidDeaths$ cd
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/population)*100
from PopvsVac

--Temp Table

Drop table if exists #PercentoPopVaccinated
Create Table #PercentoPopVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingVaccinations numeric
)
Insert into #PercentoPopVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition By cd.Location 
	Order By cd.Location,cd.Date) as RollingVaccinations
From PortfolioProject..CovidVaccinations$ cv
join PortfolioProject..CovidDeaths$ cd
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null
order by 2,3

Select *, (RollingVaccinations/population)*100
from #PercentoPopVaccinated

--Created view to store data

Create view PercentoPopVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition By cd.Location 
	Order By cd.Location,cd.Date) as RollingVaccinations
From PortfolioProject..CovidVaccinations$ cv
join PortfolioProject..CovidDeaths$ cd
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null

Select *
From PercentoPopVaccinated

