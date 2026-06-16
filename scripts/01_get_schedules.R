library(tidyverse)
library(cfbfastR)
library(tidyverse)
Sys.setenv(CFBD_API_KEY = "QBNFmU8m5+31jgTj9mFW/X663VAAFG5hPyJWRFkBefobSTDoxskqxztPhyL434KL")

<<<<<<< HEAD
View(slice(cfbd_pbp_data(year = 2001), 1:25))
=======
years <- 2000:2005
>>>>>>> c36d1c603b908beddf619b4c275b71e2970f5897

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
