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

# Merge
library(dplyr)
pick <- inner_join(x = us,
                y = es,
                by = "name")
pick$name
