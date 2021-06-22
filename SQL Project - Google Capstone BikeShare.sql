-- Check for Duplicates in the ID names
SELECT
	count(distinct ride_id)
FROM
	[202004-divvy-tripdata] -- Ran this query 13 times for each month, by changing the table name

--Check the difference between 
--the number of casual riders and members on a monhtly basis
SELECT
	count(member_casual) as total,
	member_casual
FROM
	[202004-divvy-tripdata] -- Ran this query 13 times for each month 
GROUP BY
	member_casual

-- Checking the days during which the number of riders was the greatest
-- #1 represents Monday all the way up to #7 which rerpresents Sunday
SELECT 
	count(ride_id) as Number_Riders,
	Day_Of_The_Week
FROM
	[202004-divvy-tripdata] -- Ran this query 13 times for each month
GROUP BY 
	Day_Of_The_Week
ORDER BY 
	Number_Riders DESC

-- Fragmenting the data further by looking at the number of casual riders vs members per day
SELECT 
	count(ride_id) as Number_Riders,
	Day_Of_The_Week,
	member_casual
FROM
	[202004-divvy-tripdata] -- Ran this query 13 times for each month
GROUP BY 
	Day_Of_The_Week,
	member_casual
ORDER BY 
	Number_Riders DESC,
	member_casual DESC

-- Checked for the most popular types of rides used by each, the casual riders and members separately

SELECT
count(member_casual) As Total_Number,
member_casual,
rideable_type
FROM 
[202004-divvy-tripdata] -- Ran this query 13 times for each month
GROUP BY
rideable_type,
member_casual
ORDER BY
Total_Number DESC

