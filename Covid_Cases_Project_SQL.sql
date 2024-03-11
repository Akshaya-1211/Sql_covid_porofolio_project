use Portofolio; 
select * from CovidDeaths; 

select * from CovidVaccinations;  

--  Total Cases V/S Total Deaths 
-- we are going to caluculate deaths percentage 

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_percent from CovidDeaths;

-- Deaths Percentages in USA
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_percent from CovidDeaths
where location ='Brazil';   

--- finding percentage of total cases vs total population 
select location,date,total_cases,population ,(total_cases/population)*100 as population_percent from CovidDeaths
where location like '%states%' order by 1,2; 

-- how much percentage population infected for each country;
select location,population,max(total_cases) as highest_infection,max((total_cases/population)*100) as population_percent 
from CovidDeaths group by location,population 
order by population_percent desc;  

-- find country wise deaths

select location,count(population) as highest_pop,count(total_cases)as number_of_Cases,count(total_deaths) as no_of_deaths  from CovidDeaths 
group by location,population
order by location ; 

-- Continent wise death cases 
select continent,sum(population) as tot_population,sum(cast(total_deaths as int)) as total_death_cases ,
max(total_deaths/population)*100 as percnt_of_deaths
from CovidDeaths  
where continent is not null
group by continent 
order by total_death_cases desc;

-- year wise total_cases in different locations

select year(date) as year_wise, location,sum(total_cases) tot_cases from CovidDeaths
group by year(date),location
order by year_wise asc
; 


select year(date) as year_wise, location,sum(total_cases) tot_cases from CovidDeaths
where year(date)=2020
group by year(date),location
order by year_wise asc
; 

select year(date) as year_wise, location,sum(total_cases) tot_cases from CovidDeaths
where year(date)=2020 and location='Europe'
group by year(date),location
order by year_wise asc
;  

-- location wise weekly admissions 
select sum(cast(new_vaccinations as int)) as tot_vaccinations ,location  from CovidDeaths 
where new_vaccinations is not null and continent is not null
group by location
order by tot_vaccinations desc; 

-- total deaths year wise 
select year(date) as year_wise,sum(cast(total_deaths as int)) as tot_deaths from CovidDeaths
group by year(date); 

-- fully vaccinated members  in median age 


select year(cd.date) as year,cd.location,cv.median_age,cd.people_fully_vaccinated_per_hundred from CovidDeaths cd
inner join CovidVaccinations cv on cd.date=cv.date
where cd.people_fully_vaccinated_per_hundred is not null and cd.continent is not null
GROUP BY cd.location, YEAR(cd.date), cv.median_age, cd.people_fully_vaccinated_per_hundred;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

