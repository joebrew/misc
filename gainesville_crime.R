# (install and) attach the R socrata library
library(RSocrata)

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

library(maps)
map("county", "florida")
points(gnv$lon, gnv$lat, col = "red")
