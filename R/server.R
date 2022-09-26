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
  state$ui_colors <- list(
    "background" = "#f5f3ec",
    "gray" = "#e7e5e6",
    "darkgray" = "#79757d",
    "foreground" = "#1a1b19"
  )
  state$fonts <- list(
    "primary" = "'League Spartan', 'Helvetica', 'Arial', sans-serif",
    "secondary" = "'Inter', 'Helvetica', 'Arial', sans-serif",
    "monospace" = "'JetBrains Mono', monospace"
  )

  #' Observe states
  observe({
    # states to observe
  })

  # Other app stuff-----------------------------------------------------------

}