# Joe's code, but a lot borrowed from
# http://zevross.com/blog/2014/04/11/using-r-to-quickly-create-an-interactive-online-map-using-the-leafletr-package/

#####
# ATTACH LIBRARIES (some of these need to be installed from github, jcheng, ramnathv, etc.)
#####
library(leaflet)
library(RColorBrewer)
library(maps)
library(ggplot2)
library(rgdal)
library(leafletR)
library(rgeos) #for simplification
library(sp)
library(ggmap)

#####
# DIRECTORIES
#####
root <- "/home/joebrew/Documents/misc/leaflet_learn"
setwd(root)

#####
# READ AND TRANSFORM FLORIDA CHOROPLETH
#####

# Read in map
fl <- readOGR("counties", "FCTY2")

# convert to lat lon
fl <- spTransform(fl, CRS("+init=epsg:4326"))  

# get x and y centroids
fl$x_centroid <- coordinates(fl)[,1]
fl$y_centroid <- coordinates(fl)[,2]

# create dataframe version of polygon data
fl_df <- fortify(fl, region = "NAME")
each_county <- split(fl_df, fl_df$group)

#####
# ASSIGN THE VARIABLE WE WANT TO MAP
#####
fl$var <- fl@data[,"N3"]

#####
# SETUP SOME PARAMETERS FOR WHERE TO READ AND WRITE GEOJSON FILES
# AND DO
#####

download_dir<-paste0(getwd(), "/counties")
file_name <- list.files(download_dir, pattern=".shp", full.names=FALSE)
file_name <- gsub(".shp", "", file_name)

#  Write data to GeoJSON
leafdat <- paste(download_dir, "/", file_name, ".geojson", sep="") 
zipgj <- toGeoJSON(data = fl, dest = paste0(getwd(),"/output"))

#####
# ESTABLISH CHOROPLETH PARAMETERS
#####
#  Create the cuts
cuts<-round(quantile(fl$var, probs = seq(0, 1, 0.20), na.rm = FALSE), 0)
cuts[1] <- 0 #  for this example make first cut zero

#  Fields to include in the popup
popup <- c("NAME", "var")

#  Gradulated style based on an attribute
sty <- styleGrad(prop="var", breaks=cuts, right=FALSE, style.par="col",
               style.val=brewer.pal(5, "Reds"), leg="var", lwd=1)

#####
# CREATE LEAFLET CLASS MAP OBJECT
#####

#  Create the map and load into browser
map <- leaflet(data=zipgj, dest=download_dir, style=sty,
             title="index", base.map=c("mqsat", "osm", "tls", "mqosm", "toner", "water"), 
             incl.data=TRUE,  popup=popup)

#####
# VIEW MAP IN BROWSER
#####
browseURL(map)
