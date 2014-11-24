#####
# SET WORKING DIRECTORY CONDITIONAL TO SYSTEM
#####
if ( Sys.info()["sysname"] == "Linux" ){
  public <- "/home/joebrew/Documents/misc/dot_map"
} else {
  public <- "C:/Users/BrewJR/Documents/misc/dot_map"
}
setwd(public) 


#####
# ATTACH PACKAGES
#####
library(maptools)
library(rgdal)

#####
# READ IN ALACHUA COUNTY SHAPEFILE WITH POP NUMBERS
#####
ct <- readOGR(paste0(public, "/Alachua_CT_POP"), "Alachua_CT_POP")

#####
# COLLAPSE MAP INTO ONLY OUTER BOUNDARY
#####
collapse_map <- function(x){
  require(maptools)
  boundary <- unionSpatialPolygons(x, rep(1, length(x@polygons)))
}

ct_boundary <- collapse_map(ct)

#######
# FAST ATTEMPT
##############
plot(ct, col = "white", border = "white")
for (i in 1:nrow(ct)){ 
  temp <- ct[i,]
  
  n_dots <- temp$pop
  
  # Generate random points x and y
  x <- runif(100000, 
             min= temp@bbox[,"min"]["x"], 
             max= temp@bbox[,"max"]["x"])
  y <- runif(100000,
             min= temp@bbox[,"min"]["y"], 
             max= temp@bbox[,"max"]["y"])
  
  # Merge points into my_points (spatial points)
  my_points <- data.frame(cbind(x,y))
  coordinates(my_points) <- ~x+y
  proj4string(my_points) <- proj4string(temp)
  
  # Whic of the polygons does each point fall into
  in_points <- over(my_points, polygons(temp))
  
  # Plot points in each polygon
  # Get the points for each polygon
  plot_these <- sample(my_points[which(!is.na(in_points))], n_dots, replace = FALSE)
  
  # Jitter the points
  #plot_these <- jitter(coordinates(plot_these))
  
  # Plot the points
  points(plot_these, pch = 1, cex = 0.1,
         col = adjustcolor("black", alpha.f = 0.1))
}

#########
# FAST ATTEMPT WRAPPED INTO A FUNCTION
#########

DotFun <- function(main_shape,
                   points_number = 100000,
                   points_var,
                   points_col = "darkred",
                   cex = 0.01,
                   border = "white",
                   fill = "white"){
  
  plot(main_shape, col = fill, border = border)
  for (i in 1:nrow(main_shape)){ 
    temp <- main_shape[i,]
    
    n_dots <- points_var#temp@data[,points_var]
    
    # Generate random points x and y
    x <- runif(points_number, 
               min= temp@bbox[,"min"]["x"], 
               max= temp@bbox[,"max"]["x"])
    y <- runif(points_number,
               min= temp@bbox[,"min"]["y"], 
               max= temp@bbox[,"max"]["y"])
    
    # Merge points into my_points (spatial points)
    my_points <- data.frame(cbind(x,y))
    coordinates(my_points) <- ~x+y
    proj4string(my_points) <- proj4string(temp)
    
    # Whic of the polygons does each point fall into
    in_points <- over(my_points, polygons(temp))
    
    # Get the points for each polygon
    plot_these <- sample(my_points[which(!is.na(in_points))], n_dots, replace = FALSE)

    # Plot the points
    points(plot_these, pch = 1, cex = cex,
           col = adjustcolor(points_col, alpha.f = 0.1))
  }
}

DotFun(main_shape = ct,
       points_number = 10000,
       points_var = ct$pop ,
       points_col = "darkred",
       cex = 0.01,
       border = "black",
       fill = "white")

