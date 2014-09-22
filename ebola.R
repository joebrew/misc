# http://nsaunders.wordpress.com/2014/09/22/ebola-wikipedia-and-data-janitors/

library(XML)
library(ggplot2)
library(reshape2)

# get all tables on the page
ebola <- readHTMLTable("http://en.wikipedia.org/wiki/Ebola_virus_epidemic_in_West_Africa", 
                       stringsAsFactors = FALSE)
# thankfully our table has a name; it is table #5
# this is not something you can really automate
head(names(ebola))
# [1] "Ebola virus epidemic in West Africa"          
# [2] "Nigeria Ebola areas-2014"                     
# [3] "Treatment facilities in West Africa"          
# [4] "Democratic Republic of Congo-2014"            
# [5] "Ebola cases and deaths by country and by date"
# [6] "NULL"

ebola <- ebola$`Ebola cases and deaths by country and by date`

# again, manual examination reveals that we want rows 2-71 and columns 1-3
ebola.new <- ebola[2:71, 1:3]
colnames(ebola.new) <- c("date", "cases", "deaths")

# need to fix up a couple of cases that contain text other than the numbers
ebola.new$cases[27]  <- "759"
ebola.new$deaths[27] <- "467"

# get rid of the commas; convert to numeric
ebola.new$cases  <- gsub(",", "", ebola.new$cases)
ebola.new$cases  <- as.numeric(ebola.new$cases)
ebola.new$deaths <- gsub(",", "", ebola.new$deaths)
ebola.new$deaths <- as.numeric(ebola.new$deaths)

# fix dataes
ebola.new$date <- as.Date(ebola.new$date, format = "%d %b %Y")

# plot
plot(ebola.new$date, ebola.new$cases, type = "l", col = "darkgreen",
     xlab = "Date", ylab = "People")
lines(ebola.new$date, ebola.new$deaths, col = "darkred")
legend(x= "topleft",
       lty = 1,
       col = c("darkgreen", "darkred"),
       legend = c("Cases", "Deaths"),
       bty = "n")
