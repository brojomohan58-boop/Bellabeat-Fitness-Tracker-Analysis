-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 06_clean_weight_log.sql
-- Purpose: Clean weight_loginfo. Only 8 users logged weight.
--          SAFE_CAST used on Fat -- many NULLs, plain CAST would error.
-- Expected: ~67 rows, 8 unique users
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_weight_log`
AS
SELECT DISTINCT
  TRIM(CAST(Id AS STRING)) AS user_id,
  DATE(Date) AS log_date,
  Time AS log_time,
  ROUND(WeightKg, 2) AS weight_kg,
  ROUND(WeightPounds, 2) AS weight_pounds,
  SAFE_CAST(Fat AS INT64) AS fat_percentage,
  ROUND(BMI, 2) AS bmi,
  CASE
    WHEN BMI < 18.5 THEN 'Underweight'
    WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal'
    WHEN BMI BETWEEN 25.0 AND 29.9 THEN 'Overweight'
    ELSE 'Obese'
  END AS bmi_category,
  CAST(IsManualReport AS BOOL) AS is_manual_report,
  TRIM(CAST(LogId AS STRING)) AS log_id,
  'fitbit_kaggle' AS data_source
FROM `black-anagram-483420-k4.fitness_tracking_analysis.weight_loginfo`
WHERE WeightKg IS NOT NULL;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_weight_log`;
-- Expected: ~67 rows, 8 unique users
