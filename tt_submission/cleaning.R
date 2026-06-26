library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(tidyr)

parse_manifest_date <- \(date) {
  date <- as.character(date)
  parsed_date <- as.Date(date, format = "%Y-%m-%d")
  missing_date <- is.na(parsed_date)
  parsed_date[missing_date] <- as.Date(date[missing_date], format = "%m/%d/%Y")
  parsed_date
}

manifest <- read_csv(
  "tt_submission/king_county_november_results_manifest.csv",
  col_types = cols(
    year = col_integer(),
    date = col_character(),
    url = col_character()
  )
) |>
  mutate(date = parse_manifest_date(date))

clean_column_names <- \(cols) {
  cols |>
    str_to_lower() |>
    str_replace_all(" ", "_")
}

combined_data <- manifest |>
  filter(year >= 2022) |>
  arrange(year, date) |>
  mutate(
    data = pmap(
      list(url, date),
      \(url, date) {
        read_csv(url, show_col_types = FALSE) |>
          rename_with(clean_column_names) |>
          mutate(
            report_date = date
          )
      }
    )
  ) |>
  select(-url, -date) |>
  unnest(data) |>
  rename_with(clean_column_names) |>
  group_by(year) |>
  mutate(time_index = dense_rank(report_date)) |>
  ungroup()
