library(tidyverse)
library(lubridate)

crime_daily <- read_csv("data/processed/crime_daily.csv", show_col_types = FALSE)
football_games <- read_csv("data/processed/football_games.csv", show_col_types = FALSE)
team_agency <- read_csv("data/processed/team_agency_mapping.csv", show_col_types = FALSE)

team_dates <- team_agency %>%
  crossing(date = seq(as.Date("2000-01-01"), as.Date("2005-12-31"), by = "day"))

home_games <- football_games %>%
  inner_join(team_agency, by = c("home_team" = "team")) %>%
  transmute(
    team = home_team,
    ori,
    date = game_date,
    home_game = 1,
    away_game = 0,
    home_win = home_win
  )

away_games <- football_games %>%
  inner_join(team_agency, by = c("away_team" = "team")) %>%
  transmute(
    team = away_team,
    ori,
    date = game_date,
    home_game = 0,
    away_game = 1,
    home_win = NA
  )

games_team_day <- bind_rows(home_games, away_games) %>%
  group_by(team, ori, date) %>%
  summarise(
    home_game = max(home_game),
    away_game = max(away_game),
    home_win = ifelse(any(home_game == 1), home_win[home_game == 1][1], NA),
    .groups = "drop"
  )

analysis_data <- team_dates %>%
  left_join(crime_daily, by = c("ori", "date" = "incident_date")) %>%
  left_join(games_team_day, by = c("team", "ori", "date")) %>%
  mutate(
    assault = replace_na(assault, 0),
    vandalism = replace_na(vandalism, 0),
    home_game = replace_na(home_game, 0),
    away_game = replace_na(away_game, 0),
    year = year(date),
    month = month(date),
    day_of_week = wday(date, label = TRUE)
  )

write_csv(analysis_data, "data/processed/analysis_data.csv")
