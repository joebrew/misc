# Inspiration and basic code from: 
#http://www.r-bloggers.com/google-location-data-where-ive-been/

# Download location history from google
# Get data from: https://www.google.com/settings/takeout
# Bottom of page

# Attach package to work with json files
library(rjson)

# Point to where the downloaded json is on system
json_file <- "C:/Users/BrewJR/Documents/misc/google_location/Historiald'ubicacions.json"

# Bring into R object (list)
json_data <- fromJSON(file = json_file)

# Convert to dataframe
latlong <- data.frame(do.call("rbind", json_data[[2]]))

# Get just latitude and longitude
latlong2 <- subset(latlong, select = c(latitudeE7, longitudeE7))

# Reformat latitude and longitude with decimals, etc.
latlong2$latR <- as.numeric(paste0(substr(as.character(latlong2$latitudeE7), 1, 2), 
                                   ".", substr(as.character(latlong2$latitudeE7), 3, 4)))
latlong2$longR <- as.numeric(paste0(substr(as.character(latlong2$longitudeE7), 1, 3), 
                                    ".", substr(as.character(latlong2$longitudeE7), 4, 5)))

# Get just my data
dat <- data.frame("lon" = latlong2$longR,
                  "lat" = latlong2$latR)

# Remove all the extra stuff
rm(latlong, latlong2, json_data, json_file, p)

# Plot the world
library(maps)
map("usa")

# Add points 
points(dat$lon,
       dat$lat,
       col = adjustcolor("red", alpha.f = 0.4),
       cex = 0.4,
       pch = 16)

