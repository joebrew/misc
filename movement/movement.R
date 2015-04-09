line1 <- list(x = c(1,2), y = c(2,3))
line2 <- list(x = c(2,2.5), y = c(3,2))

yoni <- function(line1 = line1,
                 line2 = line2,
                 speed1 = 1,
                 speed2 = -2){
  
  # Get distances
  distance1 <- 
    sqrt(((line1$x[1] - line1$x[2])^2) +
    ((line1$y[1] - line1$y[2])^2))
  
  distance2 <- 
    sqrt(((line2$x[1] - line2$x[2])^2) +
           ((line2$y[1] - line2$y[2])^2))
    
  # Get 360 degrees
  degrees1 <- c(line1$x[1], line1$y[1])
  
  plot(0:5,0:5, type = 'n', xlab = NA, ylab = NA)
  lines(line1)
  lines(line2)
  
  
}