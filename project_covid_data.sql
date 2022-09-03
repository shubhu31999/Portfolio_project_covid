select * from 
Coronavirus_project..CovidVaccinations$
order by 3,4

select * from 
Coronavirus_project..CovidDeaths$
order by 3,4

select location,date,total_cases,  new_cases, total_deaths ,population
from Coronavirus_project..CovidDeaths$
order by 1,2

--Q1 - what is the deathpercases of India ? 

select location,date,total_cases, total_deaths, total_deaths/total_cases*100 as death_per_cases 
from Coronavirus_project..CovidDeaths$
where location in ('india') 
order by 1,2

--Q2 - what is the total cases per population ?

select location, date , population , total_cases , (total_cases/population)*100 as total_case_per_population from 
Coronavirus_project..CovidDeaths$
 Where location = 'India'
order by 1,2

--Q3 - looking countries with highest infection rate compared to population

select location,population as total_population, date ,max(total_cases) highest_infecction_count, MAX(total_cases/population)*100 as highest_infection_rate
from Coronavirus_project..CovidDeaths$ 
group by location , population, date
order by highest_infection_rate desc



select count(*) from
(
select location,population as total_population, date ,max(total_cases) highest_infecction_count, MAX(total_cases/population)*100 as highest_infection_rate
from Coronavirus_project..CovidDeaths$ 
group by location , population, date) a




select*from Coronavirus_project..CovidDeaths$

--Q4 - showing countries with highest death count ;

select location, population ,MAX(cast(total_deaths as int))as highest_dead_count  
from Coronavirus_project..CovidDeaths$
where continent is not null
group by location, population
order by highest_dead_count desc 

select continent , sum(cast(total_deaths as int )) as total_death_count from Coronavirus_project..CovidDeaths$
where continent is not null
group by continent
order by sum(cast(total_deaths as int )) desc

--shows global numbers

select date , SUM( new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percent 
from Coronavirus_project..CovidDeaths$ 
where continent is not null
group by date
order by 1,2 

--total global numbers

select SUM( new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percent 
from Coronavirus_project..CovidDeaths$ 


--Bringing table CovidVaccinations$ table

select * from Coronavirus_project..CovidVaccinations$

--Q- let us join the two table[CovidDeaths$] and[CovidVaccinations$]

select  a.location, a.date, a.population, b.new_vaccinations from
Coronavirus_project..CovidDeaths$ a join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date



select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date 
order by 1,2 



select c. location ,c.population, c.new_vaccinations from
(select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c
order by 1,2 


select c. location ,c.population, c.new_vaccinations from
(select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c
order by 1,2 

--Q- query to fetch only 1000 rows 

select * from Coronavirus_project..CovidVaccinations$ 
order by location
offset 0 rows
fetch next 1000 rows only 

--Q - to fetch only 1000 rows on the subsquery 

select c. location ,c.date, c.population, c.new_vaccinations from
(select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c
where location = 'albania'
and new_vaccinations is not null
order by 1,2
offset 0 rows
fetch next 1000 rows only 

--Q - to find rolling people vaccination data for all locations

select c. location ,c.date, c.population, c.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location , date ) as rolling_people_vaccinated from
(select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c
order by 1,2

--Q - to find rolling people vaccination data in india 

select c. location ,c.date, c.population, c.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location , date ) as rolling_people_vaccinated from
(select  a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c
where location = 'india'
order by 1,2


--Q - calculating rolling data per population 


select d.continent, d.location , d.date, d.population, d.new_vaccinations, d.rolling_people_vaccinated , (d.rolling_people_vaccinated/population )*100 as vaccination_percet from 
(select c.continent ,c. location ,c.date, c.population, c.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location , date ) as rolling_people_vaccinated from
(select  a.continent ,a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c) d 
where d.continent is not null


--Q - create a temporary table for ease

drop table if exists percent_population_vaccinated
create table percent_population_vaccinated
(
continent nvarchar (50),
location nvarchar(50),
date datetime,
population numeric,
mew_vaccination int,
rolling_people_vaccinated int,
vaccination_perct numeric 
)

insert into percent_population_vaccinated
select d.continent, d.location , d.date, d.population, d.new_vaccinations, d.rolling_people_vaccinated , (d.rolling_people_vaccinated/population )*100 as vaccination_percet from 
(select c.continent ,c. location ,c.date, c.population, c.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location , date ) as rolling_people_vaccinated from
(select  a.continent ,a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c) d 
where d.continent is not null
order by 1,2

select * from percent_population_vaccinated


--Q - CREATING VIEW TO STORE DATA FOR LATER VISUALISATION 


CREATE view population_vaccinated_percent as
select d.continent, d.location , d.date, d.population, d.new_vaccinations, d.rolling_people_vaccinated , (d.rolling_people_vaccinated/population )*100 as vaccination_percet from 
(select c.continent ,c. location ,c.date, c.population, c.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location , date ) as rolling_people_vaccinated from
(select  a.continent ,a.location, a.date, a.population, b.new_vaccinations from Coronavirus_project..CovidDeaths$ a  join
Coronavirus_project..CovidVaccinations$ b
on a.location = b.location
and a.date = b.date)c) d 
where d.continent is not null

select * from population_vaccinated_percent

Create view global_numbers as
(select SUM( new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percent 
from Coronavirus_project..CovidDeaths$ )

select * from global_numbers

--Thanks for watching
--have a nice day :)
















