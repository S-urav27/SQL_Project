
--SQL DATA EXPLORATION PROJECT 
--skills used: joins , CTE,Temp Tables ,windows Functions , Aggregate Functions , Creating Views ,converting Data Types 

SELECT  * 
FROM [portfolio_project ]..covid_deaths
WHERE continent IS NOT null 
ORDER BY 3,4

--select data that we are going to be starting with 

SELECT location , date , total_cases , new_cases , total_deaths , population 
FROM [portfolio_project ]..covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

--looking at total_cases vs total_deaths 
--shows likelihood of dying if you got infected by covid in india 
SELECT location , date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage 
FROM [portfolio_project ]..covid_deaths
WHERE  location = 'india'
AND continent IS NOT NULL  
ORDER BY  1,2

--looking at total_cases vs population
--shows what % of population got infected 
SELECT location , date,population,total_cases,(total_cases/population)*100 AS percentage_population_infected 
FROM  [portfolio_project ]..covid_deaths
--where location like 'in%'
ORDER BY  1,2

--Countries with highest infection rate compared to population 

SELECT  location ,population,MAX(total_cases) AS highest_infection_count ,MAX((total_cases/population))*100 AS percentage_population_infected
FROM [portfolio_project ]..covid_deaths
--where location like 'in%'
GROUP BY location,population 
ORDER BY  percentage_population_infected DESC 

--Countries with highest death count per population .

SELECT location ,MAX(CAST(total_deaths AS INT )) AS total_death_count  
FROM [portfolio_project ]..covid_deaths
--where location like 'in%'
WHERE continent is not null
GROUP BY location 
ORDER BY total_death_count DESC 

--BREAKING THINGS DOWN BY CONTINENT 

--showing continents with the highest death count per population 

SELECT continent ,MAX(CAST(total_deaths AS int )) AS total_death_count FROM [portfolio_project ]..covid_deaths
--where location like 'in%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--GLOBAL NUMBERS 
-- showing total_new_cases & total_new_deaths by each date 
SELECT SUM(new_cases ) AS total_cases , SUM(CAST(new_deaths AS INT)) AS total_deaths , SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Deathpercentage
FROM [portfolio_project ]..covid_deaths
WHERE continent is not null
--group by date 
ORDER BY 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one covid vaccine 

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM [portfolio_project ]..covid_deaths dea
JOIN [portfolio_project ]..covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USING CTE to perform calculatio on partition by in previous query 
WITH PopvsVac (continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS 
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM [portfolio_project ]..covid_deaths dea
JOIN [portfolio_project ]..covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--using Temp Table to perform Calculation on partition by in previous query  

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
Location nvarchar(255),
DATE datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM [portfolio_project ]..covid_deaths dea
JOIN [portfolio_project ]..covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations 

CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM [portfolio_project ]..covid_deaths dea
JOIN [portfolio_project ]..covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3





