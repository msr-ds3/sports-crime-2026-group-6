library(tidyverse)

team_by_city <- 
  read_csv("./data/processed/stadiums-geocoded-selected-columns.csv") %>%
  mutate(home_team = team)

games <-
  read_csv("./data/processed/football_games.csv")

games_by_city <- 
  inner_join(team_by_city, games, by = "home_team") %>%
  mutate(city = str_to_lower(city)) %>%
  select(stadium, city, state, team, game_date, home_win)

cities_and_ori <-
  read_csv("./data/nibrs/nibrs_batch_header_1991_2024.csv") %>%
  filter(year %in% 2000:2005) %>%
  mutate(city = city_name, state = str_sub(ori, 1, 2)) %>%
  select(ori, state, city)


games_with_city_and_ori <-
  inner_join(games_by_city, cities_and_ori, by = c("city", "state")) %>%
  distinct()
