# Key Findings — Bellabeat Fitness Tracker Analysis

> ⚠ Notebook (`bellabeat_analysis.ipynb`) has not yet been executed against real exported CSVs. Quantitative results below (r-values, t-stats, means) are placeholders — replace with actual output once Cells 03–17 are run. Structural/qualitative findings from the source documentation are accurate as-is.

## Data Completeness
- 33 unique users total
- 24/33 users logged sleep data
- 8/33 users logged weight data
- ~940 daily activity records across ~2 months

## Activity Patterns
- Steps positively correlate with calories burned (direction confirmed by design of metric; exact r/R² **TBD** — run Cell 07)
- Activity peaks in early evening hours (per Query A3 / Cell 13 hourly analysis — exact peak hour **TBD**)
- ~30% of users fall into the sedentary segment (<5,000 steps/day) with 15+ sedentary hours/day

## Statistical Tests (pending execution)
- Welch's t-test, active vs. sedentary users, calories burned — **TBD** (t-stat, p-value, mean difference — Cell 08)
- Full correlation matrix across 12 fitness/sleep variables — **TBD** top correlated pairs (Cell 06)

## Sleep
- Sleep-tracking users show more consistent overall engagement than non-trackers (qualitative, from source doc)
- Average sleep efficiency % and nights under 7hrs — **TBD** (Query A5 / Cell 14)

## Segmentation
- 4-tier segmentation by average daily steps: Sedentary / Lightly Active / Fairly Active / Very Active
- Per-segment avg steps, calories, activity score — **TBD** (Cell 09 output, Query A1)

## Next Step
Run notebook end-to-end against exported CSVs from `10_export_tables.sql`, then replace every **TBD** above with actual computed values before finalizing `case_study_report.pdf` Section 6.
