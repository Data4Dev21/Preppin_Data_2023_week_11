--Data Source Bank want some quick and dirty analysis. 
--They know where their customers are, they know where their branches are. 
--But they don't know which customers are closest to which branches. 
--Which customers should they be prioritising based on proximity to their branches?

--Transform the latitude and longitudes from decimal degrees to radians by dividing them by 180/pi 
--The distance (in miles) can then be calculated as:  3963 * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(long2 – long1))

--Append the Branch information to the Customer information
--Transform the latitude and longitude into radians
--Find the closest Branch for each Customer
--Make sure Distance is rounded to 2 decimal places
--For each Branch, assign a Customer Priority rating, the closest customer having a rating of 1

SELECT *
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_BRANCHES;  --Branch Data

SELECT *
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_CUSTOMER_LOCATIONS; --Customer Data

WITH RAD_TABLE AS
(
SELECT *
      ,ADDRESS_LAT/(180/PI()) AS ADDRESS_LAT_RAD
      ,ADDRESS_LONG/(180/PI()) AS ADDRESS_LONG_RAD
      ,BRANCH_LAT/(180/PI()) AS BRANCH_LAT_RAD
      ,BRANCH_LONG/(180/PI()) AS BRANCH_LONG_RAD
      ,BRANCH_LONG/(180/PI())-ADDRESS_LONG/(180/PI()) AS LONG_DIFF
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_CUSTOMER_LOCATIONS
CROSS JOIN TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK11_DSB_BRANCHES --Cross join since there is no common field
)
--3963 * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(long2 – long1))
,
FINAL_TABLE AS
(
SELECT BRANCH
       ,BRANCH_LAT
       ,BRANCH_LONG
      ,ROUND(3963 * acos((sin(ADDRESS_LAT_RAD) * sin(BRANCH_LAT_RAD)) + cos(ADDRESS_LAT_RAD) * cos(BRANCH_LAT_RAD) * cos(LONG_DIFF)),2) AS DISTANCE
      ,ROW_NUMBER() OVER (PARTITION BY BRANCH ORDER BY DISTANCE ) AS CUSTOMER_PRIORITY
      ,CUSTOMER
      ,ADDRESS_LONG
      ,ADDRESS_LAT
      ,ROW_NUMBER() OVER (PARTITION BY CUSTOMER ORDER BY DISTANCE ) AS PROXIMITY      
FROM RAD_TABLE
QUALIFY PROXIMITY =1
ORDER BY CUSTOMER
)
SELECT BRANCH
       ,BRANCH_LAT
       ,BRANCH_LONG
      ,DISTANCE
      ,CUSTOMER_PRIORITY
      ,CUSTOMER
      ,ADDRESS_LONG
      ,ADDRESS_LAT
FROM FINAL_TABLE 
ORDER BY 1,5;
