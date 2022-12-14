################################################################################
# Maps for the app                                                             #
################################################################################
library(dplyr)
library(leaflet)
library(htmltools)
library(glue)

# Map definition---------------------------------------------------------------

#' Generates a symbol to indicate a parking bay
#' @param type Either filled or unfilled
#' @param zoom the map zoom level
#' @return icon
map_symbol <- function(type = "filled", zoom = 1) {
  img <- case_when(
    type == "filled" ~ "./www/filled.svg",
    type == "unfilled" ~ "./www/unfilled.svg",
    type == "placeholder" ~ "./www/placeholder.svg",
    type == "marker" ~ "./www/marker.svg",
    type == "pin" ~ "./www/pin.png",
    type == "pos_1" ~ "./www/pos_1.svg",
    type == "pos_2" ~ "./www/pos_2.svg"
  )
  size <- 24
  icon <- makeIcon(img, NULL, size, size, className = glue("marker {type}"))
  return(icon)
}

#' Generates a symbol to indicate a parking bay
#' @param type Either filled or unfilled
#' @param zoom the map zoom level
#' @return icon
map_symbol_dynamic <- function(zoom, cost_per_hour, maximum_stay) {
  # Type of icon prefix to the src file
  type <- case_when(
    (zoom <= 18) ~ "filled",
    (zoom > 18) & (maximum_stay == 60) ~ "1P",
    (zoom > 18) & (maximum_stay == 120) ~ "2P",
    (zoom > 18) & (maximum_stay == 180) ~ "3P",
    (zoom > 18) & (maximum_stay == 240) ~ "4P",
    TRUE ~ "P"
  )

  # Color of icon suffix to the src file
  color <- case_when(
    is.na(cost_per_hour) ~ "_green",
    (cost_per_hour == 0) ~ "_green",
    TRUE ~ ""
  )

  # Combine to create the src file path
  img <- paste0("./www/", type, color, ".svg")

  size <- ifelse(zoom <= 18, 14, 20)
  icon <- makeIcon(img, NULL, size, size, className = glue("marker"))
  return(icon)
}

#' Handles leaflet rendering functions for the world map
#' @param map_data the dataset for the world map with spacial information
#' @param state the reactive "state" object
#' @return a leaflet widget
map_renderer <- function(map_data, state) {
  # Unpack state parameters
  filter_radius <- state$filter_radius

  # Mapbox template location
  mapbox_template <- paste0(
    "https://api.mapbox.com/styles/v1/bringmerocks/",
    "cl6sz4cs5002k14nx3w26n0jq",
    "/tiles/{z}/{x}/{y}",
    "?access_token=",
    "pk.eyJ1IjoiYnJpbmdtZXJvY2tzIiwiYSI6ImNsNmo0dzdiMDNkMHYzanFzY3lkeHZvbGQifQ",
    ".fEx-BQJvdzz_J4-XIWazbw"
  )

  map <- map_data %>%
    # Initialise leaflet
    leaflet::leaflet(
      options = leaflet::leafletOptions(
        minZoom = 15,
        maxZoom = 20,
      ),
      sizingPolicy = leaflet::leafletSizingPolicy(
        defaultWidth = "100%",
        defaultHeight = "100%"
      )
    ) %>%
    # Add Mapbox tile
    leaflet::addTiles(
      urlTemplate = mapbox_template,
      #todo attribution =
      options = tileOptions(
        minZoom = 15,
        maxZoom = 20,
        maxNativeZoom = 20
      )
    ) %>%
    # Add Marker Layer
    leaflet::addMarkers(
      ~ longitude, ~ latitude,
      icon = map_symbol("filled"),
      clusterOptions = leaflet::markerClusterOptions(
        disableClusteringAtZoom = 18,
        spiderfyOnMaxZoom = FALSE,
        removeOutsideVisibleBounds = TRUE
      ),
      clusterId = "clusters"
    ) %>%
    # Add Radar Layer
    leaflet::addCircles(
    lat = state$filter_loc[1],
    lng = state$filter_loc[2],
    radius = unlist(state$radar_info[1]),
    color = "#61D095",
    fillOpacity = unlist(state$radar_info[2]),
    weight = 0.2,
    stroke = TRUE
    ) %>%
    #todo Add legend for custom symbols
    # addControl(
    #   position = "topright",
    #   html = map_symbol_legend()
    # ) %>%
    # Add Reference Scale
    leaflet::addScaleBar(
      position = "bottomleft",
      options = scaleBarOptions(
        metric = TRUE,
        imperial = FALSE
      )
    ) %>%
    # North arrow
    leaflet::addControl(
      html = htmltools::tags$img(width = 36, height = 36, src = "north.svg"),
      position = "bottomright",
      className = "leaflet-control-north-arrow "
    )
  return(map)
}