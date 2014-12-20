root <- '/home/joebrew/Documents/babynames/joebrew'
setwd(root)

library(babynames)
bn <- babynames
length(unique(bn$name))
