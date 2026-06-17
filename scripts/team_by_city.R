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

team_city <- tribble(
  ~team, ~city_name, ~state_abbreviation,
  "Akron", "akron", "oh",
  "Iowa State", "ames", "ia",
  "Michigan", "ann arbor", "mi",
  "Ohio", "athens", "oh",
  "Texas", "austin", "tx",
  "Virginia Tech", "blacksburg", "va",
  "Boise State", "boise", "id",
  "Clemson", "clemson", "sc",
  "Air Force", "colorado springs", "co",
  "South Carolina", "columbia", "sc",
  "Ohio State", "columbus", "oh",
  "North Texas", "denton", "tx",
  "Michigan State", "east lansing", "mi",
  "Arkansas", "fayetteville", "ar",
  "Marshall", "huntington", "wv",
  "Iowa", "iowa city", "ia",
  "Arkansas State", "jonesboro", "ar",
  "Western Michigan", "kalamazoo", "mi",
  "Kansas", "lawrence", "ks",
  "Utah State", "logan", "ut",
  "Texas Tech", "lubbock", "tx",
  "West Virginia", "morgantown", "wv",
  "Idaho", "moscow", "id",
  "Eastern Michigan", "mount pleasant", "mi",
  "Middle Tennessee", "murfreesboro", "tn",
  "BYU", "provo", "ut"
)

relevant_cities_with_ori <-
  cities_and_ori %>%
  filter(city %in% str_to_lower(team_city$city_name) & state %in% str_to_upper(team_city$state_abbreviation)) %>%
  select(city, state, ori) %>%
  distinct() %>%
  group_by(city)

games_with_city_and_ori <-
  inner_join(games_by_city, relevant_cities_with_ori, by = c("city", "state")) %>%
  select(game_date, team, city, state, ori) %>%
  distinct()

write_csv(games_with_city_and_ori, "data/processed/games_per_city_with_ori.csv")
write_csv(relevant_cities_with_ori, "data/processed/city_to_ori.csv")
