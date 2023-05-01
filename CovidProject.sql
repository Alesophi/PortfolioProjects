
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data to use


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total cases vs Total Deaths
--Death likelihood

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not null
Order by 1,2

--Looking at Total cases vs Population


Select Location, date, Population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by PercentagePopulationInfected desc

--Showing the countries with the Highest Death count per popluation

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathcount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.Location, dea. Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	Order by 2,3

	-- USE CTE

	With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.Location, dea. Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--Order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

	--Temp Table

	Drop Table if exists #PercentPopulationVaccinated
	Create Table #percentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.Location, dea. Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--Order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	--Creating view to store data for later visulaization

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.Location, dea. Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--Order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated