--Exploring the data in Covid_Deaths file
Select *
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
Order By
3, 4

--Exploring the data in Covid_Vaccines file
Select *
FROM
Portoflio_Project_Alex_COVID..Covid_Vaccines
Order By
3, 4

--Cleaning the Data
SELECT 
continent, location, MAX (cast(total_deaths as int)) as Highest_Deaths_Count --Total_deaths has to be converted to integer for the queries to recognize the values
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
GROUP BY
continent, location
ORDER BY
Highest_Deaths_Count DESC
--From this query, we realize that continents are present in the location and we should remove them

--Removing the continents from the location
SELECT 
location, MAX (cast(total_deaths as int)) as Highest_Deaths_Count --Total_deaths has to be converted to integer for the queries to recognize the values
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null
GROUP BY
location
ORDER BY
Highest_Deaths_Count DESC

												-- An Overview of the Pandemic Globally
--Looking at the highest deaths per continent
SELECT 
continent, MAX (cast(total_deaths as int)) as Highest_Deaths_Count --Total_deaths has to be converted to integer for the queries to recognize the values
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null
GROUP BY
continent
ORDER BY
Highest_Deaths_Count DESC
-- We can see that America has the highest deaths rate followed by Asia

-- The Deaths Rate per continent
SELECT 
continent, MAX (cast(total_deaths as int)) as Highest_Deaths_Count, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Deaths_Rate
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null
GROUP BY
continent
ORDER BY
Deaths_Rate DESC
--The highest death rate is in line is partially in line with the highest death count.
--The most notable difference is in Africa. The highest deaths count for Africa is the second lowest, whereas it is the one with the highest death rate. 
--Which implies that even though in numbers, the deaths are not s significant as the rest of the continents, however, among the new cases, it has the highest deaths.


-- Overall Death Rate Globally 
SELECT 
SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Overall_Deaths_Percentage
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE continent is not null
ORDER BY
1, 2
--Total Percentage of Deaths over the whole period is 2.15%


--Daily Numbers Globally
SELECT 
date, SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Overall_Deaths_Percentage
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE continent is not null
GROUP BY
date
ORDER BY
1, 2
-- We can see there is an increase in the percentage of deaths as the days go by
--until April, May 2020, when the numbers started decreasing again (I believe this is when the lockdowns started globally) 	

																--Countries' Data
--Looking at the countries with the Highest Infection Rate
SELECT
location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Infection_Rate
FROM 
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null
GROUP BY
location, population
ORDER BY
Infection_Rate DESC
-- We can see the highest infection rate reached is c19%, which is really high. And thic occured in Andorra in Europe

--Looking at the countries with the Highest Deaths
SELECT
location, population, MAX(cast(total_deaths as int)) as Highest_Deaths_Count
FROM 
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null
GROUP BY
location, population
ORDER BY
Highest_Deaths_Count DESC
-- We can see the highest deaths count was in USA with a total deaths of 610,177.

--Looking at the countries with the Highest Death Rate per Population
SELECT
location, MAX(cast(total_deaths as int)) as Total_Death_Count, MAX(total_deaths/population)*100 as Deaths_Rate
FROM Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE continent is not null
GROUP BY
location, population
ORDER BY
Deaths_Rate DESC
-- We can see that the highest Deaths per population due to COVID is 0.59%

	
																--Looking at Lebanon's Data

--Looking at Total Cases vs Total Deaths 
-- and findind the likelyhood (probabilty) of dying if someone has COVID 
SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_Percentage
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE 
continent is not null 
AND location like '%leb%'
ORDER BY
5 DESC
-- Here we can see that th bhighest percentage of deaths in Lebanon is around 5% and this happened at the start of the pandemic and the rates started decreasing reaching their lowest levels in january 2021 of 0.7%.
--However, it was not contained as the deaths rates started increasing again to the normal levels ranging between 1%-2%

--Looking at Total Cases vs Populartion 
-- and findind the likelyhood (probabilty) of catching COVID in a given country
SELECT 
location, date, population, total_cases,  (total_cases/population)*100 AS Infected_Percentage
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE continent is not null
AND location like '%leb%'
ORDER BY
5 DESC
--Here we can see an obvious trend, where infection rates started increasing with time.
--When combined these two, we can deduce that even though the infections have been increasing, the deaths rates were decreasing, which is a sign of being able to handle the pandemic better.
-- Now, whether this is due to a better awareness by the people, or due to the rules and regulations implemented by the government, or due to a proper healthcare system, requires further investigation that the available data cannot answer.

--Looking at the percentage of deaths over the whole population
SELECT 
location, date, population, total_deaths,  (total_deaths/population)*100 AS Total_Deaths_Percentage
FROM
Portoflio_Project_Alex_COVID..Covid_Deaths
WHERE continent is not null
AND location like '%leb%'
ORDER BY
5 DESC
-- The highest death recorded was 0.11% of the whole population, which isn't that bad, given that the percentage of infections reached c8% of the whole population at its peak.

--Looking at the % of fully vaccinated people among the people that have been vaccinated 
Select 
location, date, people_vaccinated, people_fully_vaccinated, cast(people_fully_vaccinated as float)/cast(people_vaccinated as float)*100 as Fully_Vaccinated_over_Total_Vaccinated
FROM
Portoflio_Project_Alex_COVID..Covid_Vaccines
WHERE location = 'Lebanon'
Order By
date
--Here we can see a clear trend that with time, the people of fully vaccinated has been increasing compared to the people who have been vaccinated only once
--The rate of fully vaccinated people to total vaccinated people reached 65%.

--Joining both tables together to get all the info required including vaccinations info
SELECT
*
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date

--Looking at the deaths in relation to the vaccines
SELECT
deaths.continent, deaths.location, deaths.date, deaths.population,deaths.new_cases, vaccines.new_vaccinations 
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null
AND vaccines.new_vaccinations is not null
AND deaths.location = 'Lebanon'
ORDER by 
cast(new_cases as int) DESC
--From the below data, we can see some kind of a trend that as new vaccines increase new cases decrease (there seems to be some sort of a negative correlation, but not too strong)

--Looking at the total vaccinated people as a % of the population
SELECT
deaths.location, deaths.date, deaths.population, vaccines.people_vaccinated, cast (vaccines.people_vaccinated as float)/ cast(deaths.population as float)*100 as total_vaccinated_people
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null
AND vaccines.new_vaccinations is not null
AND deaths.location = 'Lebanon'
ORDER by 
date
-- Here also, we can see a trend where total people vaccinated with at least one doze has reach 15% of the whole population, 
--which is a very small percentage of the whole population.

--Looking at the fully vaccinated as a % of the population
SELECT
deaths.location, deaths.date, deaths.population, vaccines.people_fully_vaccinated, cast (vaccines.people_fully_vaccinated as float)/ cast(deaths.population as float)*100 as fully_vaccinated_people
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null
AND vaccines.new_vaccinations is not null
AND deaths.location = 'Lebanon'
ORDER by 
date
-- Here also, we can see a trend where fully people vaccinated with has reached 10% of the whole population, 
--which is only 5% less than people who have been vaccinated with at least 1 doze.


-- Adding the vaccines of each country together
SELECT
deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
SUM (convert(int, vaccines.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.date) as Vaccinations_Rollout -- or SUM(cast(vaccinces.vaccinations as int) ...
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null
ORDER by 2, 3

-- Looking at the total vaccination available per the total population of a country (in a daily cumulative form to get a better idea of the daily change in rate)

--SELECT
--deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
--SUM (cast(vaccines.new_vaccinations as int)) OVER (Partition by deaths.location ORDER BY deaths.date) as Vaccinations_Rollout,
--(Vaccinations_Rollout/population)*100 -- We need to use a CTE or Temp table in order to be able to use the new "Vaccinations_Rollout" column created
--FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
--JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
--	On deaths.location = vaccines.location 
--	AND deaths.date = vaccines.date
--WHERE deaths.continent is not null
--ORDER by 2, 3

-- USE CTE
With Pop_vs_Vac (continent, location, date, population, new_vaccinations, Vaccinations_Rollout)
as
(
SELECT
deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
SUM (cast(vaccines.new_vaccinations as int)) OVER (Partition by deaths.location ORDER BY deaths.date) as Vaccinations_Rollout
--,(Vaccinations_Rollout/population)*100
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null
)
SELECT
*, (Vaccinations_Rollout/population)*100 as Rate_of_Population_Vaccinated
FROM 
Pop_vs_Vac
WHERE location = 'Lebanon'
-- We can see that for Lebanon theree are only 1,564,303 vaccines available in total. If by 7/22/2021 we have used all of our vaccines to vaccinate people, only 22% would be vaccianted with only 1 shot (not fully vaccinated)
-- Which in turn means that only 11% of the population could be fully vaccinated.

-- Creating Views to store in the database for Visualization Later

Create View Percent_of_Population_Vaccinated as
SELECT
deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
SUM (cast(vaccines.new_vaccinations as int)) OVER (Partition by deaths.location ORDER BY deaths.date) as Vaccinations_Rollout
FROM Portoflio_Project_Alex_COVID..Covid_Deaths as deaths
JOIN Portoflio_Project_Alex_COVID..Covid_Vaccines as vaccines
	On deaths.location = vaccines.location 
	AND deaths.date = vaccines.date
WHERE deaths.continent is not null



