library(RCurl)
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

#########
# SET LOCAL WORKING DIRECTORY
#########
#setwd("C:/Users/BrewJR/Documents/misc") # change this line to whereever you cloned misc
setwd("/home/joebrew/Documents/misc/")
setwd("gnv_crime")


#########
# READ IN GAINESVILLE CRIME DATA
#########
# # define the link for gainesville crime
# my_link1 <- 'https://data.cityofgainesville.org/api/views/gvua-xt9q/rows.csv?accessType=DOWNLOAD'
# my_link2 <- getURL(my_link1)
# 
# # read in the data
# gnv <- read.csv(my_link2)

gnv <- read.csv("april1.csv")

#########
# CLEAN IT UP A BIT
#########
# write a function to clean lat lon points
clean_up <- function(x){
  
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
x <- clean_up(gnv$location)
# now join x to gnv
gnv <- cbind(gnv, x)
rm(x)

# Make a date column
gnv$date <- as.Date(substr(gnv$offense_date,1,10), format = "%m/%d/%Y")

# view it
hist(gnv$date, breaks = 100)

# Remove dates prior to 2013
gnv <- gnv[which(gnv$date > "2013-01-01"),]
hist(gnv$date, breaks = 100)

#####
# GROUP BY DATES
#####
library(dplyr)
gnv_agg <- gnv %>%
  group_by(date) %>%
  summarise(n = n())
all_dates <- data.frame(date = seq(min(gnv_agg$date),
                                   max(gnv_agg$date),
                                   1))
gnv_agg <- left_join(all_dates, gnv_agg)

plot(gnv_agg$date, gnv_agg$n)

#####
# FUNCTION TO SUBSET BY NARRATIVE
##### 
crime <- function(narrative = 'ROBBERY',
                  ts = FALSE){
  
  
  sub_data <- gnv[which(grepl(narrative, gnv$narrative)),]
  if(ts){
    sub_data_agg <- sub_data %>%
      group_by(date) %>%
      summarise(n = n())
    
    all_dates <- data.frame(date = seq(min(sub_data_agg$date),
                                       max(sub_data_agg$date),
                                       1))
    return_obj <- left_join(all_dates, sub_data_agg)
  } else{
    return_obj <- sub_data
  }
  return(return_obj)  
}

assault <- crime(narrative = 'ASSAULT')
car <- crime(narrative = 'DRUG')

######### 
# ADVANCED LEAFLET MAPS
##########

# Read in zip code shape file
library(rgdal)
#library(sp)
zip <- readOGR("zips_alachua", "ACDPS_zipcode")
zip <- spTransform(zip, CRS("+init=epsg:4326"))
zip$zip <- as.numeric(as.character(zip$ZIP))

library(rCharts)
# read in geojson version of zip
#zip_geoj <- readOGR("zips_alachua", "ACDPS_zipcode")
mymap <- Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(29.65, -82.3), zoom = 10)
mymap$enablePopover(TRUE)

mymap$fullScreen(TRUE)

for (i in 1:500){
  mymap$marker(c(gnv$lat[i], gnv$lon[i]),
               bindPopup = paste(gnv$narrative[i],
                                 gnv$offense_date[i]))
  
}

mymap

##################
# Make geojson object
##################

library(leafletR)
library(maptools)
library(rgdal)

# Read in state county shapefile
fl <- readOGR("counties", "FCTY2")

# make fl into a dataframe
fl_df <- data.frame(fl)

# Make fl_df into a gesjson object
fl_gj <- toGeoJSON(data = fl_df)


# Extract the list of Polygons objects
polys <- slot(fl,"polygons")

polys_list <- list()
# Within each Polygons object
#    Extract the Polygon list (assuming just one per Polygons)
#    And Extract the coordinates from each Polygon
for (i in 1:length(polys)) {
  #print(paste("Polygon #",i))
  polys_list[[i]] <-  slot(slot(polys[[i]],"Polygons")[[1]],"coords")
}

xy <- polys_list#[1]

joe <- list()
for (i in 1:length(polys_list)){
  xyz <- matrix(unlist(xy[[i]]), ncol = 2)
  xyjson = RJSONIO::toJSON(xyz)
  
  jsonX = paste(
    '{"type":"FeatureCollection","features":[
{"type":"Feature",
"properties":{"region_id":1, "region_name":"My Region"},
"geometry":{"type":"Polygon","coordinates": [ ',xyjson,' ]}}]}')
  
  polys = RJSONIO::fromJSON(jsonX)
  
  joe[[i]] <- polys
}


mymap = Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(29.65, -82.3), zoom = 10)
mymap$enablePopover(TRUE)
for (i in 1:length(joe)){
  mymap$geoJson(joe[[i]])
  
}
#mymap$geoJson(joe[[1]])

mymap


###########
# TRY TO GET A SINGLE GEOJSON OBJECT
###########

# Make geojson object
library(leafletR)

# Extract the list of Polygons objects
polys <- slot(fl,"polygons")

polys_list <- list()
# Within each Polygons object
#    Extract the Polygon list (assuming just one per Polygons)
#    And Extract the coordinates from each Polygon
for (i in 1:length(polys)) {
  #print(paste("Polygon #",i))
  polys_list[[i]] <-  slot(slot(polys[[i]],"Polygons")[[1]],"coords")
}

xy <- polys_list#[1]
xy <- do.call("rbind", xy)
xyz <- xy


xyjson = RJSONIO::toJSON(xyz)

jsonX = paste(
  '{"type":"FeatureCollection","features":[
{"type":"Feature",
  "properties":{"region_id":1, "region_name":"My Region"},
  "geometry":{"type":"Polygon","coordinates": [ ',xyjson,' ]}}]}')

polys = RJSONIO::fromJSON(jsonX)

mymap = Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(29.65, -82.3), zoom = 10)
mymap$enablePopover(TRUE)
mymap$geoJson(polys)

mymap










#########
# MAKE SOME MAPS
#########
# plot the points on a florida map
library(maps)
map("county", "florida")
points(gnv$lon, gnv$lat, col = "red")

# Plot the points on an Alachua map
library(rgdal)
library(sp)
zip <- readOGR("zips_alachua", "ACDPS_zipcode")
zip <- spTransform(zip, CRS("+init=epsg:4326"))
zip$zip <- as.numeric(as.character(zip$ZIP))
plot(zip, col = "grey", border = "white")

points(gnv$lon, gnv$lat,
       col = adjustcolor(rainbow(nrow(gnv)), alpha.f = 0.3),
       pch = 16,
       cex = 0.3)

# Color by crime type ("Narrative")
library(RColorBrewer)
my_colors <- colorRampPalette(rainbow(10))(length(levels(gnv$Narrative)))

gnv$col <- my_colors[as.numeric(gnv$Narrative)]
plot(zip, col = "grey", border = "white")

points(gnv$lon, gnv$lat,
       col = adjustcolor(gnv$col, alpha.f = 0.5),
       pch = 16,
       cex = 0.5)

legend(x = "bottomleft",
       pch = 16,
       col = adjustcolor(my_colors, alpha.f = 0.8),
       pt.cex = 0.1,
       cex = 0.1,
       ncol = 6, 
       bty = "n",
       legend = substr(levels(gnv$Narrative), 1, 5))

########
# GET ZIP CODE FOR EACH CRIME
########
# make a spatial version of gnv
gnv <- gnv[which(!is.na(gnv$lat) & !is.na(gnv$lon)),]
gnv_sp <- SpatialPointsDataFrame(gnv[,c("lon", "lat")], gnv,
                                 proj4string = CRS("+init=epsg:4326"))
x <- over(gnv_sp, polygons(zip))

# Return to dataframe
gnv$zip <- zip$zip[x]

#########
# GET NUMBER OF CRIMES BY ZIP CODE
#########
library(dplyr)
crimes_zip <- 
  gnv %>%
  group_by(zip) %>%
  summarise(n_crimes = n()) %>%
  arrange(desc(n_crimes))

# bring those numbers into the spatial polygons data frame
zip_df <- data.frame(zip)

zip_df <- merge(x = zip_df,
                y = crimes_zip,
                by = "zip",
                all.x = TRUE,
                all.y = FALSE)
for (i in zip$zip){
  zip$n_crimes[which(zip$zip == i)] <-
    zip_df$n_crimes[which(zip_df$zip == i)]
}

##########
# WRITE A FUNCTION FOR MAKING A CHOROPLETH MAP OF THESE ZIP CODES
##########
library(classInt)
MapFun <- function(var, color){
  plotvar <- var
  nclr <- 8
  plotclr <- brewer.pal(nclr, color)
  class <- classIntervals(plotvar, nclr, style = "quantile", dataPrecision=0) #use "quantile" instead
  #class <- classIntervals(0:100, nclr, style="equal")
  colcode <- findColours(class, plotclr)
  legcode <- paste0(gsub(",", " - ", gsub("[[]|[]]|[)]", "", names(attr(colcode, "table")))))
  plot(zip, border="darkgrey", col=colcode)
  legend("bottomleft", # position
         legend = legcode, #names(attr(colcode, "table")), 
         fill = attr(colcode, "palette"), 
         cex = 0.8, 
         border=NA,
         bty = "n",
         y.intersp = 0.6)
}

# Now plot
MapFun(zip$n_crimes, "Blues")
title(main = "Number of crimes by zip code")

# Plot rate (adj. for pop)
MapFun(zip$n_crimes / zip$POP1996 * 100000, "Blues")
title(main = "Crime rate by zip code")


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
#zip_geoj <- readOGR("zips_alachua", "ACDPS_zipcode")
mymap <- Leaflet$new()
mymap$tileLayer(provider = "Stamen.TonerLite")
mymap$setView(c(29.65, -82.3), zoom = 10)
mymap$enablePopover(TRUE)

mymap$fullScreen(TRUE)

for (i in 1:100){
  mymap$marker(c(gnv$lat[i], gnv$lon[i]),
               bindPopup = paste(gnv$Narrative[i],
                                 gnv$Offense.Date[i]))
  
}

mymap

# http://zevross.com/blog/2014/04/11/using-r-to-quickly-create-an-interactive-online-map-using-the-leafletr-package/
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


downloaddir<-paste0(getwd(), "/zips_alachua" )

filename<-list.files(downloaddir, pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename)

# ----- Change zip to dat
dat <- zip
subdat<- dat

# ----- Transform to EPSG 4326 - WGS84 (required)
subdat<-spTransform(subdat, CRS("+init=epsg:4326"))

# ----- change name of field we will map
names(subdat)[names(subdat) == "POP1996"]<-"Population"

# # ----- save the data slot
subdat_data<- subdat@data

# ----- simplification yields a SpatialPolygons class
# subdat<-gSimplify(subdat,tol=0.01, topologyPreserve=TRUE)

# ----- to write to geojson we need a SpatialPolygonsDataFrame
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)



# ----- Write data to GeoJSON
leafdat<-paste(downloaddir, "/", filename, ".geojson", sep="") 

#zipgj <- toGeoJSON(data = zip, dest = paste0(getwd(),"/zips_alachua"))
zipgj <- toGeoJSON(data = subdat, dest = paste0(getwd(),"/zips_alachua"))

# # ------ Function to write to GeoJSON
# togeojson <- function(file, writepath = "~") {
#   url <- "http://ogre.adc4gis.com/convert"
#   tt <- POST(url, body = list(upload = upload_file(file)))
#   out <- content(tt, as = "text")
#   fileConn <- file(writepath)
#   writeLines(out, fileConn)
#   close(fileConn)
# }
# 
# library(httr)
# file <- paste0(getwd(), "/zips_alachua/", "ACDPS_zipcode.zip")
# togeojson(file, leafdat)


# ----- Create the cuts
cuts<-round(quantile(subdat$Population, probs = seq(0, 1, 0.20), na.rm = FALSE), 0)
cuts[1]<-0 # ----- for this example make first cut zero


# ----- Fields to include in the popup
popup<-c("ZIP", "Population")


# ----- Gradulated style based on an attribute
sty<-styleGrad(prop="Population", breaks=cuts, right=FALSE, style.par="col",
               style.val=rev(heat.colors(6)), leg="Population", lwd=1)




# ----- Create the map and load into browser
map<-leaflet(data=zipgj, dest=downloaddir, style=sty,
             title="index", base.map="osm",
             incl.data=TRUE,  popup=popup)

# ----- to look at the map you can use this code
browseURL(map)


####################
library(rgbif)
file2 <-  "/zips_alachua/ACDPS_zipcode.shp"
## Success! File is at /Users/scottmac2/abiesmagmap.geojson
gist(paste0(getwd(),"/zips_alachua/zip.geojson"), description = "test")

#################################
# MODELING
##################################

# Let's just look at 2013
gnv <- gnv[which(gnv$date >= "2013-01-01" &
                   gnv$date <= "2013-12-31"),]

#install.packages("weatherData")
library(weatherData)

# Get weather for just one day
x <- getWeatherForDate("GNV", start_date = "2014-04-14",
                       end_date = "2014-04-30",
                  opt_all_columns = TRUE)



# Get weather for a period of time
weather <- getSummarizedWeather("GNV", start_date = min(gnv$date), 
                                end_date = max(gnv$date),
                                opt_custom_columns = TRUE,
                                custom_columns = c(2,4,20))

# format
weather$date <- as.Date(weather$Date, format = "%Y-%m-%d")

# Merge to gnv
gnv <- merge(x = gnv,
             y = weather,
             by = "date",
             all.x = TRUE,
             all.y = FALSE)


# Glimpse at your data
head(weather)

# Clean
weather$rain <- as.numeric(weather$PrecipitationIn)


# Plot max temperature
plot(weather$date, weather$Max_TemperatureF, 
     col = adjustcolor("darkred", alpha.f = 0.3),
     pch = 16,
     ylim = c(20, 100),
     xlab = "Date",
     ylab = "Temp")

# Add min temperature
points(weather$date, weather$Min_TemperatureF, 
       col = adjustcolor("darkblue", alpha.f = 0.3),
       pch = 16)

# Add legend
legend("bottom",
       pch = 16,
       col = adjustcolor(c("darkred", "darkblue"), alpha.f = 0.3),
       legend = c("High", "Low"),
       bty = "n")

# Where are we?
abline(v = Sys.Date() - 365,
       col = adjustcolor("black", alpha.f = 0.4),
       lwd = 2)
