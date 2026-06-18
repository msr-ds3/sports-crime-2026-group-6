# Replication of College Football Games and Crime

This project replicates and extends Rees and Schnepel’s study on college football games and crime. The original paper examines whether college football games are associated with increases in crime in host communities. Our replication focuses on daily assault and vandalism counts from NIBRS between 2000 and 2005 and matches them to college football schedules for the schools included in the original paper.

## Project Structure

```text
sports-crime-2026-group-6/
│
├── data/
│   ├── nibrs/
│   │   ├── nibrs_offense_segment_2000.csv
│   │   ├── nibrs_offense_segment_2001.csv
│   │   ├── nibrs_offense_segment_2002.csv
│   │   ├── nibrs_offense_segment_2003.csv
│   │   ├── nibrs_offense_segment_2004.csv
│   │   ├── nibrs_offense_segment_2005.csv
│   │   └── nibrs_batch_header_1991_2024.csv
│   │
│   └── processed/
│       ├── crime_daily.csv
│       ├── football_games.csv
│       ├── team_agency_candidates.csv
│       ├── team_agency_mapping.csv
│       └── analysis_data.csv
│
├── scripts/
│   ├── 01_get_schedules.R
│   ├── 02_filter_nibrs.R
│   ├── 03_team_agency_mapping.R
│   └── 04_create_analysis_data.R
│
├── results.Rmd
├── results.html
└── README.md
```

## Scripts

### `01_get_schedules.R`

Downloads college football game schedules for the years 2000–2005 using the `cfbfastR` package. The script keeps the game date, home team, away team, home score, away score, and whether the home team won. The output is saved as:

```text
data/processed/football_games.csv
```

### `02_filter_nibrs.R`

Processes the NIBRS offense segment files for 2000–2005. The script filters the offense data to assault and vandalism offenses, aggregates them to daily counts by ORI and date, and saves the cleaned crime dataset as:

```text
data/processed/crime_daily.csv
```

### `03_team_agency_mapping.R`

Creates the mapping between the 26 college football teams from Rees and Schnepel’s sample and their corresponding city police agency ORI codes. The script uses the NIBRS batch header file to match city names and state abbreviations to ORI codes. It first saves possible matches and then saves the final team-agency mapping as:

```text
data/processed/team_agency_candidates.csv
data/processed/team_agency_mapping.csv
```

### `04_create_analysis_data.R`

Combines the cleaned crime data, football schedules, and team-agency mapping into the final analysis dataset. The script creates one row for each team-day from 2000–2005 and adds indicators for home games, away games, game outcomes, year, month, and day of week. The final dataset is saved as:

```text
data/processed/analysis_data.csv
```

## Results Notebook

### `results.Rmd`

This R Markdown notebook contains the main replication results and extension analysis. It includes:

* Appendix Table 1 descriptive statistics for assaults and vandalism
* Table 2 distribution of game days by day of week
* Descriptive figures comparing Saturday crime levels across home games, away games, and no-game days
* Per-team plots comparing crime levels by game type
* Regression models estimating the relationship between football games and crime
* An extension examining whether home wins and home losses are associated with different crime levels

The rendered notebook is saved as:

```text
results.html
```

## Data Sources

The crime data come from NIBRS offense segment files cleaned by Jacob Kaplan and made available through openICPSR. The batch header file is used to identify agency ORI codes and match them to cities and states.

College football schedule data were collected using the `cfbfastR` package, which provides game-level college football data.

## Extension

For our extension, we examine whether the outcome of a home football game matters. We compare crime levels after home wins versus home losses and estimate regressions controlling for agency, month, and year fixed effects. This allows us to test whether the final result of a game is associated with changes in assault or vandalism levels.

## Notes

The replication may not exactly match the original paper because the cleaned NIBRS data source and agency reporting coverage may differ from the data used by Rees and Schnepel. Some agencies also had incomplete or unusual reporting patterns, so our results should be interpreted as a close replication rather than an exact reproduction.
