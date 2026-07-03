"""
BELLABEAT FITNESS TRACKER — Python Analysis
Standard script version of bellabeat_analysis.ipynb (Cells 01-09).
NOTE: source documentation cut off mid-Cell 09 — Cells 10-19 not included.
No drive.mount() — run with CSVs in the same folder as this script.
"""

# ── Core libraries ───────────────────────────────────────────────────────────────────
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import matplotlib.gridspec as gridspec
import seaborn as sns
from scipy import stats
from scipy.stats import pearsonr, ttest_ind, gaussian_kde
import os, zipfile, warnings
warnings.filterwarnings("ignore")

# ── Global colour palette ────────────────────────────────────────────────────────────
BLUE    = '#2563EB'
NAVY    = '#1F3864'
RED     = '#EF4444'
ORANGE  = '#F97316'
GREEN   = '#16A34A'
PURPLE  = '#4F46E5'
PALETTE = ['#1F3864','#2563EB','#60A5FA','#BFDBFE']

# ── Chart style ──────────────────────────────────────────────────────────────────────
sns.set_theme(style='whitegrid', font_scale=1.05)
plt.rcParams['figure.dpi']        = 150
plt.rcParams['font.family']       = 'DejaVu Sans'
plt.rcParams['axes.spines.top']   = False
plt.rcParams['axes.spines.right'] = False
plt.rcParams['axes.titleweight']  = 'bold'
plt.rcParams['axes.titlesize']    = 13

DAY_ORDER = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']

print('✅  All libraries loaded successfully')


# ============================================================
# CELL 02: Load all 7 CSV files (place them next to this script)
# ============================================================
activity = pd.read_csv('master_user_activity.csv')
user_sum = pd.read_csv('user_summary.csv')
daytrend = pd.read_csv('day_of_week_trends.csv')
hourly   = pd.read_csv('peak_hours.csv')          # also becomes pbi_hourly_combined
scatter  = pd.read_csv('steps_vs_calories.csv')
sleep    = pd.read_csv('sleep_analysis.csv')
weekly   = pd.read_csv('weekly_trend.csv')

activity['activity_date'] = pd.to_datetime(activity['activity_date'])
weekly['week_start']      = pd.to_datetime(weekly['week_start'])

daytrend['day_of_week'] = pd.Categorical(
    daytrend['day_of_week'], categories=DAY_ORDER, ordered=True)
daytrend = daytrend.sort_values('day_of_week').reset_index(drop=True)

tables = {'master_user_activity':activity, 'user_summary':user_sum,
          'day_of_week_trends':daytrend,   'peak_hours':hourly,
          'steps_vs_calories':scatter,     'sleep_analysis':sleep,
          'weekly_trend':weekly}
print(f"{'Table':<28} {'Rows':>7}  {'Cols':>5}")
print('-'*45)
for name, df in tables.items():
    print(f'{name:<28} {len(df):>7,}  {df.shape[1]:>5}')
print(f"\nUnique users : {activity['user_id'].nunique()}")
print(f"Date range   : {activity['activity_date'].min().date()} → {activity['activity_date'].max().date()}")
print('\n✅  All 7 files loaded — ready to analyse')


# ============================================================
# CELL 03: Descriptive statistics — master table
# ============================================================
NUM_COLS = [
    'total_steps','total_distance','calories',
    'very_active_minutes','fairly_active_minutes',
    'lightly_active_minutes','sedentary_minutes',
    'total_active_minutes',
]
print("=== DAILY ACTIVITY — DESCRIPTIVE STATISTICS ===")
print(activity[NUM_COLS].describe().round(2).to_string())

SLEEP_COLS = ['total_minutes_asleep','total_time_in_bed',
              'minutes_awake_in_bed','sleep_efficiency_pct']
sleep_rows = activity.dropna(subset=['total_minutes_asleep'])
print("\n=== SLEEP — DESCRIPTIVE STATISTICS ===")
print(sleep_rows[SLEEP_COLS].describe().round(2).to_string())

nulls = activity[NUM_COLS + SLEEP_COLS].isnull().sum()
print("\n=== NULL COUNTS (only columns with nulls shown) ===")
print(nulls[nulls > 0])
print(f"\nRows with sleep data : {sleep_rows.shape[0]:,} / {len(activity):,}")
print(f"Users with sleep data: {sleep_rows['user_id'].nunique()} / {activity['user_id'].nunique()}")


# ============================================================
# CELL 04: Data participation — Chart 1 of 13
# ============================================================
days_tracked = activity.groupby('user_id')['activity_date'].nunique().sort_values()

fig, axes = plt.subplots(1, 2, figsize=(13, 5))

axes[0].hist(days_tracked.values, bins=10, color=BLUE, edgecolor='white', linewidth=0.9)
axes[0].axvline(days_tracked.median(), color=RED, linestyle='--', linewidth=1.8,
                label=f'Median: {days_tracked.median():.0f} days')
axes[0].set_title('Days Tracked per User')
axes[0].set_xlabel('Days'); axes[0].set_ylabel('Number of Users')
axes[0].legend()

labels = ['Activity\n(all users)', 'Sleep\n(24/33)', 'Weight\n(8/33)']
counts = [
    activity['user_id'].nunique(),
    activity.dropna(subset=['total_minutes_asleep'])['user_id'].nunique(),
    activity.dropna(subset=['bmi'])['user_id'].nunique()
]
bars = axes[1].bar(labels, counts, color=[NAVY, BLUE, '#93C5FD'], edgecolor='white')
for bar in bars:
    axes[1].text(bar.get_x()+bar.get_width()/2, bar.get_height()+.4,
                 str(int(bar.get_height())), ha='center', fontsize=12,
                 fontweight='bold', color=NAVY)
axes[1].set_title('Users with Data per Category')
axes[1].set_ylabel('Unique Users'); axes[1].set_ylim(0, 40)

plt.suptitle('Data Participation Overview', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('chart01_participation.png', bbox_inches='tight', dpi=150)
plt.show()


# ============================================================
# CELL 05: Distribution plots — 6 key metrics — Chart 2 of 13
# ============================================================
metrics = {
    'total_steps':          ('Total Daily Steps',        'Steps',  '#2563EB'),
    'calories':             ('Calories Burned',           'Cal',    '#DC2626'),
    'sedentary_minutes':    ('Sedentary Minutes/Day',     'Min',    '#7C3AED'),
    'very_active_minutes':  ('Very Active Minutes/Day',  'Min',    '#16A34A'),
    'total_active_minutes': ('Total Active Min/Day',     'Min',    '#0891B2'),
    'activity_score':       ('Activity Score (0-100)',   'Score',  '#D97706'),
}

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
axes = axes.flatten()

for i, (col, (title, xlabel, color)) in enumerate(metrics.items()):
    data = activity[col].dropna()
    axes[i].hist(data, bins=25, color=color, alpha=0.75,
                 edgecolor='white', linewidth=0.7, density=True)
    xs = np.linspace(data.min(), data.max(), 200)
    axes[i].plot(xs, gaussian_kde(data)(xs), color="black", linewidth=1.8, label="KDE")
    axes[i].axvline(data.mean(),   color=RED,   linestyle="--", linewidth=1.4,
                    label=f"Mean {data.mean():,.0f}")
    axes[i].axvline(data.median(), color=GREEN, linestyle=":",  linewidth=1.4,
                    label=f"Median {data.median():,.0f}")
    axes[i].set_title(title)
    axes[i].set_xlabel(xlabel)
    axes[i].legend(fontsize=7)

plt.suptitle('Distribution of Key Daily Metrics', fontsize=15, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('chart02_distributions.png', bbox_inches='tight', dpi=150)
plt.show()


# ============================================================
# CELL 06: Correlation matrix — Chart 3 of 13
# ============================================================
corr_cols = [
    'total_steps','total_distance','calories','very_active_minutes',
    'fairly_active_minutes','lightly_active_minutes','sedentary_minutes',
    'total_active_minutes','total_minutes_asleep',
    'total_time_in_bed','sleep_efficiency_pct','minutes_awake_in_bed'
]
corr_data   = activity[corr_cols].dropna(thresh=8)
corr_matrix = corr_data.corr(method="pearson")

fig, ax = plt.subplots(figsize=(13, 10))
mask = np.triu(np.ones_like(corr_matrix, dtype=bool))

sns.heatmap(
    corr_matrix, mask=mask, ax=ax,
    cmap='coolwarm', vmin=-1, vmax=1, center=0,
    annot=True, fmt=".2f", annot_kws={"size":8},
    linewidths=0.5, square=True,
    cbar_kws={'shrink':0.7, 'label':'Pearson r'}
)
ax.set_title('Correlation Matrix — Daily Fitness Metrics', fontsize=14,
             fontweight='bold', pad=16)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha='right', fontsize=9)
ax.set_yticklabels(ax.get_yticklabels(), rotation=0, fontsize=9)
plt.tight_layout()
plt.savefig('chart03_correlation_matrix.png', bbox_inches='tight', dpi=150)
plt.show()

pairs = (corr_matrix
         .where(np.tril(np.ones(corr_matrix.shape), k=-1).astype(bool))
         .stack().reset_index())
pairs.columns = ["var1","var2","r"]
pairs = pairs.reindex(pairs['r'].abs().sort_values(ascending=False).index)
print('Top 8 strongest correlations:')
print(pairs.head(8)[['var1','var2','r']].to_string(index=False))


# ============================================================
# CELL 07: Steps vs calories scatter + regression — Chart 4 of 13
# ============================================================
valid = scatter[(scatter['total_steps']>0) & (scatter['calories']>0)].copy()
r_val, p_val    = pearsonr(valid['total_steps'], valid['calories'])
slope, intercept, *_ = stats.linregress(valid['total_steps'], valid['calories'])

seg_colors = {'1_Sedentary':'#BFDBFE', '2_Lightly Active':'#3B82F6',
              '3_Fairly Active':'#1D4ED8', '4_Very Active':'#1F3864'}

fig, ax = plt.subplots(figsize=(9, 6))
for seg, grp in valid.groupby('daily_activity_segment'):
    ax.scatter(grp['total_steps'], grp['calories'],
               color=seg_colors.get(seg,"grey"), alpha=0.45, s=18,
               label=seg.replace('_',' ').lstrip('1234_'))

x_range = np.linspace(valid["total_steps"].min(), valid["total_steps"].max(), 300)
ax.plot(x_range, slope*x_range+intercept, color=RED, linewidth=2,
        linestyle='--', label=f'OLS trend  r={r_val:.3f}')

ax.text(0.03, 0.95,
        f'Pearson r = {r_val:.3f}\np-value < 0.001\nn = {len(valid):,}\nR² = {r_val**2:.3f}',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.85))

ax.set_title(f'Steps vs Calories — R²={r_val**2:.2f}, positive correlation confirmed')
ax.set_xlabel('Total Steps'); ax.set_ylabel('Calories Burned')
ax.legend(title='Segment', fontsize=8)
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x,_: f'{x:,.0f}'))
plt.tight_layout()
plt.savefig('chart04_steps_vs_calories.png', bbox_inches='tight', dpi=150)
plt.show()
print(f'r={r_val:.4f}  R²={r_val**2:.4f}  p={p_val:.2e}')


# ============================================================
# CELL 08: Welch T-test — active vs sedentary calories — Chart 5 of 13
# ============================================================
active_ids = user_sum[user_sum['user_segment'].isin(
    ['Fairly Active','Very Active'])]['user_id']
sed_ids    = user_sum[user_sum['user_segment'].isin(
    ['Sedentary','Lightly Active'])]['user_id']
active_cal = activity[activity['user_id'].isin(active_ids)]['calories'].dropna()
sed_cal    = activity[activity['user_id'].isin(sed_ids)]['calories'].dropna()
t_stat, p_val = ttest_ind(active_cal, sed_cal, equal_var=False)

fig, ax = plt.subplots(figsize=(8, 5))
bp = ax.boxplot([active_cal, sed_cal],
                labels=['Active\n(Fairly+Very)','Sedentary\n(Sed+Lightly)'],
                patch_artist=True, widths=0.5,
                medianprops=dict(color='black',linewidth=2))
bp['boxes'][0].set_facecolor(BLUE)
bp['boxes'][1].set_facecolor('#93C5FD')

y_max = max(active_cal.max(), sed_cal.max())
ax.plot([1,1,2,2],[y_max*1.02,y_max*1.06,y_max*1.06,y_max*1.02],'k-',linewidth=1)
sig = '***' if p_val<0.001 else '**' if p_val<0.01 else '*' if p_val<0.05 else 'ns'
ax.text(1.5, y_max*1.08, sig, ha='center', fontsize=16, fontweight='bold')
ax.set_title('Daily Calories: Active vs Sedentary Users')
ax.set_ylabel('Calories Burned')
plt.tight_layout()
plt.savefig('chart05_ttest_calories.png', bbox_inches='tight', dpi=150)
plt.show()
print(f't={t_stat:.3f}  p={p_val:.2e}  {"SIGNIFICANT" if p_val<0.05 else "ns"}')
print(f'Active mean   : {active_cal.mean():,.0f} cal/day')
print(f'Sedentary mean: {sed_cal.mean():,.0f} cal/day')
print(f'Difference    : {active_cal.mean()-sed_cal.mean():,.0f} cal/day')


# ============================================================
# CELL 09: User segmentation — donut + bar — Chart 6 of 13
# Segments built here from user_summary.csv (fixes the
# FileNotFoundError for user_segments.csv)
# ============================================================
SEG_ORDER  = ['Sedentary','Lightly Active','Fairly Active','Very Active']
SEG_COLORS = ['#BFDBFE','#60A5FA','#2563EB','#1F3864']

seg_counts = user_sum['user_segment'].value_counts().reindex(SEG_ORDER).dropna()

fig, axes = plt.subplots(1, 2, figsize=(13, 6))

wedges, texts, autotexts = axes[0].pie(
    seg_counts.values, labels=seg_counts.index,
    autopct='%1.0f%%', colors=SEG_COLORS,
    startangle=140, wedgeprops=dict(width=0.55), pctdistance=0.78)
for t in autotexts: t.set_fontsize(11); t.set_fontweight('bold')
for t in texts: t.set_fontsize(10)
axes[0].set_title('User Activity Segments\n(by avg daily steps)', pad=14)

seg_stats = (user_sum.groupby('user_segment')
             [['avg_daily_steps','avg_daily_calories']]
             .mean().reindex(SEG_ORDER).dropna())
x = np.arange(len(seg_stats)); w = 0.35
axes[1].bar(x-w/2, seg_stats['avg_daily_steps']/1000,
            width=w, color=BLUE, label='Avg Steps (000s)')
axes[1].bar(x+w/2, seg_stats['avg_daily_calories']/100,
            width=w, color=ORANGE, label='Avg Calories (00s)')
axes[1].set_xticks(x)
axes[1].set_xticklabels(seg_stats.index, rotation=15, ha='right')
axes[1].set_title('Avg Steps & Calories by Segment')
axes[1].set_ylabel('Scaled value (see legend units)')
axes[1].legend(fontsize=9)

plt.suptitle('User Segmentation Overview', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('chart06_user_segments.png', bbox_inches='tight', dpi=150)
plt.show()
print(seg_counts.to_string())
# NOTE: axes[1] block above completes the source doc's cut-off code —
# the pasted documentation ended mid-line here. Verify against your
# original notebook if you have it.

# ============================================================
# Cells 10-19 (Charts 7-13 + Cell 18 pbi_ export block) not in
# source doc yet — paste the rest and I'll add them here.
# ============================================================
