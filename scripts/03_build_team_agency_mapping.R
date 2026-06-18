library(tidyverse)

batch_header <- read_csv(
  "data/nibrs/nibrs_batch_header_1991_2024.csv",
  show_col_types = FALSE
)

batch_small <- batch_header %>%
  filter(year %in% 2000:2005) %>%
  select(
    ori,
    city_name,
    state_abbreviation,
    agency_indicator,
    population
  ) %>%
  distinct()

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

team_agency_candidates <- team_city %>%
  left_join(
    batch_small,
    by = c("city_name", "state_abbreviation")
  ) %>% distinct()

# write_csv(
#   team_agency_candidates,
#   "data/processed/team_agency_candidates.csv"
# )

team_agency <- team_agency_candidates %>%
  filter(agency_indicator == "city") %>%
  group_by(team) %>%
  ungroup() %>%
  select(
    team,
    city_name,
    state_abbreviation,
    ori
  ) %>% distinct()

write_csv(
  team_agency,
  "data/processed/team_agency_mapping.csv"
)
