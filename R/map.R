################################################################################
# Maps for the app                                                             #
################################################################################
library(dplyr)
library(leaflet)
library(htmltools)

# Map definition---------------------------------------------------------------

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
        # minZoom = 3,
        # maxZoom = 6
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
    ) %>%
    #todo Add Marker Layer
    leaflet::addMarkers(
      ~ longitude, ~ latitude,
      # icon =
      # label =
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