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


