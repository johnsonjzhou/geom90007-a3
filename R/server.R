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

  # Handle incoming messages from Javascript
  observeEvent(input$search_result, {
    print(input$search_result)
  })
  
  # Toggle for displaying only free spaces
  observeEvent(input$filter_free, {
    state$filter_free <- input$filter_free
  })

  # Toggle for displaying only disability accessible spaces
  observeEvent(input$filter_accessible, {
    state$filter_accessible <- input$filter_accessible
  })

  # Range slider for distance from intended location
  observeEvent(input$filter_radius, {
    state$filter_radius <- input$filter_radius
  })

  # Cost filters
  observeEvent(input$filter_cost_min, {
    state$filter_cost <- c(input$filter_cost_min, input$filter_cost_max) * 100
  })

  observeEvent(input$filter_cost_max, {
    state$filter_cost <- c(input$filter_cost_min, input$filter_cost_max) * 100
  })

  # Duration filter with increment buttons
  observeEvent(input$filter_duration, {
    state$filter_duration <- input$filter_duration * 60
  })

  observeEvent(input$filter_duration_inc, {
    updateNumericInput(
      inputId = "filter_duration",
      value = input$filter_duration + 1
    )
  })

  observeEvent(input$filter_duration_dec, {
    updateNumericInput(
      inputId = "filter_duration",
      value = input$filter_duration - 1
    )
  })
  
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
  state$filter_free <- FALSE

  #' @param filter_accessible {bool} Filter for disabled access.
  state$filter_accessible <- FALSE

  #' @param filter_radius {c(min, max)} Distance range from specified location.
  state$filter_radius <- c(0.25, 0.5)

  #' @param filter_cost {c(min, max)} Filter for price range.
  state$filter_cost <- c(0, 200)

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
    # Apply filtered data to state
    state$filtered_data <- map_data(master_data, state)
  })

  #' Observe map zoom and update map symbol
  observe({
    leafletProxy("leaflet_map", data = state$filtered_data) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      leaflet::addMarkers(
        ~ longitude, ~ latitude,
        icon = ~ map_symbol_dynamic(
          input$leaflet_map_zoom, cost_per_hour, maximum_stay
        ),
        clusterOptions = leaflet::markerClusterOptions(
          disableClusteringAtZoom = 18,
          spiderfyOnMaxZoom = FALSE,
          removeOutsideVisibleBounds = TRUE
        ),
        clusterId = "clusters"
      )
  })

  #' Master data --------------------------------------------------------------
  master_data <- load_master_data_local()

  #' Mapping -----------------------------------------------------------------

  #' Render the world map in a leaflet widget
  output$leaflet_map <- renderLeaflet(
    map_renderer(state$filtered_data, state)
  )

  # Other app stuff-----------------------------------------------------------
  
  #' Function that displays information on user clicked
  #' marker
  observeEvent(input$leaflet_map_marker_click, {
    selected_marker <- state$filtered_data %>% filter(
      longitude == input$leaflet_map_marker_click$lng & 
      latitude == input$leaflet_map_marker_click$lat) %>%
      distinct(bay_id, .keep_all = TRUE)

    location <- ifelse(!is.na(selected_marker$street),
                       selected_marker$street, "-")
    disability <- ifelse(!is.na(selected_marker$disability_deviceid),
                         "disabled.svg", "")
    free <- ifelse(!is.na(selected_marker$cost_per_hour),
                      "", "free.svg")
    cost <- ifelse(!is.na(selected_marker$cost_per_hour),
                  sprintf("$%.2f", selected_marker$cost_per_hour / 100), "-")
    start_time <- ifelse(!is.na(selected_marker$start_time),
                         selected_marker$start_time, "-")
    end_time <- ifelse(!is.na(selected_marker$end_time),
                       selected_marker$end_time, "-")
    meter_type <- get_meter_type(selected_marker$maximum_stay)
    
    # Displays popup information panel
    shinyalert(
      title = "Bay Information",
      type = "info",
      html = TRUE,
      showConfirmButton = FALSE,
      closeOnClickOutside = TRUE,
      closeOnEsc = TRUE,
      text = paste0("Location: ", location, br(),
                    "Cost Per Hour: ", cost, br(),
                    "Start Time: ", start_time, br(),
                    "End Time: ", end_time, br(), br(),
                    tags$img(src = disability),
                    tags$img(src = free),
                    tags$img(src = meter_type)) 
    )
  })

  #' Calculates the number of hours that a car can be parked for
  #' @return type of parking meter
  get_meter_type <- function(maximum_stay_mins) {
    meter_hours <- maximum_stay_mins / 60
    meter_type <- case_when(
                    meter_hours == 1 ~ '1P.svg',
                    meter_hours == 2 ~ '2P.svg',
                    meter_hours == 3 ~ '3P.svg',
                    meter_hours == 4 ~ '4P.svg',
                    TRUE ~ 'P.svg'
                    )
    return(meter_type)
  }
}