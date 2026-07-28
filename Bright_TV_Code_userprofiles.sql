-- Databricks notebook source

---This code is to check what my data looks like
Select*
From june_intake.bright_tv_casestudy.userprofiles
LIMIT 5;

---------------------------------------------------------
--Checking for Duplicates
---------------------------------------------------------
Select Count(*),
        userid
From june_intake.bright_tv_casestudy.userprofiles
Group by userid
Having count(*)>1;

----------------------------------------------------------
---Gender checks
----------------------------------------------------------
Select distinct Gender ---to check what is contained in this categorical column
From june_intake.bright_tv_casestudy.userprofiles;
--cleaning the gender
Select distinct
    CASE
        WHEN Gender = 'None' THEN 'Unknown' ---Replaces the value None with unknown
        WHEN Gender = ' ' THEN 'Unknown' ---Replaces the empty space with unknown
        WHEN Gender IS NULL THEN 'Unknown' ---Replaces null with unknown
        ELSE Gender ---if gender is male or female, return it as it is
        END AS Sex ---new column name
From june_intake.bright_tv_casestudy.userprofiles;
-----------------------------------------------------------------
---Race Checks
------------------------------------------------------------------
Select distinct Race
From june_intake.bright_tv_casestudy.userprofiles;

Select Count(distinct UserID) AS Subs,
    CASE 
        WHEN Race = 'other' THEN 'unknown' ---replace other with unknown
        WHEN Race = 'None' THEN 'unknown' ---replace none with unknown
        WHEN Race = ' ' THEN 'unknown' ----replace empty with unknown
        WHEN Race IS NULL THEN 'unknown' ---replace null with unknown
        ELSE Race ---keep it as it is
        END AS Ethnicity ---new column
From june_intake.bright_tv_casestudy.userprofiles
Group by Ethnicity;
--------------------------------------------------
--Province checks
---------------------------------------------------
Select distinct Province
From june_intake.bright_tv_casestudy.userprofiles;

Select Distinct
    CASE 
        WHEN Province = 'None' THEN 'unknown'
        WHEN Province = ' ' THEN 'unknown'
        ELSE Province
        END AS Region
From june_intake.bright_tv_casestudy.userprofiles;
--------------------------------------------------
--Age checks
--------------------------------------------------
Select distinct Age
From june_intake.bright_tv_casestudy.userprofiles;

Select MIN(Age) AS min_age ---checks the youngest person
        MAX(Age) AS max_age ---checks the oldest person
        AVG(Age) AS mean_age
From june_intake.bright_tv_casestudy.userprofiles;
Select
    CASE
        WHEN Age = 0 THEN 'Infant'
        WHEN Age between 1 AND 12 THEN 'Kids'
        WHEN Age between 13 AND 17 THEN 'Youth'
        WHEN Age between 18 AND 35 THEN 'Young Adults'
        WHEN Age between 36 AND 50 THEN 'Adults'
        WHEN Age >50 AND Age <=60 THEN 'Elder'
        WHEN Age >60 THEN 'Pensioner'
        END AS Age_group
From june_intake.bright_tv_casestudy.userprofiles;
----------------------------------------------------------

---Combining above cleaned columns into one
Select
    UserID,
    CASE
        WHEN (Email IS NOT NULL) OR (Email<>' ') OR (Email NOT IN ('None','other')) THEN 1
        ELSE 0
        END AS Email_flag,
    CASE
        WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle`<>' ') OR (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
        ELSE 0
        END AS Socialmedia_flag,
    CASE
        WHEN gender = 'None' THEN 'unknown'
        WHEN gender = ' ' THEN 'unknown'
        WHEN gender IS NULL THEN 'unknown'
        ELSE gender
        END AS sex,
    
    CASE
        WHEN race = 'other' THEN 'unknown' 
        WHEN race = 'None' THEN 'unknown' 
        WHEN race = ' ' THEN 'unknown' 
        WHEN race IS NULL THEN 'unknown' 
        ELSE race 
        END AS ethnicity,
    
  CASE 
        WHEN Province = 'None' THEN 'unknown'
        WHEN Province = ' ' THEN 'unknown'
        ELSE Province
        END AS Region,
    
    Age,
    CASE
        WHEN Age = 0 THEN '01.Infant: 0'
        WHEN Age between 1 AND 12 THEN '02.Kids: 1 - 12'
        WHEN Age between 13 AND 17 THEN '03.Youth: 13 - 17'
        WHEN Age between 18 AND 35 THEN '04.Young Adults: 18 - 35'
        WHEN Age between 36 AND 50 THEN '05.Adults: 36 -50'
        WHEN Age >50 AND Age <=60 THEN '06.Elder: 51 -60'
        WHEN Age >60 THEN '07.Pensioner: >60'
        END AS Age_group
FROM june_intake.bright_tv_casestudy.userprofiles;

----------------------------------------------------------
---combining both tables together
----------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE user_profiles AS (
SELECT UserID,
    CASE
        WHEN Province = 'None' THEN 'Uncategorised'
        WHEN Province = ' ' THEN 'Uncategorised'
        WHEN Province = 'other' THEN 'Uncategorised'
        WHEN Province IS NULL THEN 'Uncategorised'
        ELSE Province
        END AS Region,

        Age,
     CASE
        WHEN Age = 0 THEN 'Infants'
        WHEN Age between 1 AND 12 THEN 'Kids'
        WHEN Age between 13 AND 17 THEN 'Youth'
        WHEN Age between 18 AND 35 THEN 'Young Adults'
        WHEN Age between 36 AND 50 THEN 'Adults'
        WHEN Age >50 AND Age <=60 THEN 'Elder'
        WHEN Age >60 THEN 'Pensioner'
        END AS Age_groups,

    CASE
        WHEN (Email IS NOT NULL) OR (Email = ' ') OR (Email NOT IN ('None','other')) THEN 1
        ELSE 0
        END AS Email_flag,

    CASE
        WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle` = ' ') OR (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
        ELSE 0
        END AS SM_flag,

    CASE
        WHEN Race = 'other' THEN 'None' 
        WHEN Race = ' ' THEN 'None' 
        ELSE Race 
        END AS Race,

      CASE
        WHEN Gender = 'other' THEN 'None' 
        WHEN Gender = ' ' THEN 'None' 
        ELSE Gender
        END AS Gender,

FROM june_intake.bright_tv_casestudy.userprofiles),


viewership AS (
SELECT
    COALESCE(UserID0,userid4) AS userid,
    TO_CHAR(RecordDate2,'yyyyMM') AS month_id,
    TO_DATE(RecordDate2) AS watch_date,
    TIME(RecordDate2) AS watch_time,
    TO_CHAR(RecordDate2,'DD') AS day_of_week,
    DAYNAME(RecordDate2) AS day_name,

    CASE
        WHEN day_name IN ('Sat','Sun') THEN 'weekend'
        ELSE 'weekday'
        END AS day_classification,

        MONTHNAME(RecordDate2) AS month_name,

    CASE
        WHEN Channel2 IN ('SaeSee','Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supersport Live Events','DStv Events1') THEN 'Live Events'
        ELESE Channel2
        END AS Tv_channel,

    date_format(RecordDate2,'HH:mm:ss') AS watch_time,
    CASE
        WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01.Midnight'
        WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02.Morning'
        WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03.Afternoon'
        WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04.Evening'
        END AS time_of_day,
    
    date_format(`Duartion 2`,'HH:mm:ss') AS duration,
    CASE
        WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01.Low Usage:<30 min'
        WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02.Mid Usage:<60 min'
        WHEN duration > '00:59:59' THEN '03.High Usage:>60 min'
        ELSE '04.No Usage'
        END AS screen_time_bucket,

    HOUR(RecordDate2)AS hour_of_day

FROM june_intake.bright_tv_casestudy.viewership),

SELECT Coalesce(A.userid,B.userid) AS sub_id,
        month_id,
        watch_date,
        date_of_week,
        day_name,
        day_classification,
        month_name,
        Tv_channel,
        time_of_day,
        hour_of_day,
        screen_time_bucket,
        --user_flag,
        duration,
        Region,
        Age_group,
        Email_flag,
        SM_flag,
        Race,
        Gender,
FROM viewership AS A
LEFT JOIN userprofiles AS B
ON A.userid = B.userid;





