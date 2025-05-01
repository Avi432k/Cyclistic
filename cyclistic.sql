SELECT AVG(ride_length1), MAX(ride_length1), MIN(ride_length1), AVG(trip_duration), MAX(trip_duration), MIN(trip_duration)
FROM `cyclistic_data_2019_2020`;

-- CALCULATING THE MEAN, MAX AND MIN TRIP DURATION FOR MEMBERS VS CASUALS

SELECT usertype, AVG(ride_length1), MAX(ride_length1), MIN(ride_length1), AVG(trip_duration), MAX(trip_duration), MIN(trip_duration)
FROM `cyclistic_data_2019_2020`
GROUP BY usertype;

SELECT usertype, AVG(ride_length1), MAX(ride_length1), MIN(ride_length1), AVG(trip_duration), MAX(trip_duration), MIN(trip_duration)
FROM `cyclistic_data_2019_2020`
WHERE trip_duration < 9000
GROUP BY usertype;

SELECT usertype, COUNT(trip_duration)
FROM `cyclistic_data_2019_2020`
WHERE trip_duration > 12000
GROUP BY usertype;

-- INVESTIGATING THE DAY OF THE WEEK IN WHCIH THE BIKES ARE RIDDEN BETWEEN MEMBERS AND CASUALS 

SELECT usertype, `weekday`, COUNT(trip_duration)
FROM `cyclistic_data_2019_2020`
GROUP BY `weekday`, usertype;

SELECT usertype, `weekday`, COUNT(`weekday`)
FROM `cyclistic_data_2019_2020`
GROUP BY usertype, `weekday`
ORDER BY COUNT(`weekday`) DESC;

SELECT DISTINCT `date`
FROM cyclistic_data_2019_2020;
