setwd("/home/joebrew/Documents/misc/names")

es <- readLines("/home/joebrew/Documents/misc/names/NamesDatabases/first names/non-normalized/es.txt", 
                warn = FALSE)
es <- data.frame(name = es, country = "es")
us <- readLines("/home/joebrew/Documents/misc/names/NamesDatabases/first names/us.txt", 
                warn = FALSE)
us <- data.frame(name = us, country = "us")

all <- readLines("/home/joebrew/Documents/misc/names/NamesDatabases/first names/all.txt", 
                warn = FALSE)
all <- data.frame(name = all, country = "all")

balears <- read.csv("/home/joebrew/Documents/misc/names/balears.csv", skip = 8,
                    stringsAsFactors = FALSE)
names(balears) <- c("name", "illes_balears", "mallorca", "petra", "x")

library(XML)
x <- xmlToList("catala.xml")
my_list <- list()
for (i in 1:length(x)){
  my_name <- paste0("df", i)
  
  assign(my_name, data.frame(matrix(unlist(x[[i]]), nrow = 1, byrow = T)))
    
  my_list[[i]] <- get(my_name)
}
catala <- do.call(rbind.fill, my_list)
names(catala)[1:2] <- c("nom", "nombre") 
catala$nom <- as.character(catala$nom)
catala$nombre <- as.character(catala$nombre)


random_name <- function(df = balears, var_name = "name"){
  sample(df[,var_name], 1)
}
random_name()

# Sample
x <- sample(balears$name, nrow(balears))
for (i in 1:length(x)){print(x[i]);Sys.sleep(1)}

# Sample
sample(all$name, 1)