--Select * from PortfolioProject..CovidDeaths
--order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Data Exploration

-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths * 100 / total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%india%'
ORDER BY 1, 5 desc;

-- What percentage of people got covid
SELECT location, date, Population, total_cases, (total_cases / Population)*100 AS DeathPopPercentage
FROM PortfolioProject..CovidDeaths
where location like '%india%'
ORDER BY 1, 2 desc;

-- Countries with highest infection rates
SELECT location, Population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases / Population))*100 AS MaxDeathPopPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
GROUP BY location, Population
ORDER BY MaxDeathPopPercentage desc;

-- Highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

-- 
SELECT 
       SUM(new_cases) as total_newcases,
       SUM(new_deaths) as total_newdeaths,
       CASE WHEN SUM(new_cases) <> 0
            THEN (SUM(new_deaths) * 100.0) / SUM(new_cases)
            ELSE 0
       END as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- total population vs new vaccination 

SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolled
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Create a CTE

WITH PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinatedRolled) AS
(
    SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolled
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *
FROM PopsvsVac
ORDER BY Location, Date;


-- temp table

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	PeopleVaccinatedRolled numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolled
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

Select * from #PercentPopulationVaccinated


--- create view to store data for later visualization

DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinat AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolled
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
