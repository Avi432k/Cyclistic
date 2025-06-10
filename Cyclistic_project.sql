SELECT * 
FROM divvy_trips_2019_q1;

SELECT *
FROM divvy_trips_2020_q1


-- CREATE COPIES OF DATASETS

CREATE TABLE trips_2019_copy
LIKE divvy_trips_2019_q1;

INSERT trips_2019_copy
SELECT * 
FROM divvy_trips_2019_q1;

CREATE TABLE trips_2020_copy
LIKE divvy_trips_2020_q1;

INSERT trips_2020_copy
SELECT * 
FROM divvy_trips_2020_q1;

SELECT *
FROM trips_2019_copy;

SELECT *
FROM trips_2020_copy;

-- STANDARDISE COLUMN NAMES

-- Change 2020 column name from 'ride_id' to 'trip_id'
ALTER TABLE trips_2020_copy
CHANGE COLUMN ride_id trip_id TEXT;

-- Change 2019 trip_id column from int to text
ALTER TABLE trips_2019_copy
MODIFY COLUMN trip_id VARCHAR(255);

-- Change 2020 column name from 'member_casual' to 'usertype'
ALTER TABLE trips_2020_copy
CHANGE COLUMN member_casual usertype TEXT;

-- Change 2019 usertype values to 'member' and 'casual' 
UPDATE trips_2019_copy
SET usertype = CASE
WHEN usertype = 'Subscriber' THEN 'member'
WHEN usertype = 'Customer' THEN 'casual'
END;


-- Remove rideable_type column
SELECT DISTINCT rideable_type
FROM trips_2020_copy;

ALTER TABLE trips_2020_copy
DROP COLUMN rideable_type;

-- Change 2020 column name from 'started_at' to 'start_time', and from 'ended_at' to 'end_time'
ALTER TABLE trips_2020_copy
CHANGE COLUMN started_at start_time TEXT;

ALTER TABLE trips_2020_copy
CHANGE COLUMN ended_at end_time TEXT;

-- Split datetime columns into separate date and time columns for both 2019 and 2020 
SELECT
SUBSTRING_INDEX(start_time, ' ', 1) AS `date`,
SUBSTRING_INDEX(start_time, ' ', -1) AS `starting_time`,
SUBSTRING_INDEX(end_time, ' ', -1) AS `ending_time`
FROM trips_2019_copy;

SELECT
SUBSTRING_INDEX(start_time, ' ', 1) AS `date`,
SUBSTRING_INDEX(start_time, ' ', -1) AS `starting_time`,
SUBSTRING_INDEX(end_time, ' ', -1) AS `ending_time`
FROM trips_2020_copy;

ALTER TABLE trips_2019_copy
ADD COLUMN `date` DATE,
ADD COLUMN `starting_time` TIME,
ADD COLUMN `ending_time` TIME;

UPDATE trips_2019_copy
SET 
  `date` = SUBSTRING_INDEX(start_time, ' ', 1),
  `starting_time` = SUBSTRING_INDEX(start_time, ' ', -1),
  `ending_time` = SUBSTRING_INDEX(end_time, ' ', -1);

ALTER TABLE trips_2020_copy
ADD COLUMN `date` DATE,
ADD COLUMN `starting_time` TIME,
ADD COLUMN `ending_time` TIME;

UPDATE trips_2020_copy
SET 
  `date` = SUBSTRING_INDEX(start_time, ' ', 1),
  `starting_time` = SUBSTRING_INDEX(start_time, ' ', -1),
  `ending_time` = SUBSTRING_INDEX(end_time, ' ', -1);
  
-- Create day_of_week column

SELECT 
`date`,
DAYNAME(`date`) AS day_of_week
FROM trips_2019_copy;

SELECT 
`date`,
DAYNAME(`date`) AS day_of_week
FROM trips_2020_copy;

ALTER TABLE trips_2019_copy
ADD COLUMN day_of_week VARCHAR(255);

UPDATE trips_2019_copy
SET day_of_week = DAYNAME(`date`);

ALTER TABLE trips_2020_copy
ADD COLUMN day_of_week VARCHAR(255);

UPDATE trips_2020_copy
SET day_of_week = DAYNAME(`date`);

-- Create trip duration column 

SELECT 
starting_time,
ending_time,
CASE
    WHEN ending_time >= starting_time THEN
      TIME_TO_SEC(TIMEDIFF(ending_time, starting_time))
    ELSE
      TIME_TO_SEC(ending_time) + 86400 - TIME_TO_SEC(starting_time)
  END trip_duration
  FROM trips_2019_copy;

ALTER TABLE trips_2019_copy
ADD COLUMN trip_duration INT;

UPDATE trips_2019_copy
SET trip_duration = 
  CASE
    WHEN ending_time >= starting_time THEN
      TIME_TO_SEC(TIMEDIFF(ending_time, starting_time))
    ELSE
      TIME_TO_SEC(ending_time) + 86400 - TIME_TO_SEC(starting_time)
  END;
  
ALTER TABLE trips_2020_copy
ADD COLUMN trip_duration INT;

UPDATE trips_2020_copy
SET trip_duration = 
  CASE
    WHEN ending_time >= starting_time THEN
      TIME_TO_SEC(TIMEDIFF(ending_time, starting_time))
    ELSE
      TIME_TO_SEC(ending_time) + 86400 - TIME_TO_SEC(starting_time)
  END;

-- Create a starting hour column

SELECT 
starting_time,
HOUR(starting_time)
FROM trips_2019_copy;

ALTER TABLE trips_2019_copy
ADD COLUMN starting_hour INT;

UPDATE trips_2019_copy
SET starting_hour = HOUR(starting_time);

ALTER TABLE trips_2020_copy
ADD COLUMN starting_hour INT;

UPDATE trips_2020_copy
SET starting_hour = HOUR(starting_time);

SELECT starting_time, starting_hour
FROM trips_2020_copy;

-- Drop redundant columns

ALTER TABLE trips_2019_copy
DROP COLUMN start_time,
DROP COLUMN end_time,
DROP COLUMN bikeid,
DROP COLUMN tripduration,
DROP COLUMN from_station_id,
DROP COLUMN from_station_name,
DROP COLUMN to_station_id,
DROP COLUMN to_station_name,
DROP COLUMN gender,
DROP COLUMN birthyear;

ALTER TABLE trips_2020_copy
DROP COLUMN start_time,
DROP COLUMN end_time,
DROP COLUMN start_station_name,
DROP COLUMN start_station_id,
DROP COLUMN end_station_name,
DROP COLUMN end_station_id,
DROP COLUMN start_lat,
DROP COLUMN start_lng,
DROP COLUMN end_lat,
DROP COLUMN end_lng;

SELECT *
FROM trips_2019_copy;

SELECT *
FROM trips_2020_copy;

-- Merge 2019 and 2020 datasets

SELECT * FROM trips_2019_copy
UNION 
SELECT * FROM trips_2020_copy;

CREATE TABLE trips_2019_2020 LIKE trips_2019_copy;

INSERT INTO trips_2019_2020
SELECT * FROM trips_2019_copy
UNION 
SELECT * FROM trips_2020_copy;

SELECT *
FROM trips_2019_2020;



-- DATA VALIDATION

-- Validating the trip duration column

SELECT MAX(trip_duration), AVG(trip_duration)
FROM trips_2019_2020;

SELECT *
FROM divvy_trips_2019_q1
WHERE start_time > end_time;

SELECT *
FROM divvy_trips_2020_q1
WHERE started_at > ended_at;

-- Delete values from trips_2019_2020 where start time greater than end time

SELECT trip_id
FROM trips_2019_2020
WHERE trip_id IN
	(SELECT ride_id
	FROM divvy_trips_2020_q1
	WHERE started_at > ended_at);

DELETE FROM trips_2019_2020
WHERE trip_id IN
	(SELECT ride_id
	FROM divvy_trips_2020_q1
	WHERE started_at > ended_at);

SELECT *
FROM trips_2019_2020
WHERE trip_duration = 86274;

SELECT *
FROM divvy_trips_2019_q1
WHERE trip_id = 86274;

SELECT *
FROM divvy_trips_2019_q1
WHERE trip_id = 21979809;

-- EXPORT trips_2019_2020 into csv file

SELECT *
FROM trips_2019_2020;

-- DATA EXPLORATION

SELECT usertype, trip_duration
FROM trips_2019_2020
ORDER BY trip_duration;

