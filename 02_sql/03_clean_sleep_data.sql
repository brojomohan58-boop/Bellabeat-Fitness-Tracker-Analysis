-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 03_clean_sleep_data.sql
-- Purpose: Clean sleep_day, add sleep_efficiency_pct
--          (% of time in bed actually asleep).
-- Expected: ~413 rows, 24 unique users
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_sleep_data`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(SleepDay) AS sleep_date,
  CAST(TotalSleepRecords AS INT64) AS total_sleep_records,
  CAST(TotalMinutesAsleep AS INT64) AS total_minutes_asleep,
  CAST(TotalTimeInBed AS INT64) AS total_time_in_bed,
  CAST(TotalTimeInBed AS INT64) - CAST(TotalMinutesAsleep AS INT64) AS minutes_awake_in_bed,
  ROUND(
    SAFE_DIVIDE(
      CAST(TotalMinutesAsleep AS FLOAT64),
      CAST(TotalTimeInBed AS FLOAT64)
    ) * 100, 1
  ) AS sleep_efficiency_pct,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.sleep_day`
WHERE TotalMinutesAsleep IS NOT NULL
  AND TotalTimeInBed IS NOT NULL
  AND TotalTimeInBed > 0;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_sleep_data`;
-- Expected: ~413 rows, 24 unique users
