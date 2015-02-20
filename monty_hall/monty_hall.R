# monty hall problem

monty_hall <- function(stay = TRUE){
  posibs <- c("goat", "goat", "car")
  posibs <- sample(posibs, 3, replace = FALSE)
  doors <- 1:3
  picked <- sample(1:3, 1)
  not_picked <- doors[-picked]
  show <- sample(which(posibs[not_picked] == "goat"), 1)
  
  if(!stay){
    picked <- not_picked[-show]
  }
  object <- posibs[picked]
  return(object)
}

stays <- rep(NA, 1000)
changes <- rep(NA, 1000)
stay_car <- rep(NA, 1000)
changes_car <- rep(NA, 1000)

cols <- c("red", "blue")

setwd('/home/joebrew/Desktop/temp')

for (i in 1:1000){
  for (j in c("a", "b", "c", "d", "e")){
    set.seed(i * sample(1:10, 1) + 1^2)
    stays[i] <- monty_hall(stay = TRUE)
    changes[i] <- monty_hall(stay = FALSE)
    
    x <- stays[1:i]
    y <- changes[1:i]
    x <- length(x[which(x == "car")]) / length(x)
    y <- length(y[which(y == "car")]) / length(y)
    
    stay_car[i] <- x
    changes_car[i] <- y
    
    #plotname
    plotname <- as.character(i)
    while(nchar(plotname) < 6){
      plotname <- paste0("0",plotname)
    }
    plotname <- paste0(j, plotname, ".png")
    
    if(i %% 10 == 0){
      png(plotname)
      
      plot(x = c(1,1000),
           y = c(0,1), type = "n",
           xlab = "Number of tries",
           ylab = "Proportion choosing car")
      
      legend(x = "topright",
             col = cols,
             legend = c("Stay", "Change"),
             lty = 1)
      
      abline(h = c(1/3, 0.5),
             col = adjustcolor("black", alpha.f = 0.4),
             lty = 3)
      text (x = 800, y= c(1/3, 0.5),
            pos = 3,
            col = adjustcolor("black", alpha.f = 0.4),
            labels = c("33%", "50%"))
      
      lines(x = 1:i,
            y = stay_car[1:i], col = cols[1])
      lines(x = 1:i,
            y = changes_car[1:i], col = cols[2])
      
      title(main = paste0("Probability of choosing car after ", i, " tries"))
      dev.off()
    }
    #Sys.sleep(0.01)  
    
  }
  
  
  }
  