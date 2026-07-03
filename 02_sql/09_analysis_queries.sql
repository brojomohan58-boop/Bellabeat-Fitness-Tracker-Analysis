-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 09_analysis_queries.sql
-- Purpose: A1-A8 analysis queries. Run after master_user_activity
--          is built. Export each result set as CSV for Python/Power BI.
-- ============================================================

-- ---------------------------------------------------------
-- A1: User Segmentation Summary
-- Export as: user_segments.csv
-- ---------------------------------------------------------
SELECT
  daily_activity_segment,
  COUNT(DISTINCT user_id) AS user_count,
  ROUND(AVG(total_steps), 0) AS avg_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(sedentary_minutes), 0) AS avg_sedentary_min,
  ROUND(AVG(activity_score), 1) AS avg_activity_score
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY daily_activity_segment
ORDER BY daily_activity_segment;


-- ---------------------------------------------------------
-- A2: Average Steps & Calories by Day of Week
-- Export as: day_of_week_trends.csv
-- ---------------------------------------------------------
SELECT
  day_of_week,
  ROUND(AVG(total_steps), 0) AS avg_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(very_active_minutes), 0) AS avg_very_active_min,
  ROUND(AVG(sedentary_minutes), 0) AS avg_sedentary_min,
  COUNT(*) AS data_points
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY day_of_week
ORDER BY
  CASE day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;


-- ---------------------------------------------------------
-- A3: Peak Activity Hours (from hourly steps)
-- Export as: peak_hours.csv
-- ---------------------------------------------------------
SELECT
  hour_of_day,
  ROUND(AVG(step_total), 0) AS avg_steps,
  SUM(step_total) AS total_steps,
  COUNT(DISTINCT user_id) AS active_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_steps`
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- ---------------------------------------------------------
-- A4: Steps vs Calories Correlation (scatter data)
-- Export as: steps_vs_calories.csv
-- ---------------------------------------------------------
SELECT
  user_id,
  activity_date,
  total_steps,
  calories,
  very_active_minutes,
  sedentary_minutes,
  daily_activity_segment
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
WHERE total_steps > 0
  AND calories > 0;


-- ---------------------------------------------------------
-- A5: Sleep Quality Analysis
-- Export as: sleep_analysis.csv
-- ---------------------------------------------------------
SELECT
  user_id,
  ROUND(AVG(total_minutes_asleep), 0) AS avg_min_asleep,
  ROUND(AVG(total_time_in_bed), 0) AS avg_time_in_bed,
  ROUND(AVG(minutes_awake_in_bed), 0) AS avg_min_wasted,
  ROUND(AVG(sleep_efficiency_pct), 1) AS avg_sleep_efficiency,
  COUNTIF(total_minutes_asleep < 420) AS nights_under_7hrs,
  COUNT(*) AS total_nights_logged
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
WHERE total_minutes_asleep IS NOT NULL
GROUP BY user_id
ORDER BY avg_sleep_efficiency ASC;


-- ---------------------------------------------------------
-- A6: Sedentary Time Distribution
-- Export as: sedentary_distribution.csv
-- ---------------------------------------------------------
SELECT
  CASE
    WHEN sedentary_minutes < 600 THEN 'Low (<10hrs)'
    WHEN sedentary_minutes < 900 THEN 'Medium (10-15hrs)'
    ELSE 'High (>15hrs)'
  END AS sedentary_bucket,
  COUNT(*) AS day_count,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(total_steps), 0) AS avg_steps
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY sedentary_bucket
ORDER BY sedentary_bucket;


-- ---------------------------------------------------------
-- A7: Per-User Summary (one row per user)
-- Export as: user_summary.csv -- key for user-level filter in Power BI
-- ---------------------------------------------------------
SELECT
  user_id,
  COUNT(DISTINCT activity_date) AS days_tracked,
  ROUND(AVG(total_steps), 0) AS avg_daily_steps,
  ROUND(AVG(calories), 0) AS avg_daily_calories,
  ROUND(AVG(sedentary_minutes), 0) AS avg_sedentary_min,
  ROUND(AVG(very_active_minutes), 0) AS avg_very_active_min,
  ROUND(AVG(activity_score), 1) AS avg_activity_score,
  ROUND(AVG(total_minutes_asleep), 0) AS avg_min_asleep,
  ROUND(AVG(sleep_efficiency_pct), 1) AS avg_sleep_efficiency,
  ANY_VALUE(bmi) AS bmi,
  ANY_VALUE(bmi_category) AS bmi_category,
  -- Segment based on AVERAGE (not daily)
  CASE
    WHEN AVG(total_steps) < 5000 THEN 'Sedentary'
    WHEN AVG(total_steps) < 7500 THEN 'Lightly Active'
    WHEN AVG(total_steps) < 10000 THEN 'Fairly Active'
    ELSE 'Very Active'
  END AS user_segment
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY user_id
ORDER BY avg_daily_steps DESC;


-- ---------------------------------------------------------
-- A8: Weekly Trend (steps over time)
-- Export as: weekly_trend.csv
-- ---------------------------------------------------------
SELECT
  DATE_TRUNC(activity_date, WEEK) AS week_start,
  ROUND(AVG(total_steps), 0) AS avg_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(very_active_minutes), 0) AS avg_very_active_min,
  COUNT(DISTINCT user_id) AS active_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY week_start
ORDER BY week_start;
