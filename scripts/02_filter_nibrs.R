library(tidyverse)

years <- 2000:2005
dates_2000 <- seq.Date(as.Date("2000/08/20"), as.Date("2000/12/10"), by = "day")
dates_2001 <- seq.Date(as.Date("2001/08/20"), as.Date("2001/12/10"), by = "day")
dates_2002 <- seq.Date(as.Date("2002/08/20"), as.Date("2002/12/10"), by = "day")
dates_2003 <- seq.Date(as.Date("2003/08/20"), as.Date("2003/12/10"), by = "day")
dates_2004 <- seq.Date(as.Date("2004/08/20"), as.Date("2004/12/10"), by = "day")
dates_2005 <- seq.Date(as.Date("2005/08/20"), as.Date("2005/12/10"), by = "day")
all_dates <- data.frame(dates_2000, dates_2001, dates_2002, dates_2003, dates_2004, dates_2005)

dir.create("data/processed", showWarnings = FALSE)

for (yr in years) {

  file_in <- paste0("data/nibrs/nibrs_offense_segment_", yr, ".csv")

  crimes <- read_csv(file_in, show_col_types = FALSE) %>%
    filter(
      str_detect(ucr_offense_code, "assault") |
        str_detect(ucr_offense_code, "vandalism")
    ) %>% 
    mutate(
      incident_date = as.Date(incident_date),
      crime_type = case_when(
        str_detect(ucr_offense_code, "assault") ~ "assault",
        str_detect(ucr_offense_code, "vandalism") ~ "vandalism"
      )
    ) %>%
    group_by(ori, incident_date, crime_type) %>%
    summarise(
      n = n_distinct(unique_incident_id),
      .groups = "drop"
    )

  write_csv(
    crimes,
    paste0("data/processed/crimes_", yr, ".csv")
  )
}

crime_daily <- map_dfr(
  years,
  ~read_csv(
    paste0("data/processed/crimes_", .x, ".csv"),
    show_col_types = FALSE
  )
)

crime_daily_wide <- crime_daily %>%
  group_by(ori, incident_date, crime_type) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  pivot_wider(
    id_cols = c(ori, incident_date),
    names_from = crime_type,
    values_from = n,
    values_fill = 0
  )

_join(crime_daily_wide, all_dates)

write_csv(crime_daily_wide, "data/processed/crime_daily.csv")