library(tidyverse)

years <- 2000:2005

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

write_csv(crime_daily_wide, "data/processed/crime_daily.csv")