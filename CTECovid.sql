--USE CTE

with VacbyPop (continent, location, date, population, new_vaccinations, total_new_vacc	)
as 
(
	select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,  
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vacc
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
		where dea.continent is not null
		--and vac.new_vaccinations is not null
		--order by 2,3;
		)
select *, (total_new_vacc/population)*100 as vacc_People_pct  from VacbyPop
order by 2,3;


