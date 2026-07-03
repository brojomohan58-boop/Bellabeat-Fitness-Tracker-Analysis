-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 07_clean_heart_rate.sql
-- Purpose: Clean heartrate_seconds (filter physiologically impossible
--          values) then roll up to hourly averages for joining/viz,
--          since seconds-level granularity is too fine for analysis.
-- ============================================================

-- 7a: Cleaned seconds-level table
CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_heart_rate`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(Date) AS heart_date,
  Time AS heart_time,
  CAST(Value AS INT64) AS heart_rate,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.heartrate_seconds`
WHERE Value IS NOT NULL
  AND CAST(Value AS INT64) BETWEEN 30 AND 220;  -- filter impossible values

-- 7b: Hourly rollup (more useful for analysis)
CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.hourly_heart_rate`
AS
SELECT
  user_id,
  heart_date,
  EXTRACT(HOUR FROM heart_time) AS hour_of_day,
  ROUND(AVG(heart_rate), 1) AS avg_heart_rate,
  MIN(heart_rate) AS min_heart_rate,
  MAX(heart_rate) AS max_heart_rate,
  COUNT(*) AS reading_count
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_heart_rate`
GROUP BY user_id, heart_date, hour_of_day;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users,
  MIN(avg_heart_rate) AS min_avg_hr,
  MAX(avg_heart_rate) AS max_avg_hr
FROM `black-anagram-483420-k4.fitness_tracking_analysis.hourly_heart_rate`;
