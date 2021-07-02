-- Check for the number of clients in each table
SELECT
	Count (Distinct Id)
FROM dbo.dailyActivity_merged -- Performed this query for the 6 tables
-- Turns out that we have 33 clients, as opposed to the 30 as was mentioned in the task (except for file regarding the weight info, where we only have 24 clients)

-- Check the timeframe of the study
SELECT
	MIN (ActivityDate) as MIN,
	MAX(ActivityDate) as MAX
FROM 
	dbo.dailyActivity_merged -- Performed it on all six tables
-- The period of this study is from 12/04/2016-12/05/2016

-- Exploring some of the values of the attributes
SELECT
	min(SedentaryActiveDistance) as MIN,	
	max(SedentaryActiveDistance) as MAX
FROM 
	dbo.dailyActivity_merged
-- The sedentary time ranges between 0 and 0.10 minutes, which is close to 0 hence we can ignore that minor error as it won't have any significant impact on the results

SELECT
	*
FROM 
	dbo.dailyActivity_merged
WHERE
	TotalDIstance <> TrackerDistance
--We get only 15 out of the total 940 obseravtions, for three clients out of the 33 clients in the study. This implies that the fitbit trackes is accurate in tracking the distance covered by the user.

SELECT
	Id,
	TotalDistance,
	TrackerDistance,
	(TotalDistance) - (TrackerDistance) AS Difference
FROM
	dbo.dailyActivity_merged
WHERE
	TotalDistance <> TrackerDistance
ORDER BY
	Difference
-- Checking for the difference between the distance tracked and the total ditance covered for the 15 observations, the value ranges between 0.04 - 1.83 minutes. Not much of a sginificane, however to try and be as accurate as possible, we select the distance tracked when analyzing the data. 

-- Checking for null values in the data:
SELECT
	*
FROM
	dbo.dailyActivity_merged
WHERE 
	Id is null
	OR ActivityDate is null
	OR TotalSteps is null
	OR TotalDistance is null
-- No null values present in our data

-- Data looks clean, now we move to Analyze the data

-- Getting a sense of how active the users in our study are
SELECT 
	Id,
	ActivityDate,
	LightlyactiveMinutes+FairlyActiveMinutes+VeryActiveMinutes as TotalActiveMinutes,
	SedentaryMinutes,
	LightlyactiveMinutes+FairlyActiveMinutes+VeryActiveMinutes+SedentaryMinutes as TotalDailyMinutes,
	Calories
FROM
	dbo.dailyActivity_merged
Order By
	TotalDailyMinutes
-- The TotalDailyMinutes show that the values range between 2 and 1440, which shows that some clients do wear their fitbit tracker for the whole day while others only wear it for 2minutes. Looking at the calories attribute, we can see that calories are not matching with the TotalActiveMinutes. 
--However with a chart we can better visualize whethere a correlation between Activity and Calories exists.
SELECT 
	Id,
	ActivityDate,
	LightlyactiveMinutes+FairlyActiveMinutes+VeryActiveMinutes as TotalActiveMinutes,
	SedentaryMinutes,
	LightlyactiveMinutes+FairlyActiveMinutes+VeryActiveMinutes+SedentaryMinutes as TotalDailyMinutes,
	Calories
FROM
	dbo.dailyActivity_merged
ORDER BY 
	TotalActiveMinutes
--The highest active minutes per day was 552minutes, which is 38.3% of the whole day.
--The maximum sedentary minutes per day is 1440 minutes.

-- Exploring Sleeping Patterns
SELECT 
	*
FROM
	dbo.sleepDay_merged
ORDER BY 
	TotalMinutesAsleep
--The data show a strong correlation between total minutes asleep and total time in bed as the longest minutes of sleep belong to the longest time in bed (796m and 961m) respectively.

--Exploring the weight data
SELECT 
	COUNT(DISTINCT Id)
FROM
	dbo.weightLogInfo_merged
--Out of the 67 observations, we only have 8 different clients.
--Hence the data is very few and we should drop it.

--Merging the Activity and Sleep together to see if there is any relationship between sleep, calories and active minutes
SELECT 
	Id,
	sum(VeryActiveMinutes) as Total_Monthly_Very_Active_Minutes,
	sum(FairlyActiveMinutes) as Total_Monthly_Fairly_Active_Minutes,
	sum(LightlyActiveMinutes) as Total_Monthly_Lightly_Active_Minutes,
	sum(SedentaryMinutes) as Total_Monthly_Sedentary_Minutes,
	sum(Calories) as Total_Monthly_Calories
INTO 
	Monthly_Activity 
FROM 
	dbo.dailyActivity_merged
GROUP BY 
	Id
-- Created a Temporary table called Monthly_Activity with the above values

SELECT 
	Id,
	SUM(TotalMinutesAsleep) AS Total_Monthly_Minutes_Asleep,
	SUM(TotalTimeInBed) AS Total_Monthly_Time_In_Bed
INTO
	Monthly_Sleep
FROM 
	dbo.sleepDay_merged
GROUP BY 
	Id
-- Created a temporary table called Monthly_Sleep with the above values

-- Merging both temporary tables into a new table
SELECT
	Monthly_Activity.Id,
	Total_Monthly_Very_Active_Minutes,
	Total_Monthly_Fairly_Active_Minutes,
	Total_Monthly_Lightly_Active_Minutes,
	Total_Monthly_Sedentary_Minutes,
	Total_Monthly_Very_Active_Minutes + Total_Monthly_Fairly_Active_Minutes + Total_Monthly_Lightly_Active_Minutes AS Total_Monthly_Active_Minutes,
	Total_Monthly_Minutes_Asleep,
	Total_Monthly_Time_In_Bed,
	Total_Monthly_Calories
INTO 
	Monthly_Sleep_Activity
FROM
	Monthly_Activity
INNER JOIN Monthly_Sleep
ON Monthly_Activity.Id = Monthly_Sleep.Id
--Created a new table called Monthly_Sleep_Activity with the above values

SELECT
	*
FROM
	Monthly_Sleep_Activity
ORDER BY
	Total_Monthly_Sedentary_Minutes
-- Looking at the data, there is no indication that a strong correlation exists between sedentary minutes and total minutes asleep.
	














