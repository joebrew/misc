setwd("C:/Users/BrewJR/Documents/misc") # change this line to whereever you cloned misc
setwd("gnv_crime")

# define the link for gainesville crime
my_link1 <- "https://data.cityofgainesville.org/api/views/9ccb-cyth/rows.csv"

# read in the data
gnv <- read.csv(my_link1)

# get lat and lon
names(gnv)

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
       pch = 1,
       cex = 0.3)
