################################################################################
# UI components for the dashboard                                              #
################################################################################
library(shiny)
library(glue)
library(htmltools)

# Headers----------------------------------------------------------------------

headers <- tags$head(
  # web fonts
  tags$link(
    rel = "stylesheet", type = "text/css",
    href = "https://use.typekit.net/zvh8ynu.css"
  ),
  tags$link(
    rel = "stylesheet", type = "text/css",
    href = "https://fonts.googleapis.com/icon?family=Material+Icons"
  ),
  # css overrides
  tags$link(
    rel = "stylesheet", type = "text/css",
    href = "shiny_app.css"
  ),
  # javascript
  tags$script(
    src = "shiny_app.js"
  )
)

# Filter Panel-----------------------------------------------------------------

filter_panel <- tabPanel(
  title = "Filters",
  fluidRow(
    class = "header-row",
    tags$h1(
      "Filters"
    ),
    actionButton(
      inputId = "filters_show_hide",
      label = "Show/Hide"
    )
  ),
  fluidRow(
    class = "control-row",
    checkboxInput(
      inputId = "filter_free",
      label = "Show only free ($0) spots"
    )
  ),
  fluidRow(
    class = "control-row",
    checkboxInput(
      inputId = "filter_accessible",
      label = "Show only disability-friendly spots"
    )
  ),
  fluidRow(
    class = "control-row",
    tags$div(
      class = "label",
      "Radius"
    ),
    sliderInput(
      inputId = "filter_duration",
      min = 0,
      max = 1000,
      step = 250,
      value = 250,
      dragRange = TRUE,
      label = "Cost"
    )
  ),
  fluidRow(
    class = "control-row cost",
    tags$div(
      class = "label",
      "Cost"
    ),
    numericInput(
      inputId = "filter_cost_min",
      label = "min",
      value = 0
    ),
    numericInput(
      inputId = "filter_cost_max",
      label = "max",
      value = 2
    )
  ),
  fluidRow(
    class = "control-row duration",
    tags$div(
      class = "label",
      "Parking duration"
    ),
    actionButton(
      inputId = "filter_duration_dec",
      label = "-"
    ),
    numericInput(
      inputId = "filter_duration",
      label = "Duration",
      value = 2
    ),
    actionButton(
      inputId = "filter_duration_inc",
      label = "+"
    )
  ),
  fluidRow(
    class = "control-row",
    actionButton(
      inputId = "search",
      label = "Search"
    )
  )
)

# Map Panel---------------------------------------------------------------------

map_panel <- tabPanel(
  title = "Map",
  leafletOutput(
    "leaflet_map",
    height = "100%", width = "100%"
  )
)

# UI element-------------------------------------------------------------------

ui <- navbarPage(
  title = env$app_name,
  map_panel,
  filter_panel,
  header = headers,
  windowTitle = env$app_name,
  fluid = FALSE,
  position = "fixed-top",
  lang = "en"
)
