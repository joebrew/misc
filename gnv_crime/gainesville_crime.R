setwd("C:/Users/BrewJR/Documents/misc") # change this line to whereever you cloned misc
setwd("gnv_crime")

# define the link for gainesville crime
my_link1 <- "https://data.cityofgainesville.org/api/views/9ccb-cyth/rows.csv"

# read in the data
gnv <- read.csv(my_link1)

# write a function to clean lat lon points
DegreesToDecimals <- function(x){
  
  # split the string to keep only the lat, lon, part
  a <- do.call(rbind, strsplit(as.character(x), "\n"))
  aa <- a[,3]
  
    # now split at the comma
    b <- do.call(rbind, strsplit(as.character(aa), ","))
    bb <- b#[,2]
  
  # make df
  bb <- data.frame(bb)
  
  # fix names
  names(bb) <- c("lat", "lon")
  
  # remove parentheses
  bb$lat <- as.numeric(gsub("\\(|\\)", "", bb$lat))
  bb$lon <- as.numeric(gsub("\\(|\\)", "", bb$lon))
  
  return(bb)
}
x <- DegreesToDecimals(gnv$Location.1)
# now join x to gnv
gnv <- cbind(gnv, x)
rm(x)

# plot the points on a florida map
library(maps)
map("county", "florida")
points(gnv$lon, gnv$lat, col = "red")

# Plot the points on an Alachua map
library(rgdal)
library(sp)
zip <- readOGR("zips_alachua", "ACDPS_zipcode")
zip <- spTransform(zip, CRS("+init=epsg:4326"))
plot(zip, col = "grey", border = "white")

points(gnv$lon, gnv$lat,
       col = adjustcolor(rainbow(nrow(gnv)), alpha.f = 0.3),
       pch = 16,
       cex = 0.3)

# Color by crime type ("Narrative")
library(RColorBrewer)
my_colors <- colorRampPalette(brewer.pal(3, "Spectral"))(length(levels(gnv$Narrative)))
barplot(summary(gnv$Narrative), col = my_colors, border = FALSE)

gnv$col <- my_colors[as.numeric(gnv$Narrative)]
plot(zip, col = "grey", border = "white")

points(gnv$lon, gnv$lat,
       col = adjustcolor(gnv$col, alpha.f = 0.5),
       pch = 16,
       cex = 0.5)

# PLOT WITH GOOGLE
library(googleVis)
n_rows <- 100
goo_loc <- paste(gnv$lat[1:n_rows], gnv$lon[1:n_rows], sep = ":")
goo_gnv <- data.frame(gnv[1:n_rows,], goo_loc)
g.inter.map <- gvisMap(data = goo_gnv, 
                       locationvar = "goo_loc",
                       options=list(showTip=TRUE, 
                                    showLine=TRUE, 
                                    enableScrollWheel=TRUE,
                                    mapType='hybrid', 
                                    useMapTypeControl=TRUE,
                                    width=800,
                                    height=400),
                       tipvar = "Narrative")
plot(g.inter.map)

# PLOT WITH LEAFLET / rCHARTS
#library(devtools)
#install_github("rCharts", "ramnathv")

library(rCharts)

# read in geojson version of zip
zip_geoj <- readOGR("zips_alachua", "ACDPS_zipcode")
mymap <- Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(29.55, -82.12), zoom = 10)
mymap$enablePopover(TRUE)
mymap$geoJson(zip_geoj)
#mymap$fullScreen(TRUE)

for (i in 1:100){
  mymap$marker(c(gnv$lat[i], gnv$lon[i]),
               bindPopup = paste(gnv$Narrative[i],
                                 gnv$Offense.Date[i]))
  
}

mymap

# Clean up zip code stuff to add to it

# give better variable name
zip$pop <- zip$POP1996

# create a df version of zip
zip_df <- data.frame(zip)

# simplify to spatial polygons class
library(leafletR)
library(rgdal) #for reading/writing geo files
library(rgeos) #for simplification
library(sp)

# note that this file is somewhat big so it might take a couple
# of minutes to download
#url<-"http://www2.census.gov/geo/tiger/TIGER2010DP1/County_2010Census_DP1.zip"
downloaddir<-paste0(getwd(), "/zips_alachua" )

filename<-list.files(downloaddir, pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename)

# ----- Change zip to dat
dat <- zip

# ----- Create a subset of New York counties
subdat<- dat

# ----- Transform to EPSG 4326 - WGS84 (required)
subdat<-spTransform(subdat, CRS("+init=epsg:4326"))

# ----- change name of field we will map
names(subdat)[names(subdat) == "POP1996"]<-"Population"

# # ----- save the data slot
subdat_data<- subdat@data

# ----- simplification yields a SpatialPolygons class
subdat<-gSimplify(subdat,tol=0.01, topologyPreserve=TRUE)

# ----- to write to geojson we need a SpatialPolygonsDataFrame
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)



# ----- Write data to GeoJSON
leafdat<-paste(downloaddir, "/", filename, ".geojson", sep="") 

# ------ Function to write to GeoJSON
togeojson <- function(file, writepath = "~") {
  url <- "http://ogre.adc4gis.com/convert"
  tt <- POST(url, body = list(upload = upload_file(file)))
  out <- content(tt, as = "text")
  fileConn <- file(writepath)
  writeLines(out, fileConn)
  close(fileConn)
}

library(httr)
file <- paste0(getwd(), "/zips_alachua/", "ACDPS_zipcode.zip")
togeojson(file, leafdat)


# ----- Create the cuts
cuts<-round(quantile(subdat$Population, probs = seq(0, 1, 0.20), na.rm = FALSE), 0)
cuts[1]<-0 # ----- for this example make first cut zero


# ----- Fields to include in the popup
popup<-c("ZIP", "Population")


# ----- Gradulated style based on an attribute
sty<-styleGrad(prop="Population", breaks=cuts, right=FALSE, style.par="col",
               style.val=rev(heat.colors(6)), leg="Population", lwd=1)


# ----- Create the map and load into browser
map<-leaflet(data=leafdat, dest=downloaddir, style=sty,
             title="index", base.map="osm",
             incl.data=TRUE,  popup=popup)

# ----- to look at the map you can use this code
browseURL(map)
