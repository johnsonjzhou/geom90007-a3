# App dependencies-------------------------------------------------------------
# Please run the following to ensure dependencies are installed
source("./R/libraries.R")

# Data-------------------------------------------------------------------------
source("./R/data.R")

# Mapping----------------------------------------------------------------------
source("./R/map.R")


# Define the Shiny app
shiny::shinyApp(ui, server)
