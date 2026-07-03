-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 10_export_tables.sql
-- Purpose: EXPORT DATA statements to write each required CSV
--          to GCS, matching the 7 files Colab needs + master table.
--          Replace 'your-bucket-name' with your actual GCS bucket.
-- ============================================================

-- 1) master_user_activity.csv
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/master_user_activity_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
SELECT * FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`;

-- 2) user_summary.csv (Query A7)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/user_summary_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
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
  CASE
    WHEN AVG(total_steps) < 5000 THEN 'Sedentary'
    WHEN AVG(total_steps) < 7500 THEN 'Lightly Active'
    WHEN AVG(total_steps) < 10000 THEN 'Fairly Active'
    ELSE 'Very Active'
  END AS user_segment
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY user_id
ORDER BY avg_daily_steps DESC;

-- 3) day_of_week_trends.csv (Query A2)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/day_of_week_trends_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
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
    WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;

-- 4) peak_hours.csv (Query A3)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/peak_hours_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
SELECT
  hour_of_day,
  ROUND(AVG(step_total), 0) AS avg_steps,
  SUM(step_total) AS total_steps,
  COUNT(DISTINCT user_id) AS active_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.cleaned_hourly_steps`
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 5) steps_vs_calories.csv (Query A4)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/steps_vs_calories_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
SELECT
  user_id, activity_date, total_steps, calories,
  very_active_minutes, sedentary_minutes, daily_activity_segment
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
WHERE total_steps > 0 AND calories > 0;

-- 6) sleep_analysis.csv (Query A5)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/sleep_analysis_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
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

-- 7) weekly_trend.csv (Query A8)
EXPORT DATA OPTIONS(
  uri='gs://your-bucket-name/bellabeat/weekly_trend_*.csv',
  format='CSV', overwrite=true, header=true, field_delimiter=','
) AS
SELECT
  DATE_TRUNC(activity_date, WEEK) AS week_start,
  ROUND(AVG(total_steps), 0) AS avg_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(very_active_minutes), 0) AS avg_very_active_min,
  COUNT(DISTINCT user_id) AS active_users
FROM `black-anagram-483420-k4.fitness_tracking_analysis.master_user_activity`
GROUP BY week_start
ORDER BY week_start;

-- ============================================================
-- Alternative: no GCS bucket? Run each SELECT (02-09 outputs)
-- in BigQuery console and use "Save results → CSV (local file)"
-- for each of the 7 files instead of EXPORT DATA.
-- ============================================================
