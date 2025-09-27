## Energy Consuption Analysis

-- creating a database called energy for forther analysis
-- using the energ database

create database if not exists energy;

use energy;
-- 1. country table
CREATE TABLE country (
    country VARCHAR(100) primary key,
    cid VARCHAR(10) unique
);

select * from country;

-- 2. emission_3 table
CREATE TABLE emission (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
    on delete cascade on update cascade
);
 
select * from emission;

-- 3. population table
CREATE TABLE population (
    country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
    on delete cascade on update cascade
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
    on delete cascade on update cascade
);

select * from production;

-- 5. gdp table
CREATE TABLE gdp (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
    on delete cascade on update cascade
);

select * from gdp;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
    on delete cascade on update cascade
);

select * from consumption;


## General & Comparative Analysis
-- 1] What is the total emission per country for the most recent year available?

select country, year, sum(emission) as total_emission
from emission
where year = (select MAX(year) from emission)
group by country, year
order by total_emission desc;

-- 2] What are the top 5 countries by GDP in the most recent year?
select country,year,value as GDP_VALUE
from gdp
where year=(select max(year) from gdp)
order by GDP_VALUE desc limit 5;

-- Q3] Compare energy production and consumption by country and year. 
select c.country,p.year,p.energy,p.production ,cons.consumption
from country c
join production p
on c.country = p.country
join consumption cons
on p.country = cons.country
and p.year = cons.year
and p.energy =  cons.energy
order by p.production desc;

-- Q4] Which energy types contribute most to emissions across all countries?
select c.country,e.energy_type, sum(e.emission) as Emition_contribute
from country c
join emission as e
on c.country = e.country
group by c.country,e.energy_type
order by Emition_contribute desc;

-- Trend Analysis Over Time
-- 5] How have global emissions changed year over year?

select year, sum(emission) as global_emissions
from emission 
group by year
order by year asc;

-- 6]  What is the trend in GDP for each country over the given years?
select * from gdp;
select country,year,sum(value) as change_in_gdp
from gdp
group by country,year
order by country,year;

-- 7] How has population growth affected total emissions in each country?
select p.country,p.year,
sum(e.emission) as _emission,
p.value as population_value
from population p
join emission e
on p.country=e.country
group by p.country,p.year,p.value
order by _emission desc;

-- 8] Has energy consumption increased or decreased over the years for major economies?

select major_economies.country,c.year,sum(c.consumption) as total_consumption
from consumption c
join (select country ,sum(value) as total_gdp
from gdp
group by country
order by total_gdp desc limit 5) as major_economies
on c.country=major_economies.country
group by c.year, major_economies.country
order by c.year desc, major_economies.country;


-- 9] What is the average yearly change in emissions per capita for each country?

select e.country,e.year,
(sum(e.emission) / sum(p.value)) as emission_per_capital
from emission e
join population p
on e.country=p.country
and e.year=p.year
group by e.country,e.year
order by e.country,e.year;


-- Ratio & Per Capita Analysis
-- 10] What is the emission-to-GDP ratio for each country by year?
select e.country,e.year,
round(sum(e.emission) / sum(g.value),4) as emission_to_gdp_ratio
from emission e
join gdp g
on e.country=g.country
and e.year=g.year
group by e.country,e.year
order by e.country,e.year;

-- 11] What is the energy consumption per capita for each country over the last decade?
select * from consumption;
select c.country,c.year,
sum(consumption) / sum(p.value) as consumption_per_capital
from consumption c
join population p
on c.country=p.country
and c.year=p.year
where c.year>= year(curdate())-10
group by c.country,c.year
order by c.country,c.year;


-- 12]  How does energy production per capita vary across countries?

select pr.country,pr.year,
sum(pr.production) / sum(po.value) as production_per_capital
from production pr
join population po
on pr.country=po.country
and pr.year=po.year
group by pr.country,pr.year
order by production_per_capital desc;

-- 13] Which countries have the highest energy consumption relative to GDP?

select c.country,c.year,
sum(c.consumption) / sum(g.value) as production_per_capital
from consumption c
join gdp g
on c.country=g.country
and c.year=g.year
group by c.country,c.year
order by production_per_capital desc;





 -- Global Comparisons
-- 14]  What are the top 10 countries by population and how do their emissions compare?
select p.country,
sum(p.value) as total_population,
sum(e.emission) as total_emission
from population p
join emission e
on p.country=e.country
and p.year=e.year
group by p.country
order by total_population desc limit 10;

-- 15] Which countries have improved (reduced) their per capita emissions the most over the last decade?

SELECT 
    e.country, e.year,
    (e.emission / p.value) AS per_capita_emissions
FROM emission e
join population p
on e.country=p.country
WHERE e.year>= year(curdate())-10
ORDER BY e.country, e.year ,per_capita_emissions desc;

-- 16] What is the global share (%) of emissions by country?
select country,year,emission,
(emission / (select sum(emission) from emission where year = year)) * 100 as emission_share_percentage
from emission
order by year, emission_share_percentage desc;

-- 17] What is the global average GDP, emission, and population by year?
select g.year,
avg(g.value) as global_avg_gdp,
avg(e.emission) as global_avg_emission,
avg(p.value) as global_avg_population
from gdp g
join emission e
on g.country=e.country
and g.year=e.year
join population p
on p.country=g.country
and p.year=g.year
group by year
order by year;
