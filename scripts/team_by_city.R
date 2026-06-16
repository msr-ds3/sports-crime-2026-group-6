library(tidyverse)

team_by_city <- 
# Using kaggle dataset matching teams to cities: https://www.kaggle.com/datasets/mexwell/ncaa-stadiums
  read_csv("./data/processed/stadiums-geocoded-selected-columns.csv") %>%
  mutate(home_team = team)

games <-
  read_csv("./data/processed/football_games.csv")

games_by_city <- 
  inner_join(team_by_city, games, by = "home_team") %>%
  mutate(city = str_to_lower(city)) %>%
  select(team, city, state, game_date, home_win)

cities_and_ori <-
  read_csv("./data/nibrs/nibrs_batch_header_1991_2024.csv") %>%
  filter(year %in% 2000:2005) %>%
  mutate(city = city_name, state = str_sub(ori, 1, 2)) %>%
  select(ori, state, city)

cities <- c("Akron", "Ames", "Ann Arbor", "Athens", "Austin", "Blacksburg", "Boise", "Clemson", 
"Colorado Springs", "Columbia", "Columbus", "Denton", "East Lansing", "Fayetteville", "Huntington",
"Iowa City", "Jonesboro", "Kalamazoo", "Lawrence", "Logan", "Lubbock", "Morgantown", "Moscow",
"Mount Pleasant", "Murfreesboro", "Provo")

games_with_city_and_ori <-
  inner_join(games_by_city, cities_and_ori, by = c("city", "state")) %>%
  filter(city %in% str_to_lower(cities)) %>%
  distinct()


write_csv(games_with_city_and_ori, "data/processed/games_per_city_with_ori.csv")
