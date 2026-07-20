-- Databricks notebook source
---Telling Databricks to use the 'bright_tv catalogue' and the 'data'schema
USE bright_tv.data;

--running the full tables 
SELECT*
FROM user_profiles;

SELECT*
FROM viewership;

---gender checks
SELECT DISTINCT Gender
FROM user_profiles;

-- checking for duplicates in my data 
SELECT UserID,  
COUNT(*) AS duplicate_count 
FROM bright_tv.data.user_profiles
GROUP BY UserID 
HAVING COUNT(*) > 1;

-- I am checking the size pf the data 
SELECT COUNT(*) AS number_of_rows, 
COUNT(DISTINCT UserID) AS number_subs 
FROM bright_tv.data.user_profiles 

-- Are the any rows where useRID is NULL  
SELECT COUNT(*) AS cnt 
FROM bright_tv.data.user_profiles
WHERE UserID IS NULL;

SELECT DISTINCT UserID 
FROM bright_tv.data.user_profiles;

--Gender Checks --------------------------------------------------------- 
SELECT DISTINCT gender 
FROM bright_tv.data.user_profiles;

SELECT  
    COUNT(DISTINCT userid) AS subs,  
    CASE 
        WHEN gender IS NULL OR gender = '' THEN 'None' 
        ELSE gender 
    END AS Gender 
FROM bright_tv.data.user_profiles
GROUP BY Gender;

---------------------------------------
--Race Checks 
SELECT COUNT(*) AS num_rows 
FROM bright_tv.data.user_profiles 
WHERE Race IS NULL;

SELECT DISTINCT Race 
FROM bright_tv.data.user_profiles; 

SELECT DISTINCT 
    CASE 
        WHEN Race='other' THEN 'None' 
        WHEN Race=' ' THEN 'None' 
    ELSE Race 
END AS Race 
FROM bright_tv.data.user_profiles;

--------------------------------------------------------- 
--Province Checks 
SELECT DISTINCT Province 
FROM bright_tv.data.user_profiles;

SELECT DISTINCT 
    CASE  
        WHEN Province=' ' THEN 'Uncategorized' 
        WHEN Province='None' THEN 'Uncategorized' 
    ELSE Province 
    END AS Region 
FROM bright_tv.data.user_profiles; 

---------------------------------------------------------
 --Age 
  SELECT MIN(Age) AS min_age, --- = 0 
        MAX(Age) AS max_age -- = 114 
FROM bright_tv.data.user_profiles;

-- Count users with NULL age
SELECT COUNT(*) AS cnt
FROM bright_tv.data.user_profiles
WHERE age IS NULL;
-------------------------------------------------------------------------------------------------------
-- Build user_profiles CTE
WITH user_profiles AS (
    SELECT 
        UserID,
        CASE  
            WHEN Province IS NULL OR Province = '' OR Province = 'None' THEN 'Uncategorized'
            ELSE Province 
        END AS Region,
        
        age,
        CASE 
            WHEN age = 0 THEN 'Infants' 
            WHEN age BETWEEN 1 AND 12 THEN 'Kids' 
            WHEN age BETWEEN 13 AND 19 THEN 'Teenager' 
            WHEN age BETWEEN 20 AND 35 THEN 'Youth' 
            WHEN age BETWEEN 36 AND 50 THEN 'Adult' 
            WHEN age BETWEEN 51 AND 65 THEN 'Elder' 
            WHEN age > 65 THEN 'Pensioner' 
        END AS age_groups,
        
        CASE 
            WHEN email IS NOT NULL AND email <> '' AND email <> 'None' THEN 1 
            ELSE 0 
        END AS email_flag,
        
        CASE 
            WHEN `Social Media Handle` IS NOT NULL AND `Social Media Handle` <> '' AND `Social Media Handle` <> 'None' THEN 1 
            ELSE 0 
        END AS sm_flag,
        
        CASE 
            WHEN Race IS NULL OR Race = '' OR Race = 'other' THEN 'None' 
            ELSE Race 
        END AS Race,
        
        CASE 
            WHEN gender IS NULL OR gender = '' THEN 'None' 
            ELSE gender 
        END AS Gender
    FROM bright_tv.data.user_profiles
),

-- Build viewership CTE
viewership AS (
    SELECT 
        COALESCE(UserID0, userid4) AS userid, 
        TO_CHAR(RecordDate2, 'yyyyMM') AS month_id, 
        TO_DATE(RecordDate2) AS watch_date, 
        TO_CHAR(RecordDate2, 'DD') AS day_of_week, 
        DAYNAME(RecordDate2) AS day_name,
        
        CASE 
            WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
            ELSE 'weekday' 
        END AS day_classification,
        
        MONTHNAME(RecordDate2) AS month_name,
        
        CASE  
            WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee' 
            WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supersport Live Events','DStv Events 1') THEN 'Live Events' 
            ELSE Channel2 
        END AS Tv_channel,
        
        DATE_FORMAT(RecordDate2, 'HH:mm:ss') AS watch_time,
        CASE 
            WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight' 
            WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning' 
            WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon' 
            WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening' 
        END AS time_of_day,
        
        DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
        CASE  
            WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min' 
            WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min' 
            WHEN duration > '00:59:59' THEN '03. High Usage: >60 min'
            ELSE '04. No Usage' 
        END AS screen_time_bucket,
        
        HOUR(RecordDate2) AS hour_of_day
    FROM bright_tv.data.viewership
)

-- Final join
SELECT 
    COALESCE(A.userid, B.userid) AS sub_id, 
    month_id, 
    watch_date, 
    day_of_week, 
    day_name, 
    day_classification,
    month_name, 
    Tv_channel, 
    time_of_day, 
    hour_of_day, 
    screen_time_bucket, 
    duration, 
    Region, 
    age_groups, 
    email_flag, 
    sm_flag, 
    Race, 
    Gender 
FROM viewership AS A 
LEFT JOIN user_profiles AS B 
    ON A.userid = B.userid;

    ---------------------------------------------------------------------------------------
--EXPLORING VIEWERSHIP DATA

---CHECKING THE COLUMNS IN THE TABLE
SELECT*
FROM bright_tv.data.viewership;

---ANALSING THE INFO
SELECT*
FROM bright_tv.data.viewership
WHERE UserID0 IS NULL;

to try this 

FROM viewership AS A 
LEFT JOIN user_profiles AS B 
ON A.userid=B.userid;

    SELECT COUNT(*) 
FROM brightlearn.data.tv_user_profile
WHERE gender=' ';

---Dataset coverage, to see number of users , number of channels , total records and time frame
SELECT 
    MIN(RecordDate2) AS start_period,
    MAX(RecordDate2) AS end_period,
    COUNT(DISTINCT UserID0) AS total_users,
    COUNT(DISTINCT Channel2) AS total_channels,
    COUNT(*) AS total_records
FROM bright_tv.data.viewership;

--groupby  month to see the coverage trends over time
SELECT 
    DATE_FORMAT(RecordDate2, 'yyyy-MM') AS month_id,
    COUNT(DISTINCT UserID0) AS users,
    COUNT(DISTINCT Channel2) AS channels,
    COUNT(*) AS records
FROM bright_tv.data.viewership
GROUP BY DATE_FORMAT(RecordDate2, 'yyyy-MM')
ORDER BY month_id;

---to show quater and year coverage
SELECT 
    YEAR(RecordDate2) AS year_id,
    QUARTER(RecordDate2) AS quarter_id,
    COUNT(DISTINCT UserID0) AS users,
    COUNT(DISTINCT Channel2) AS channels,
    COUNT(*) AS records
FROM bright_tv.data.viewership
GROUP BY YEAR(RecordDate2), QUARTER(RecordDate2)
ORDER BY year_id, quarter_id;




