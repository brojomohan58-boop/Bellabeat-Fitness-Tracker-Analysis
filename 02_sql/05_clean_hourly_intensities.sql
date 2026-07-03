-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 05_clean_hourly_intensities.sql
-- Purpose: Clean hourly_intensities. ActivityHour was stored as STRING
--          -- cast via PARSE_TIME for type safety.
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_intensities`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(ActivityDate) AS activity_date,
  PARSE_TIME('%I:%M:%S %p', ActivityHour) AS activity_hour,
  EXTRACT(HOUR FROM PARSE_TIME('%I:%M:%S %p', ActivityHour)) AS hour_of_day,
  CAST(TotalIntensity AS INT64) AS total_intensity,
  ROUND(AverageIntensity, 2) AS average_intensity,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.hourly_intensities`
WHERE TotalIntensity IS NOT NULL;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_intensities`;
