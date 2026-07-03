-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 08_master_user_activity.sql
-- Purpose: Build the PRIMARY table for Python and Power BI.
--          Joins daily activity + sleep + weight, adds derived
--          metrics: daily_activity_segment, activity_score.
-- Depends on: cleaned_daily_activity, cleaned_sleep_data, cleaned_weight_log
-- ============================================================

CREATE OR REPLACE TABLE
  `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
AS
WITH base AS (
  SELECT
    da.user_id,
    da.activity_date,
    da.day_of_week,
    da.total_steps,
    da.total_distance,
    da.calories,
    da.very_active_minutes,
    da.fairly_active_minutes,
    da.lightly_active_minutes,
    da.sedentary_minutes,
    da.total_active_minutes,
    sd.total_minutes_asleep,
    sd.total_time_in_bed,
    sd.minutes_awake_in_bed,
    sd.sleep_efficiency_pct,
    wl.weight_kg,
    wl.bmi,
    wl.bmi_category
  FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_daily_activity` da
  LEFT JOIN `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_sleep_data` sd
    ON da.user_id = sd.user_id
    AND da.activity_date = sd.sleep_date
  LEFT JOIN `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_weight_log` wl
    ON da.user_id = wl.user_id
    AND da.activity_date = wl.log_date
)
SELECT
  *,
  -- User segmentation by daily steps
  CASE
    WHEN total_steps < 5000 THEN '1_Sedentary'
    WHEN total_steps < 7500 THEN '2_Lightly Active'
    WHEN total_steps < 10000 THEN '3_Fairly Active'
    ELSE '4_Very Active'
  END AS daily_activity_segment,
  -- Composite activity score (0-100)
  ROUND(
    LEAST(
      (total_steps / 10000.0 * 50)
      + (very_active_minutes / 30.0 * 30)
      + (total_active_minutes / 60.0 * 20),
      100
    ), 1
  ) AS activity_score
FROM base;

-- Validate
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users,
  ROUND(AVG(total_steps), 0) AS avg_daily_steps,
  ROUND(AVG(calories), 0) AS avg_daily_calories,
  ROUND(AVG(sedentary_minutes), 0) AS avg_sedentary_min,
  COUNTIF(total_minutes_asleep IS NOT NULL) AS rows_with_sleep,
  COUNTIF(bmi IS NOT NULL) AS rows_with_weight
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`;
