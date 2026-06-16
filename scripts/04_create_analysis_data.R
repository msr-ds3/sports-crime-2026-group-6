library(tidyverse)
library(lubridate)

# Replicate table 2

games_by_weekday <-
    read_csv("./data/processed/games_per_city_with_ori.csv") %>%
    mutate(weekday = wday(game_date, week_start = getOption("lubridate.week.start", 7), label = TRUE)) %>%
    group_by(weekday) %>%
    summarize(count = n())

num_games <- 
    games_by_weekday %>%
    summarize(sum = sum(as.numeric(count)))

game_location_oris <-
    read_csv("./data/processed/games_per_city_with_ori.csv") %>%
    select(ori) %>%
    distinct()

crimes_by_weekday <-
    read_csv("./data/processed/crime_daily.csv") %>%
    filter(ori %in% game_location_oris$ori, year(incident_date) >= 2000) %>%
    mutate(weekday = wday(incident_date, week_start = getOption("lubridate.week.start", 7), label = TRUE)) %>%
    group_by(weekday) %>%
    summarize(count = n())

num_crime_days <- 
    crimes_by_weekday %>%
    summarize(sum = sum(as.numeric(count)))