#####
# INSTALL AND ATTACH rMaps LIBRARY
#####
#require(devtools)
#install_github('ramnathv/rCharts@dev')
#install_github('ramnathv/rMaps')
library(rMaps)

#####
# CROSSLET EXAMPLE
#####
# crosslet(
#   x = "country", 
#   y = c("web_index", "universal_access", "impact_empowerment", "freedom_openness"),
#   data = web_index
# )

#####
# DATA MAPS
#####
ichoropleth(Crime ~ State, data = subset(violent_crime, Year == 2010))
ichoropleth(Crime ~ State, data = violent_crime, animate = "Year")
ichoropleth(Crime ~ State, data = violent_crime, animate = "Year", play = TRUE)

# explore violent crime data
violent_crime <- violent_crime
