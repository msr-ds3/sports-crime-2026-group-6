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

years <- 2000:2005
dates_2000 <- seq.Date(as.Date("2000/08/20"), as.Date("2000/12/10"), by = "day")
dates_2001 <- seq.Date(as.Date("2001/08/20"), as.Date("2001/12/10"), by = "day")
dates_2002 <- seq.Date(as.Date("2002/08/20"), as.Date("2002/12/10"), by = "day")
dates_2003 <- seq.Date(as.Date("2003/08/20"), as.Date("2003/12/10"), by = "day")
dates_2004 <- seq.Date(as.Date("2004/08/20"), as.Date("2004/12/10"), by = "day")
dates_2005 <- seq.Date(as.Date("2005/08/20"), as.Date("2005/12/10"), by = "day")
all_dates <- c(dates_2000, dates_2001, dates_2002, dates_2003, dates_2004, dates_2005)

all_dates_df <- data.frame(all_dates)
oris <- select(team_agency, ori)
all_days_and_oris <- cross_join(oris, all_dates_df)
all_days_with_crimes <- left_join(all_days_and_oris, crime_daily, by = c("ori", "all_dates" = "incident_date")) %>% 
  arrange(ori) %>%
  replace_na(replace = list(vandalism = 0, assault = 0))

analysis_data <-
  left_join(all_days_with_crimes, games_team_day, by = c("all_dates" = "date", "ori")) %>%
  mutate(
    assault = replace_na(assault, 0),
    vandalism = replace_na(vandalism, 0),
    home_game = replace_na(home_game, 0),
    away_game = replace_na(away_game, 0),
    no_game = 1 - (home_game + away_game),
    date = all_dates,
    year = year(date),
    month = month(date),
    day_of_week = wday(date, label = TRUE)
  ) %>%
  left_join(team_agency, by = "ori") %>%
  mutate(team = team.y) %>%
  filter(team != "Texas Tech") %>%  
  select(ori, date, vandalism, assault, home_game, away_game, no_game, home_win, year, month, day_of_week, team)
  
  write_csv(analysis_data, "data/processed/analysis_data.csv")
