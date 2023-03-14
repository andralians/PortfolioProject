select * from PortProject..CovidVaccinations
order by 3,4;

select * from PortProject..CovidDeaths
order by 3,4;

--looking at total death vs total cases
	select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
	from PortProject..CovidDeaths
	where location like ('%states%')
	order by 5 desc;

-- percentage population of covid
	select location, date, population, total_cases, (total_cases/population)*100 as death_percentage
	from PortProject..CovidDeaths
	where location like ('%states%')
	order by 1,2;

	--looking countries with highest infection rate compared to population

	select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as population_infected_pct
	from PortProject..CovidDeaths
	--where location like ('%states%')
	group by location, population
	order by population_infected_pct desc;

	--showing countries with highest death case per population

	select location, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	group by location
	order by TotalDeathCount desc;

-- get rid with null continent
select * from PortProject..CovidDeaths
--where continent is not null
order by 3,4;


-- not null applied to get rid wrong location

select continent, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	where continent is not null
	group by continent
	order by TotalDeathCount desc;

-- using HAVING for filtering null on TotalDeathCount 

select top 1 continent, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	where continent is not null
	group by continent
	having max(cast(total_deaths as int)) is not null
	order by TotalDeathCount desc 
	;


	-- agregate highest death by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	where continent is not null
	group by continent
	order by TotalDeathCount desc;

-- this one with null is accurate aggregation somehow, but only show the continent without any breakdown

	select location, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	where continent is null
	group by location
	order by TotalDeathCount desc;

-- now looking the world... on continent for the accurate agg

	select continent, max(cast(total_deaths as int)) as TotalDeathCount 
	from PortProject..CovidDeaths
	where continent is not null
	group by continent
	order by TotalDeathCount desc;


-- GLOBAL NUMBERS

	select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
		from PortProject..CovidDeaths
		where continent is not null
		group by date 
		order by date;



--TOTAL CASES
	
	select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
		from PortProject..CovidDeaths
		where continent is not null
		--order by date;

-- LOOKING AT TOTAL POPULATION VS VACCINATION
	--partition by used for looking at the total of new vaccionations on every location
	--so every row has a column of SUM new vacc based on location

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,  
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vacc
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
		where dea.continent is not null
		--and vac.new_vaccinations is not null
		order by 2,3;




--USE TEMP TABLE

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated (
	
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vacc numeric,
	total_new_vacc numeric

)

insert into #percentPopulationVaccinated
	select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,  
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vacc
	from PortProject..CovidDeaths dea
	join PortProject..CovidVaccinations vac
		on vac.location = dea.location
		and vac.date = dea.date
			where dea.continent is not null
			--and vac.new_vaccinations is not null
			--order by 2,3


	select *, (total_new_vacc/population)*100 as vacc_People_pct  from #percentPopulationVaccinated
	order by 2,3;

	

--creating view for later visualization (watch where your active database on!)

create view percentPopulationVaccinated as

	select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,  
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vacc
		from PortProject..CovidDeaths dea
		join PortProject..CovidVaccinations vac
		on vac.location = dea.location
		and vac.date = dea.date
			where dea.continent is not null;
			--and vac.new_vaccinations is not null
			--order by 2,3;

select * from percentPopulationVaccinated;



