n <- 100
place <- 1:n
x <- sample(-180:180, n)
y <- sample(-80:80, n)

product <- 1:n
weight <- rnorm(n, mean = 2, sd = 2)

# Visualize locations
library(maps)
map("world",  fill = TRUE, col = adjustcolor("black", alpha.f = 0.1))
points(x, y, col = "red", pch = 16)

# Visualize locations with the weight of the object that
# has to go there
map("world",  fill = TRUE, col = adjustcolor("black", alpha.f = 0.1))
points(x, y, cex = weight, col = "red")

# Bind all things into a dataframe
df <- data.frame(place, x, y, product, weight)

# Define function for calculating distance
# Calculate distance in kilometers between two points
earth.dist <- function (long1, lat1, long2, lat2)
{
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378.145
  d <- R * c
  return(d)
}

# Simulate 100 different routes
# Calculating a weight* distance score
expenditure <- list()
expenditure$score <- NA
expenditure$route <- NA

cols <- rainbow(100)
cols <- sample(cols)

for (i in 1:100){
  # random starting point
  start_point <- c(sample(x, 1), sample(y, 1))
  # random order of routes
  new_df <- df[sample(1:nrow(df)),]
  
  
  # Map
  map("world",  fill = TRUE, col = adjustcolor("black", alpha.f = 0.1))
  title(main = paste0("Route number ", i))
  points(x, y, cex = weight, col = adjustcolor(cols[i]))
  for (j in 1:nrow(new_df)){
    # Calculate distnace
    if(j == 1){
      old_point <- start_point
    } else {
      old_point <- as.numeric(df[j-1, c('x', 'y')])
    }
    new_point <- as.numeric(df[j, c('x', 'y')])
    distance <- earth.dist(long1 = new_df$x[j],
                           lat1 = new_df$y[j],
                           long2 = old_point[1],
                           lat2 = old_point[2])
    
    # Get distance traveled from previous point to new point
    new_df$distance[j] <- distance
    

    
    # Draw lines
    lines(x = c(old_point[1], new_point[1]),
          y = c(old_point[2], new_point[2]),
          col = adjustcolor(cols[i], alpha.f = 0.5))
    
    # Label
    text(x = new_point[1],
         y = new_point[2],
         labels = j,
         col = cols[i],
         cex = 0.2)
    #Sys.sleep(0.3)
  }
 
  # Get cumulative distance
  new_df$cumulative_distance <- cumsum(new_df$distance)
  # Get a weight-distance unit score
  new_df$weight_distance <- new_df$cumulative_distance * new_df$weight
  
  # Sum the weight_distance and send to the list
  expenditure$score[[i]] <- sum(new_df$weight_distance)
  expenditure$x[[i]] <- new_df$x
  expenditure$y[[i]] <- new_df$y
  expenditure$df[[i]] <- new_df
  
}

hist(expenditure$score, breaks = 20, col = "grey")
best <- which.min(expenditure$score)
best_df <- expenditure$df[[best]]
map("world",  fill = TRUE, col = adjustcolor("black", alpha.f = 0.1))
title(main = paste0("Route number ", best))
points(x = best_df$x, 
       y = best_df$y, cex = weight, col = adjustcolor(cols[best]))

for (j in 1:nrow(best_df)){
  # Calculate distnace
  if(j == 1){
    old_point <- start_point
  } else {
    old_point <- as.numeric(df[j-1, c('x', 'y')])
  }
  new_point <- as.numeric(df[j, c('x', 'y')])
  distance <- earth.dist(long1 = best_df$x[j],
                         lat1 = best_df$y[j],
                         long2 = old_point[1],
                         lat2 = old_point[2])
  
  # Get distance traveled from previous point to new point
  best_df$distance[j] <- distance
  
  # Draw lines
  lines(x = c(old_point[1], new_point[1]),
        y = c(old_point[2], new_point[2]),
        col = adjustcolor(cols[best], alpha.f = 0.5))
  
  # Label
  text(x = new_point[1],
       y = new_point[2],
       labels = j,
       col = cols[best],
       cex = 0.2)
  Sys.sleep(0.5)
}
hist(expenditure$score)
