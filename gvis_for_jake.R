#####
# ATTACH (AND INSTALL, IF REQUIRED) PACKAGES
#####
library(RCurl)
library(googleVis)

#####
# READ IN ALACHUA COUNTY'S "CONTROL FLU" DATA, AND NAME DAT
#####
my_link <- "https://docs.google.com/spreadsheets/d/1icEDpqkJVNuvGLV6GcULuvfVK0healPyPep3enHkceE/export?gid=0&format=csv"
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
my_csv <- getURL(my_link)
dat <- read.csv(textConnection(my_csv)); rm(my_csv, my_link)

#####
# EXPLORE THE DATA 
#####
head(dat)
summary(dat)
plot(dat)
# Note that this is the kind of format you'll need:
# - some sort of id column {in this case "id", which is equivalent to school}
# - some sort of time column (year, day, date, etc.) {in this case, year}
# - some sort of value column {in this case, immunization rate}

#####
# SET UP THE PARAMETERS FOR THE MOTION CHART
# AND NAME THE RESULTING OBJECT "X"
#####
x <- gvisMotionChart(data = dat, 
                     idvar="id", 
                     timevar="year",
                     xvar = "frLunch13", # Percent of kids on free/reduced lunch
                     yvar = "immRate", # Immunization rate
                     colorvar = "type", # elem / middle / high
                     sizevar = "totMem") # total number of enrolled student

#####
# PLOT THE MOTION CHART IN YOUR DEFAULT BROWSER
#####
plot(x)