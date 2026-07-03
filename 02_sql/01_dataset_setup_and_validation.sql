-- ============================================================
-- BELLABEAT FITNESS TRACKER ANALYSIS
-- 01_dataset_setup_and_validation.sql
-- Purpose: Confirm dataset and all 6 raw source tables exist
--          before running cleaning scripts.
-- ============================================================

-- Confirm dataset exists
SELECT schema_name
FROM `black-anagram-483420-k4.INFORMATION_SCHEMA.SCHEMATA`
WHERE schema_name = 'fitness_tracking_analysis';

-- Confirm all 6 raw source tables exist
SELECT table_name
FROM `black-anagram-483420-k4.fitness_tracking_analysis.INFORMATION_SCHEMA.TABLES`
WHERE table_name IN (
  'daily_activity', 'sleep_day', 'hourly_steps',
  'hourly_intensities', 'weight_loginfo', 'heartrate_seconds'
);
