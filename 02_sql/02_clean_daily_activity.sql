-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 02_clean_daily_activity.sql
-- Purpose: Clean daily_activity, add day_of_week, total_active_minutes,
--          and data_source tag. Primary analysis table.
-- Expected: ~940 rows, 33 unique users
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_daily_activity`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(ActivityDate) AS activity_date,
  FORMAT_DATE('%A', DATE(ActivityDate)) AS day_of_week,
  CAST(TotalSteps AS INT64) AS total_steps,
  ROUND(TotalDistance, 2) AS total_distance,
  ROUND(TrackerDistance, 2) AS tracker_distance,
  ROUND(LoggedActivitiesDistance, 2) AS logged_activity_distance,
  ROUND(VeryActiveDistance, 2) AS very_active_distance,
  ROUND(ModeratelyActiveDistance, 2) AS moderately_active_distance,
  ROUND(LightActiveDistance, 2) AS light_active_distance,
  ROUND(SedentaryActiveDistance, 2) AS sedentary_active_distance,
  CAST(VeryActiveMinutes AS INT64) AS very_active_minutes,
  CAST(FairlyActiveMinutes AS INT64) AS fairly_active_minutes,
  CAST(LightlyActiveMinutes AS INT64) AS lightly_active_minutes,
  CAST(SedentaryMinutes AS INT64) AS sedentary_minutes,
  CAST(VeryActiveMinutes AS INT64)
    + CAST(FairlyActiveMinutes AS INT64)
    + CAST(LightlyActiveMinutes AS INT64) AS total_active_minutes,
  CAST(Calories AS INT64) AS calories,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.daily_activity`
WHERE TotalSteps IS NOT NULL
  AND TotalSteps >= 0
  AND Calories IS NOT NULL;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_daily_activity`;
-- Expected: ~940 rows, 33 unique users
