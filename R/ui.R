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
    class = "row header",
    tags$h1(
      "Filters"
    ),
    actionButton(
      inputId = "filters_show_hide",
      label = "Show/Hide"
    )
  ),
  fluidRow(
    class = "row control",
    checkboxInput(
      inputId = "filter_free",
      label = "Show only free ($0) spots",
      value = FALSE
    )
  ),
  fluidRow(
    class = "row control",
    checkboxInput(
      inputId = "filter_accessible",
      label = "Show only disability-friendly spots",
      value = FALSE
    )
  ),
  fluidRow(
    class = "row control",
    tags$div(
      class = "label",
      "Radius"
    ),
    sliderInput(
      inputId = "filter_radius",
      min = 0,
      max = 1,
      step = 0.25,
      value = c(0.25, 0.5),
      dragRange = TRUE,
      label = "Radius"
    )
  ),
  fluidRow(
    class = "row control collapse",
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
    class = "row control collapse",
    tags$div(
      class = "label",
      "Parking duration"
    ),
    fluidRow(
      class = "row duration",
      actionButton(
        inputId = "filter_duration_dec",
        class = "stepwise",
        label = "-"
      ),
      numericInput(
        inputId = "filter_duration",
        label = "Duration",
        value = 3
      ),
      actionButton(
        inputId = "filter_duration_inc",
        class = "stepwise",
        label = "+"
      )
    ),
    tags$div(
      class = "label small",
      "hours"
    ),
  ),
  fluidRow(
    class = "row control",
    actionButton(
      inputId = "search",
      label = "Search"
    )
  )
)

# Dimmer Panel-----------------------------------------------------------------

dimmer_panel <- tabPanel(
  title = "Dimmer"
)

# Map Panel---------------------------------------------------------------------

map_panel <- tabPanel(
  title = "Map",
  leafletOutput(
    "leaflet_map",
    height = "100%", width = "100%"
  )
)

# Search Panel-----------------------------------------------------------------

search_panel <- tabPanel(
  title = "Search",
  fluidRow(
    class = "logo",
    tags$img(
      src = "logo.svg"
    )
  ),
  fluidRow(
    class = "search-bar",
    tags$div(
      class = "wrapper",
      textInput(
        inputId = "search-input",
        label = "NGV"
      ),
      tags$div(
        id = "button-gps",
        class = "button gps"
      ),
      tags$div(
        id = "button-search",
        class = "button search"
      )
    )
  )
)

# UI element-------------------------------------------------------------------

ui <- navbarPage(
  title = env$app_name,
  map_panel,
  search_panel,
  dimmer_panel,
  filter_panel,
  header = headers,
  windowTitle = env$app_name,
  fluid = FALSE,
  position = "fixed-top",
  lang = "en"
)
