################################################################################
# Data handlers for the app                                                    #
################################################################################
library(jsonlite)
library(dplyr)

sensors <- jsonlite::fromJSON(
  txt = "./data/2022-10-08-11-58 realtime.json",
  flatten = TRUE
)

sensors_2 <- jsonlite::fromJSON(
  txt = "./data/2022-10-08-12-13 realtime.json",
  flatten = TRUE
)

sensors_unocc <- before %>%
  group_by(status) %>%
  summarise(n = n())

View(sensors_unocc)

sensors_2_unocc <- before %>%
  group_by(status) %>%
  summarise(n = n())

View(sensors_2_unocc)
