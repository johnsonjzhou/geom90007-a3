################################################################################
# Deployment to shinyapps.io                                                   #
################################################################################

# Use or install rsconnect
tryCatch({
  library(rsconnect)
}, error = function(e) {
  install.packages("rsconnect", repos = "https://cloud.r-project.org")
})

# Deployment account particulars
deploy <- list(
  "account" = "CHANGEME",
  "token" = "CHANGEME",
  "secret" = "CHANGEME",
  "appName" = "parkit"
)

# Set account info
rsconnect::setAccountInfo(
  name = deploy$account,
  token = deploy$token,
  secret = deploy$secret
)

# Push the deployment
deployApp(
  appName = deploy$appName,
  account = deploy$account
)
