# Assignment 3 GEOM90007 Information Visualisation

## Run App

### Install dependencies
```R
source("./R/libraries.R")
```

### Running the Shiny App
```R
# ./app.R
shiny::shinyApp(ui, server)
```

### Running the Shiny App silently
```R
shiny::runApp(launch.browser = FALSE)
```

## Building

### Directory tree
```
root
  |- data: data sources for the dash board
  |- doc: documentation
  |- R: supporting R scripts for the app
  |- src: supporting non-R source files and assets
  |- www: production non-R files and assets for use by the app
```

### Building supporting (non-R) source files (optional)
Non-R source files are built using `webpack`, 
transforming from `./src` to `./www`.  
```bash
# install node module
npm install

# build
npm run build
```