################################################################################
# Server components for the dashboard                                          #
################################################################################
library(dplyr)
library(shiny)
library(leaflet)
library(plotly)

#' The server function to pass to the shiny dashboard
server <- function(input, output, session) {
  #' Event handlers ----------------------------------------------------------

  # Event handling template
  # observeEvent(input${handler}, {
  #   session$sendCustomMessage(type = "event_name", message = "message")
  # })

  #' State -------------------------------------------------------------------

  #' Reactive states and settable defaults
  state <- reactiveValues()

  #' @param ui_colors {list} List of colors used in the app.
  state$ui_colors <- list(
    "background" = "#FFFFFF",
    "lightgray" = "#E9E9EA",
    "gray" = "#A8A8B5",
    "darkgray" = "#949598",
    "foreground" = "#52525F",
    "accent" = "#3465E5",
    "highlight" = "#61D095"
  )

  #' @param fonts {list} List of fonts used in the app.
  state$fonts <- list(
    "primary" = "'brandon-grotesque', 'Helvetica', 'Arial', sans-serif"
    # "secondary" = "'Inter', 'Helvetica', 'Arial', sans-serif",
    # "monospace" = "'JetBrains Mono', monospace"
  )

  #' @param filter_free {bool} Filter for free parking.
  state$filter_free <- TRUE

  #' @param filter_accessible {bool} Filter for disabled access.
  state$filter_accessible <- FALSE

  #' @param filter_radius {c(min, max)} Distance range from specified location.
  state$filter_radius <- c(0, 0.4)

  #' @param filter_cost {c(min, max)} Filter for price range.
  state$filter_cost <- c(0, 120)

  #' @param filter_duration {integer} Filter for parking duration.
  state$filter_duration <- 180

  #' @param filter_tap {bool} Filter for tap and go payment method.
  state$filter_tap <- FALSE

  #' @param filter_cc {bool} Filter for credit cards payment method.
  state$filter_cc <- FALSE

  #' @param loc {c(lat, lon)} The focus location, default NGV
  state$filter_loc <- c(-37.822477, 144.969162)

  #' @param loc_search_name {character} The name of the search location.
  state$loc_search_name <- ""

  #' @param loc_search_term {character} The search term as input by the user.
  state$loc_search_term <- ""

  #' Observe states
  observe({
    # states to observe
  })

  #' Master data --------------------------------------------------------------
  master_data <- load_master_data_local()

  #' Mapping -----------------------------------------------------------------

  #' Filter map data based on context
  map_data_filter <- reactive({
    spatial_df <- map_data(state$map_context)
    return(spatial_df)
  })

  #' Render the world map in a leaflet widget
  output$leaflet_map <- renderLeaflet(
    map_renderer(map_data(master_data, state), state)
  )

  # Other app stuff-----------------------------------------------------------

}