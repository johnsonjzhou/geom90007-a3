# ParkIt

Assignment 3 GEOM90007 Information Visualisation at the University of Melbourne.  

Live demo is available at:  
[https://johnsonzhou.shinyapps.io/parkit/](https://johnsonzhou.shinyapps.io/parkit/)

![screenshot](/doc/ParkIt.gif)

---
## Run App

> This app uses CSS style that are not supported by the built-in browser of RStudio. For best experience, please use an external (modern) browser.

### Install dependencies
```R
source("./R/libraries.R")
```

### Running the Shiny App
```R
# At the root project directory
shiny::runApp()
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

### Deployment to shinyapps.io
Use script `deploy.R` and ensuring to change the following parameters:
```R
deploy <- list(
  "account" = "CHANGEME",
  "token" = "CHANGEME",
  "secret" = "CHANGEME",
  "appName" = "parkit"
)
```