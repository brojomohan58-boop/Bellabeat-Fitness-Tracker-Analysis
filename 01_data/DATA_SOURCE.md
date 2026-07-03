# Data Source

## Dataset
**FitBit Fitness Tracker Data** — Kaggle, published by Möbius, CC0 Public Domain license.
Originally sourced via Amazon Mechanical Turk survey of 30–33 FitBit users who consented to submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring.

> ⚠ Verify exact license/attribution page and date range against the current Kaggle listing before publishing — this project's own SQL layer tags every row with `data_source = 'fitbit_kaggle'` for traceability but does not re-derive the survey period.

## Raw Tables Used (BigQuery: `fitness_tracking_analysis`)
| Table | Grain | Rows (raw) |
|---|---|---|
| `daily_activity` | 1 row/user/day | ~940 |
| `sleep_day` | 1 row/user/sleep-record/day | ~413 |
| `hourly_steps` | 1 row/user/hour | ~24,568 |
| `hourly_intensities` | 1 row/user/hour | ~24,568 |
| `weight_loginfo` | 1 row/user/weigh-in | ~67 |
| `heartrate_seconds` | 1 row/user/second | millions |

## Known Limitations
- **Small sample:** 33 unique users total; sleep data covers only 24, weight only 8.
- **Short window:** ~2 months of activity data — insufficient for seasonal trend analysis.
- **No demographics:** no age, gender, location, or health-condition fields — segmentation is behavior-only (steps-based).
- **Self-selected sample:** Mechanical Turk respondents are not guaranteed representative of Bellabeat's target demographic.
- **Uneven device compliance:** weight and sleep logging require manual/opt-in tracking, producing large null gaps versus passively-collected steps/calories.

These limitations are stated explicitly in the case study report as a caveat, with a recommendation for a larger, demographically-varied follow-up study.
