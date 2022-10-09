################################################################################
# Data handlers for the app                                                    #
################################################################################
library(jsonlite)
library(dplyr)
library(RSocrata)
library(glue)

#' Load data from either excel file or csv
#' @param filename the filename for the file to be loaded
#' @param ... additional parameters to pass to jsonlite::fromJSON
#' @return dataframe
load_json <- function(filename, ...) {
  df <- jsonlite::fromJSON(txt = filename, flatten = TRUE)
  return(df)
}

#' Queries the Socrata API to get data
#' @param dataset The name of the dataset required.
#' @param params A list of parameters to apply to the query as list(key=value).
#' @return Dataframe.
#' @throws Error if dataset is unrecognised.
#' @throws Error if error in response when fetching data.
load_remote <- function(dataset, params = list()) {
  # Print verbose
  print(glue("Loading remote dataset: {dataset}"))

  # The app token to access the api
  app_token <- "M9ZZYTOg8ADyERRdemysg1SOU"

  # Convert the params list into a GET query string
  query <- ""
  if (length(params) > 0) {
    query_string <- paste(names(params), params, sep = "=", collapse = "&")
    query <- glue("?{query_string}")
  }

  # Match the dataset resource
  resource <- switch(
    dataset,
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/wuf8-susg
    "bays" = "wuf8-susg.json",
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/vdsi-4gtj
    "meters" = "vdsi-4gtj.json",
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/ntht-5rk7
    "restrictions" = "ntht-5rk7.json",
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/vh2v-4nfs
    "sensors" = "vh2v-4nfs.json",
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/7pgd-bdf2
    "sensors_2019" = "7pgd-bdf2.json",
    #' @see https://dev.socrata.com/foundry/data.melbourne.vic.gov.au/7q9g-yyvg
    "paystay_restrictions" = "7q9g-yyvg.json",
    #' @see https://data.melbourne.vic.gov.au/Transport/Pay-Stay-parking-restrictions/ambt-72qg
    "paystay_segments" = "7q9g-yyvg.json",
    TRUE: stop(glue("Unrecognised dataset {dataset}"))
  )

  df <- read.socrata(
    glue("https://data.melbourne.vic.gov.au/resource/{resource}{query}"),
    app_token = app_token
  )
  
  # Print verbose
  print(glue("Dataset {dataset} loaded with {nrow(df)} rows"))

  return(df)
}

#' Loads all the required data and performs the necessary joins
#' @returns Dataframe containing an entire set of required data
load_master_data <- function() {
  #' @section City of Melbourne parking datasets -----------------------------

  # On-street parking bay sensors
  # sensors should be 2-min live, but is currently disrupted, thus static
  sensors <- load_remote("sensors") %>%
    # rename foreign key st_marker_id to marker_id for consistency
    rename(marker_id = st_marker_id) %>%
    # select the required info
    select(c(bay_id, status))

  # On-street parking bays
  bays <- load_remote("bays", params = list(
    # return only the following columns
    "$select" = "marker_id,meter_id,bay_id,rd_seg_id,rd_seg_dsc"
  ))

  # On-street car park bay restrictions
  restrictions <- load_remote("restrictions") %>%
    # rename key bayid to bay_id for consistency
    rename(bay_id = bayid)

  # On-street car parking meters with location
  meters <- load_remote("meters") %>%
    # rename key meterid to meter_id for consistency
    rename(meter_id = meterid) %>%
    # make longitude, latitude numeric
    mutate_at(c("longitude", "latitude"), as.numeric)

  #' @section Paystay datasets -----------------------------------------------

  # Pay Stay parking restrictions
  paystay_restrictions <- load_remote("paystay_restrictions")

  # Pay Stay zones linked to street segments
  # paystay_segments <- load_remote("paystay_segments") %>%
  #   # rename the foreign key street_segment_id to rd_segment_id
  #   # for consistency
  #   rename(rd_seg_id = street_segment_id)

  df <- bays %>%
    left_join(restrictions, by = "bay_id") %>%
    # inner_join(meters, by = "meter_id") %>%
    # inner_join(paystay_segments, by = "rd_seg_id") %>%
    # inner_join(paystay_restrictions, by = "pay_stay_zone") %>%
    left_join(sensors, by = c("bay_id"))

  #' @debug
  View(df)

  return(df)
}

#' Filters the master_data to pass on to the map renderer based on state
#' @param master_data The master data dataframe
#' @param state The state reactive object
#' @return a dataframe filtered with state parameters
map_data <- function(master_data, state) {
  # Unpack state parameters
  filter_free <- state$filter_free
  filter_accessible <- state$filter_accessible
  filter_radius <- state$filter_radius
  filter_cost <- state$filter_cost
  filter_duration <- state$filter_duration
  filter_tap <- state$filter_tap
  filter_cc <- state$filter_cc


}

#' Loads historical data for a given time
#' @return DataFrame of sensor data
load_historical_sensors <- function() {
  df <- load_remote("sensors_2019", params = list(
    "$where" = paste(
      "arrivaltime", "<=", "'2019-09-27T08:00:00.000'",
      "and",
      "departuretime", ">", "'2019-09-27T08:00:00.000'",
      sep = " "
    )
  )) %>%
  distinct(deviceid, .keep_all = TRUE)
  View(df)
  return(df)
}
