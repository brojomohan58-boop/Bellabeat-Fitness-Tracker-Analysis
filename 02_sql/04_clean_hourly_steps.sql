-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 04_clean_hourly_steps.sql
-- Purpose: Clean hourly_steps. ActivityTime was stored as STRING
--          (e.g. "12:00:00 AM") -- PARSE_TIME converts to TIME type
--          for proper hour extraction.
-- Expected: 24568 rows, hours 0-23
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_steps`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(ActivityDate) AS activity_date,
  PARSE_TIME('%I:%M:%S %p', ActivityTime) AS activity_time,
  EXTRACT(HOUR FROM PARSE_TIME('%I:%M:%S %p', ActivityTime)) AS hour_of_day,
  CAST(StepTotal AS INT64) AS step_total,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.hourly_steps`
WHERE StepTotal IS NOT NULL;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users,
  MIN(hour_of_day) AS min_hour,
  MAX(hour_of_day) AS max_hour
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_steps`;
-- Expected: 24568 rows, hours 0-23
