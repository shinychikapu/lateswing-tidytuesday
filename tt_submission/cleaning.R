library(dplyr)
library(readr)
library(purrr)

base_path <- "G:/.shortcut-targets-by-id/1uONb6nTw9mTPgGMji1rvDZdVBoxD7_YY/forecasting-election-swings/data/king_county/"
years <- 2016:2025

all_files <- unlist(map(years, \(y) {
  list.files(
    path = file.path(base_path, y),
    pattern = "\\.csv$",
    full.names = TRUE
  )
}))

# Exclude any file with "combined" in the filename
all_files <- all_files[!grepl("combined", basename(all_files), ignore.case = TRUE)]

combined_data <- map_dfr(all_files, function(file) {
  read_csv(file) |>
    mutate(
      source_file = basename(file),
      year_folder = basename(dirname(file))
    )
})
library(stringr)
seattle_data <- combined_data |>
  filter(str_detect(`District Name`, "City of Seattle")) |>
  filter(!str_detect(`Ballot Title`, "Municipal")) |>
  filter(!str_detect(`Ballot Title`, "Proposition")) |>
  filter(!str_detect(`Ballot Title`, "Initiative"))

state_data <- combined_data |>
filter(`District Type` == "State Offices")

federal_data <- combined_data |>
  filter(`District Type` == "Federal")
