--Create a table that contains the columns you want to have. I named mine "Main". 
--This is where you'll combine all your data into one table for exploration and cleaning.

USE [Cyclistic Bikeshare]
GO

/****** Object:  Table [dbo].[April2020]    Script Date: 11/11/2022 10:58:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Main](
	[ride_id] [varchar](50) NULL,
	[rideable_type] [varchar](50) NULL,
	[started_at] [varchar](50) NULL,
	[ended_at] [varchar](50) NULL,
	[start_station_name] [varchar](50) NULL,
	[start_station_id] [varchar](50) NULL,
	[end_station_name] [varchar](50) NULL,
	[end_station_id] [varchar](50) NULL,
	[start_lat] [varchar](50) NULL,
	[start_lng] [varchar](50) NULL,
	[end_lat] [varchar](50) NULL,
	[end_lng] [varchar](50) NULL,
	[member_casual] [varchar](50) NULL
) ON [PRIMARY]
GO;

--Combine all tables into one table using INSERT INTO.

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM April2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM May2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM June2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM July2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Aug2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Sep2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Oct2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Nov2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Dec2020;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Jan2021;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM Feb2021;

INSERT INTO [Cyclistic Bikeshare].[dbo].[Main]
SELECT *
FROM March2021;


--Now we clean the data and add the columns we need.
-- Note that the query below cleans the data and puts it into a Biskeshare_CleanData table
-- using the SELECT ... INTO Bikeshare_CleanData WHERE ...

SELECT ride_id, rideable_type, start_station_name, end_station_name,

--Extract date from datetime 
CAST(started_at AS DATE) AS start_date,
CAST(ended_at AS DATE) AS end_date,


--Extract MonthYear name from date
DATENAME(m,started_at)+cast(datepart(yyyy,started_at) as varchar) as MonthYear,

--Extract day name from date
DATENAME(WEEKDAY, started_at) AS day,

--Extract time from timestamp
CONVERT(VARCHAR(10), CAST(started_at AS TIME), 0) AS start_time,
CONVERT(VARCHAR(10), CAST(ended_at AS TIME), 0) AS end_time,

-- Extract starting hour from timestamp
DATENAME(hh, start_time) AS start_hour,

--Calculate ride duration by subtracting start time from end time
DATEDIFF(minute, started_at, ended_at) AS ride_duration_minutes,


--Calculate the ride distance in metres between latitudes and longitudes
geography::Point(start_lat, start_lng, 4326).STDistance(geography::Point(end_lat, end_lng, 4326)) AS ride_dis_metres,

member_casual

INTO Bikeshare_CleanData
FROM Main
WHERE start_station_id IS NOT NULL 
OR end_station_id IS NOT NULL

-- Delete rows where ride duration is 0 or less.
DELETE 
FROM  Bikeshare_CleanData
WHERE ride_duration_minutes <= 0

-- THE ANALYSIS 
-- Create views that you will save to Excel and later visualize with Tableau
-- 1. Get the average ride duration grouped by member_casual and monthyear
-- This will help determine ride duration by months

CREATE VIEW [average_ride_duration_monthyear2] AS
SELECT
    MonthYear, member_casual,
    AVG(ride_duration_minutes) AS avg_ride_duration
FROM
   Bikeshare_CleanData
GROUP BY
member_casual, MonthYear;

-- 2. Get the total rides per day grouped by member_casual

CREATE VIEW [TotalRides_by_day] AS
SELECT
    day, member_casual,
    COUNT(ride_id) AS Total_rides
FROM
   Bikeshare_CleanData
GROUP BY
member_casual, day;

-- 3. Get bike preference throughout the year.

CREATE VIEW [Bike_Preference_by_months] AS
SELECT
    month, rideable_type,
	COUNT(ride_id) AS Total_Rides
FROM
   Bikeshare_CleanData
GROUP BY
month, rideable_type

-- 4. Get average ride distance between casual riders and members

CREATE VIEW [Avg_distance] AS
SELECT  member_casual, 
AVG(ride_dis_metres) AS Avg_distance
FROM Bikeshare_CleanData
GROUP BY member_casual


-- 5. Get the total rides per month grouped by member_casual

CREATE VIEW [TotalRides_by_month] AS
SELECT
    month, member_casual,
    COUNT(ride_id) AS Total_rides
FROM
   Bikeshare_CleanData
GROUP BY
member_casual, month
