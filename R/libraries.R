################################################################################
# Libraries required for the app                                               #
################################################################################

#' Dependencies used in the app
dependencies <- c(
  "rjson",
  "jsonlite",
  "shiny",
  "dplyr",
  "janitor",
  "tidyr",
  "tidyselect",
  "readxl",
  "ggplot2",
  "plotly",
  "leaflet",
  "rworldmap",
  "sp",
  "glue",
  "colorspace",
  "htmltools",
  "pracma",
  "RSocrata",
  "geojsonio",
  "rgeos",
  "shinyalert"
)

#' Attempts to load packages and install them if required
#' @param dependencies - a vector of dependency names
load_dependencies <- function(dependencies) {
  print(dependencies)
  for (package in dependencies) {
    tryCatch({
      library(package, character.only = TRUE)
    }, error = function(e) {
      install.packages(package, repos = "https://cloud.r-project.org")
      library(package, character.only = TRUE)
    })
  }
}

# Load dependencies if running locally,
# avoid if hosted on shinyapps.io
if (!grepl("srv/connect", getwd())) {
  load_dependencies(dependencies)
}
