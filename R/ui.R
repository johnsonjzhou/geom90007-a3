################################################################################
# UI components for the dashboard                                              #
################################################################################
library(shiny)
library(glue)
library(htmltools)

# Headers----------------------------------------------------------------------

headers <- tags$head(
  # web fonts
  #! update this
  tags$link(
    rel = "stylesheet", type = "text/css",
    href = paste0(
      "https://fonts.googleapis.com/css2?",
      "family=Inter:wght@400;500;600",
      "&family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;1,400;1,500;1,600",
      "&family=League+Spartan:wght@500;600",
      "&family=PT+Serif:ital,wght@0,400;0,700;1,400",
      "&display=swap"
    )
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

# Map Panel---------------------------------------------------------------------

# map_panel <- tabPanel(
#   title = "Map",
#   leafletOutput(
#     "leaflet_map",
#     height = "100%", width = "100%"
#   )
# )

# UI element-------------------------------------------------------------------

ui <- navbarPage(
  title = env$app_name,
  # map_panel,
  header = headers,
  windowTitle = env$app_name,
  fluid = FALSE,
  position = "fixed-top",
  lang = "en"
)
