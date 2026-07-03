# Data Dictionary — `master_user_activity`

Primary analysis table. Grain: 1 row per `user_id` per `activity_date`. Built by `08_master_user_activity.sql` (LEFT JOIN of `cleaned_daily_activity`, `cleaned_sleep_data`, `cleaned_weight_log`).

| Column | Type | Description |
|---|---|---|
| `user_id` | STRING | Anonymized FitBit user identifier, trimmed |
| `activity_date` | DATE | Calendar date of the record |
| `day_of_week` | STRING | Full weekday name (e.g. `Monday`) |
| `total_steps` | INT64 | Total steps recorded that day |
| `total_distance` | FLOAT64 | Total distance (km), rounded to 2dp |
| `calories` | INT64 | Total calories burned that day |
| `very_active_minutes` | INT64 | Minutes at "very active" intensity |
| `fairly_active_minutes` | INT64 | Minutes at "fairly active" intensity |
| `lightly_active_minutes` | INT64 | Minutes at "lightly active" intensity |
| `sedentary_minutes` | INT64 | Minutes sedentary |
| `total_active_minutes` | INT64 | Sum of very + fairly + lightly active minutes |
| `total_minutes_asleep` | INT64 (nullable) | Minutes asleep; NULL if no sleep log that day |
| `total_time_in_bed` | INT64 (nullable) | Minutes in bed; NULL if no sleep log |
| `minutes_awake_in_bed` | INT64 (nullable) | `total_time_in_bed - total_minutes_asleep` |
| `sleep_efficiency_pct` | FLOAT64 (nullable) | `(minutes_asleep / time_in_bed) * 100`, rounded 1dp |
| `weight_kg` | FLOAT64 (nullable) | Logged weight in kg; NULL if no weigh-in that day |
| `bmi` | FLOAT64 (nullable) | Logged BMI |
| `bmi_category` | STRING (nullable) | `Underweight` / `Normal` / `Overweight` / `Obese`, derived from `bmi` |
| `daily_activity_segment` | STRING | `1_Sedentary` (<5000 steps) / `2_Lightly Active` (<7500) / `3_Fairly Active` (<10000) / `4_Very Active` (≥10000) — **per-day** segment |
| `activity_score` | FLOAT64 | Composite 0–100 score: `LEAST((steps/10000*50) + (very_active_min/30*30) + (total_active_min/60*20), 100)` |

## Related Tables
- `cleaned_daily_activity`, `cleaned_sleep_data`, `cleaned_hourly_steps`, `cleaned_hourly_intensities`, `cleaned_weight_log`, `cleaned_heart_rate`, `hourly_heart_rate` — see individual `0X_clean_*.sql` files for their schemas.
- `user_summary` (Query A7) — one row per user, averages of the above + `user_segment` (segment based on the user's **average** steps, not daily).
