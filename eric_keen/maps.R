##############
# Use OpenStreetMaps to make cool maps
##############
# library(maps)
# library(mapdata)
# library(maptools) 
# library(rJava)
# library(rgdal)

# Install and attach the OpenStreetMap package
install.packages("OpenStreetMap")
library(OpenStreetMap)

# Define the centrid for a watercolor map of Gainesville
wc <- openmap(c(29.9, -82.65), c(29.4,-82.0),
                         type="stamen-watercolor")

# Give it a projection
wc2 <- openproj(wc, projection = "+proj=longlat")

# Plot the map
plot(wc2, raster=TRUE)

# For another example, let's zoom out, and change the map type
bw <- openmap(c(60, -90), c(0, 0),
              type="stamen-toner")
bw2 <- openproj(bw, projection = "+proj=longlat")
plot(bw2)

# Final example - terrain map of sewanee area
tw <- openmap(c(35.3, -86.15), c(35.1, -85.8),
              type="stamen-terrain")
tw2 <- openproj(tw, projection = "+proj=longlat")
plot(tw2)

# Note that you can add points to these maps using base R
# Here I'll add a red point at Sewanee
points(x = -85.9214,
       y = 35.2011,
       pch = 16, 
       col = adjustcolor("darkred", alpha.f = 0.6))

##############
# Use rCharts / leaflet to make interactive maps
###############
# To get this package, you'll need to install and attach devtools first...
install.packages("devtools")
library(devtools)

# Then install the rCharts package directly from github
install_github('ramnathv/rCharts')

# Attach the rCharts package
library(rCharts)

# Set some parameters for the map
mymap <- Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(47.6097, -122.3331), zoom = 7)
mymap$enablePopover(TRUE)

# Show the map! (you can zoom in, out, etc.)
mymap

# Add some markers to the map (first randomly creating some points)
lat <- jitter(rep(47.6, 100), factor = 10)
lon <- jitter(rep(-122.3331, 100), factor = 10)
location_names <- sample(c("poop", "pee", "fart", "dookie", "eric"), 100, replace = TRUE)

# Redraw a map
mymap <- Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(47.6097, -122.3331), zoom = 3)
mymap$enablePopover(TRUE)


# Loop through each point to make the market
for (i in 1:100){
  mymap$marker(c(lat[i], lon[i]),
               bindPopup = paste(location_names[i]))
  
}

# Draw the map with points
mymap

# note that you can zoom in and out, and
# also click on a point to see its label

##############
# Use google maps
###############

# Install and attach the googleVis package
install.packages("googleVis")
library(googleVis)

# Define some random points
goo_loc <- paste(lat, lon, sep = ":")

# Bind our locations and labels into one dataframe
mydf <- data.frame(lat, lon, goo_loc, location_names)
g.inter.map <- gvisMap(data = mydf, 
                       locationvar = "goo_loc",
                       options=list(showTip=TRUE, 
                                    showLine=TRUE, 
                                    enableScrollWheel=TRUE,
                                    mapType='hybrid', 
                                    useMapTypeControl=TRUE,
                                    width=800,
                                    height=400),
                       tipvar = "location_names")

# Show the map in your browser. 
# Note that you can zoom in, and click to see each points' labels
plot(g.inter.map)


##############
# R's maps package has some really easy-to-use stuff
###############
library(maps)
map("county", "fl")

map("county")

map("state")

##############
# Finally, check out gadm.org for RData files already loaded up with geo stuff!
###############

#I've download a US one here
# setwd("C:/Users/BrewJR/Documents/misc/eric_keen")
load("usa_map_from_gadm.RData")
usa <- gadm
rm(gadm)

load("indonesia_map_from_gadm.RData")
indo <- gadm
rm(gadm)

# Plot usa
plot(usa, col = rainbow(nrow(usa)),
     border = FALSE)

# Plot Indoensia
plot(indo, col = rainbow(nrow(indo)),
     border = FALSE)
