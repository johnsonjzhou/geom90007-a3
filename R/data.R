################################################################################
# Data handlers for the app                                                    #
################################################################################
library(jsonlite)
library(dplyr)
library(RSocrata)
library(glue)
library(tidyr)
library(stringr)
library(geojsonio)
library(rgeos)
library(pracma)

#' Load data from json
#' @param filename the filename for the file to be loaded
#' @param ... additional parameters to pass to jsonlite::fromJSON
#' @return dataframe
load_json <- function(filename, ...) {
  df <- jsonlite::fromJSON(txt = filename, flatten = TRUE)
  print(glue("Loaded dataframe with {nrow(df)} rows"))
  return(df)
}

#' Load data from a geojson spatial file
#' @param filename the filename for the file to be loaded
#' @param ... additional parameters to pass to geojsonio::geojson_read
#' @return spatial dataframe
load_geojson <- function(filename, ...) {
  sp_df <- geojsonio::geojson_read(filename, what = "sp")
  print(glue("Loaded spatial dataframe with {nrow(sp_df)} rows"))
  return(sp_df)
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
#' @note This is currently not in use, use load_master_data_local instead.
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

#' Loads all the required data and performs the necessary joins
#' @returns Dataframe containing an entire set of required data
load_master_data_local <- function() {
  #' @section City of Melbourne parking datasets -----------------------------

  # On-street parking bay sensors
  # sensors should be 2-min live, but is currently disrupted, thus static
  # Using archived data from 27-09-2019 0800
  sensors <- load_json("./data/sensors_2019_09_27_0800.json") %>%
    # rename key bayid to bay_id for consistency
    rename(bay_id = bayid, occupied_id = deviceid) %>%
    # select the required info
    select(c(bay_id, occupied_id))

  # On-street parking bays
  bays_sp <- load_geojson("./data/bays.geojson")
  # Calculate the centroids from the spatial data
  bay_centroids <- rgeos::gCentroid(bays_sp, byid = TRUE)
  # Extract the dataframe from the spatial dataframe
  # Assign the longitude, latitude from the calculated centroids
  bays <- bays_sp@data %>% mutate(
    longitude = bay_centroids@coords[, 1],
    latitude = bay_centroids@coords[, 2]
  )

  # On-street car park bay restrictions
  disability <- load_json("./data/restrictions_disability_only.json") %>%
    # rename key bayid to bay_id for consistency
    rename(bay_id = bayid, disability_deviceid = deviceid) %>%
    select(c(bay_id, disability_deviceid))



  #' @section Paystay datasets -----------------------------------------------

  # Pay Stay parking restrictions
  paystay_restrictions <- load_json(
    "./data/paystay_restrictions_fri_0800.json"
  ) %>%
  mutate_at(c("cost_per_hour", "maximum_stay"), as.numeric)

  # Pay Stay zones linked to street segments
  paystay_segments <- load_json("./data/paystay_segments.json") %>%
    # rename the foreign key street_segment_id to rd_segment_id
    # for consistency
    rename(rd_seg_id = street_segment_id) 

  df <- bays %>%
    left_join(sensors, by = "bay_id") %>%
    left_join(disability, by = "bay_id") %>%
    left_join(paystay_segments, by = "rd_seg_id") %>%
    left_join(paystay_restrictions, by = "pay_stay_zone") 

  #' @debug
  # View(df)

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
  filter_loc <- state$filter_loc

  # Filter master_data
  filtered <- master_data %>%
    # Calculate the distance from the focus location
    rowwise() %>%
    mutate(
      distance = pracma::haversine(c(latitude, longitude), filter_loc)
    ) %>%
    # Select points residing within the filter_radius
    filter(
      distance >= filter_radius[1] &
      distance <= filter_radius[2]
    ) %>%
    # Select points that satisfies the cost filter
    # If cost_per_hour is NA, means the bay is Free
    filter(
      is.na(cost_per_hour) |
      (
        cost_per_hour >= filter_cost[1] &
        cost_per_hour <= filter_cost[2]
      )
    ) %>%
    # Select points that exceeds the duration filter
    # If maximum_stay is NA, means no time restrictions apply
    filter(
      is.na(maximum_stay) |
      maximum_stay > filter_duration
    )

  # If required, display points only if they are not occupied
  if (filter_free) {
    filtered <- filtered %>% filter(is.na(occupied_id))
  }

  # If required, display points only if they are disability accessible
  if (filter_accessible) {
    filtered <- filtered %>% filter(!is.na(disability_deviceid))
  }

  # Return only unique bays (remove any duplicates)
  filtered <- filtered %>%
    distinct(bay_id, .keep_all = TRUE)

  #' @debug
  View(filtered)

  return(filtered)
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
