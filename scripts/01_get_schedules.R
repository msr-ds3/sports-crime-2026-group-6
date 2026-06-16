library(tidyverse)
library(cfbfastR)

Sys.setenv(CFBD_API_KEY = "QBNFmU8m5+31jgTj9mFW/X663VAAFG5hPyJWRFkBefobSTDoxskqxztPhyL434KL")

years <- 2000:2005

games <- map_dfr(years, function(yr) {
  cfbd_game_info(year = yr)
})

games_clean <- games %>%
  mutate(
    game_date = as.Date(start_date),
    home_win = home_points > away_points
  ) %>%
  select(
    season,
    game_date,
    home_team,
    away_team,
    home_points,
    away_points,
    home_win
  )

write_csv(games_clean, "data/processed/football_games.csv")
