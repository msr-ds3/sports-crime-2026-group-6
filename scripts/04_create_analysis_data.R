library(tidyverse)
library(lubridate)

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
