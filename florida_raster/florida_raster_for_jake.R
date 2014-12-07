#####
# SET LOCAL WORKING DIRECTORY
# (change on your computer)
#####
setwd("/home/joebrew/Documents/misc/florida_raster")

#####
# ATTACH SOME PACKAGES
#####
library(rgdal)
library(raster)

#####
# READ IN THE FLORIDA COUNTIES SHAPEFILE
# (in the same github directory)
#####
fl <- readOGR("florida_counties", "counties")

#####
# TEST TO MAKE SURE YOU READ IT RIGHT
#####
plot(fl)

#####
# CONVERT FL COUNTIES TO RASTER ("VALUES" ARE SIMPLY COUNTY NUMBERS (alphabetically))
#####
# (borrowing heavily from: http://stackoverflow.com/questions/14992197/shapefile-to-raster-conversion-in-r)
## Set up a raster "template" to use in rasterize()
ext <-  extent(as.numeric(c(bbox(fl)[1,], bbox(fl)[2,])))
xy <- abs(apply(as.matrix(bbox(ext)), 1, diff))
n <- 100
r <- raster(ext, ncol=xy[1]*100, nrow=xy[2]*100)

## Rasterize the shapefile
rr <-rasterize(fl, r)

## A couple of outputs
writeRaster(rr, "fl.asc")
plot(rr)

#####
# ALTERNATIVE METHOD (assign values to each county based on area)
#####
# Borrowed heavily from http://gis.stackexchange.com/questions/17798/converting-a-polygon-into-a-raster-using-r
r <- raster(ncol=180, nrow=180)
extent(r) <- extent(fl)
rp <- rasterize(fl, r, 'Shape_Area')

# Output
writeRaster(rp, "fl2.asc")
plot(rp)

#####
# CONVER THE ENTIRE STATE AS ONE UNIT TO RASTER
#####

# First, break down the fl boundaries
# Using code Joe hosts on github (a function called collapse_map)
library(devtools)
source_url("https://raw.githubusercontent.com/joebrew/misc/master/functions/functions.R")
fl_collapsed <- collapse_map(fl)

# Check to see that the collapse worked
plot(fl_collapsed)

# Give a projection string
fl_collapsed <- SpatialPolygonsDataFrame(fl_collapsed, data = data.frame("dummy" = 1))
proj4string(fl_collapsed) <- proj4string(fl)

# Turn fl_collapsed into a raster
r <- raster(ncol=180, nrow=180)
extent(r) <- extent(fl_collapsed)
rc <- rasterize(fl_collapsed, r, 'dummy')

# Output
writeRaster(rc, "fl3.asc")
plot(rc)
#####
#
#####