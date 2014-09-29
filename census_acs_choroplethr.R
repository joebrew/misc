library(choroplethr)
library(acs)

my_key <- "e6dbe1347a39270d90d300f78179adcb87a596d2"
api.key.install(my_key)

choroplethr_acs("B01001", "county", endyear=2012, span=5,
                showLabels = FALSE)

# B01003: total population
# B01002: median age by sex
# B19001: household income in the last 12 months