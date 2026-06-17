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

# Replicate table 2

games_by_weekday <-
    read_csv("./data/processed/games_per_city_with_ori.csv") %>%
    mutate(weekday = wday(game_date, week_start = getOption("lubridate.week.start", 7), label = TRUE)) %>%
    group_by(weekday) %>%
    summarize(observation_days = n())

num_games <- 
    games_by_weekday %>%
    summarize(sum = sum(as.numeric(games_by_weekday$observation_days)))

game_location_oris <-
    read_csv("./data/processed/city_to_ori.csv") 

crimes_by_weekday <-
    read_csv("./data/processed/crime_daily.csv") %>%
    filter(ori %in% game_location_oris$ori, year(incident_date) >= 2000) %>%
    mutate(weekday = wday(incident_date, week_start = getOption("lubridate.week.start", 7), label = TRUE)) %>%
    group_by(weekday) %>%
    summarize(agency_days = n())

num_crime_days <- 
    crimes_by_weekday %>%
    summarize(sum = sum(as.numeric(crimes_by_weekday$agency_days)))


table2 <-
    left_join(crimes_by_weekday, games_by_weekday, by = "weekday") %>%
    add_row(weekday = "Total", agency_days = num_crime_days$sum, observation_days = num_games$sum) %>%
    replace_na(replace = list(observation_days = 0)) 
