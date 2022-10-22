################################################################################
# UI components for the dashboard                                              #
################################################################################
library(shiny)
library(glue)
library(htmltools)

# Headers----------------------------------------------------------------------

headers <- tags$head(
  # favicon
  tags$link(
    rel = "icon", type = "image/x-icon",
    href = "favicon.svg"
  ),
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
    class = "header",
    tags$h1(
      "Filters"
    ),
    tags$div(
      id = "filters-show-hide",
      class = "button-show",
    )
  ),
  tags$div(class = "spacer h32"),
  fluidRow(
    class = "control",
    checkboxInput(
      inputId = "filter_free",
      label = "Show only free ($0) spots",
      value = FALSE
    )
  ),
  fluidRow(
    class = "control",
    checkboxInput(
      inputId = "filter_accessible",
      label = "Show only disability-friendly spots",
      value = FALSE
    )
  ),
  tags$div(class = "spacer h32"),
  fluidRow(
    class = "control",
    tags$div(
      class = "label",
      "Radius"
    ),
    sliderInput(
      inputId = "filter_radius",
      min = 0,
      max = 1,
      step = 0.25,
      value = c(0, 1),
      dragRange = TRUE,
      label = NULL,
      post = "km"
    )
  ),
  tags$div(class = "spacer h32"),
  fluidRow(
    class = "control input-small cost",
    tags$div(
      class = "label",
      "Cost per hour"
    ),
    numericInput(
      inputId = "filter_cost_min",
      label = "min",
      value = 0
    ),
    tags$hr(
      class = "accent-connect"
    ),
    numericInput(
      inputId = "filter_cost_max",
      label = "max",
      value = 6
    )
  ),
  tags$div(class = "spacer h32"),
  fluidRow(
    class = "control input-small hide-label",
    tags$div(
      class = "label",
      "Parking duration"
    ),
    fluidRow(
      class = "w-150",
      actionButton(
        inputId = "filter_duration_dec",
        class = "stepwise",
        label = "-"
      ),
      numericInput(
        inputId = "filter_duration",
        label = "hours",
        value = 2
      ),
      actionButton(
        inputId = "filter_duration_inc",
        class = "stepwise",
        label = "+"
      )
    ),
    # tags$div(
    #   class = "label small",
    #   "hours"
    # ),
  ),
  tags$div(class = "spacer h32"),
  # fluidRow(
  #   class = "control v-collapse-bottom",
  #   actionButton(
  #     inputId = "search",
  #     label = "Search"
  #   )
  # )
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
        label = "NGV",
        placeholder = "Search Destination"
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

search_results_panel <- tabPanel(
  title = "SearchResults"
)

# Intro panel------------------------------------------------------------------

intro_panel <- tabPanel(
  title = "Intro",
  class = "page-1",
  tags$img(class = "logo", src = "./logo.svg"),
  tags$div(
    class = "pages",
    tags$div(
      class = "page",
      tags$img(src = "./parking_area.svg"),
      tags$p("Access parking spot availability in Melbourne in real-time.")
    ),
    tags$div(
      class = "page",
      tags$img(src = "./location.svg"),
      tags$p(
        "Find spots near your location, filter by how much you want to walk."
      )
    ),
    tags$div(
      class = "page",
      tags$img(src = "./city.svg"),
      tags$p(
        "It just got easier to live in the most liveable city in the world."
      )
    )
  ),
  tags$div(class = "bubble one"),
  tags$div(class = "bubble two"),
  tags$div(
    class = "dots",
    tags$div(class = "dot seq-1"),
    tags$div(class = "dot seq-2"),
    tags$div(class = "dot seq-3")
  ),
  tags$div(
    id = "intro-left",
    class = "button left",
    direction = "left"
  ),
  tags$div(
    id = "intro-right",
    class = "button right",
    direction = "right"
  ),
)

# Loading panel----------------------------------------------------------------

loading_panel <- tabPanel(
  title = "Loading",
  class = "container",
  tags$div(
    class = "pulse"
  )
)

# UI element-------------------------------------------------------------------

ui <- navbarPage(
  title = "ParkIt",
  map_panel,
  search_panel,
  search_results_panel,
  dimmer_panel,
  loading_panel,
  filter_panel,
  intro_panel,
  header = headers,
  windowTitle = "ParkIt",
  fluid = FALSE,
  position = "fixed-top",
  lang = "en"
)
