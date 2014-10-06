library(rCharts)
setwd("C:/Users/BrewJR/Documents/misc/rCharts")
# ## Example 1 Facetted Scatterplot
# names(iris) = gsub("\\.", "", names(iris))
# rPlot(SepalLength ~ SepalWidth | Species, data = iris, color = 'Species', type = 'point')
# 
# ## Example 2 Facetted Barplot
# hair_eye = as.data.frame(HairEyeColor)
# rPlot(Freq ~ Hair | Eye, color = 'Eye', data = hair_eye, type = 'bar')

library(rgdal)
fl <- readOGR("zcta_fl",
              "tl_2010_12_zcta510")

xy = cbind(
  c(13.42666, 13.42666, 13.56383, 13.56358, 13.42666),
  c(48.99831, 49.08815, 49.08815, 48.99831, 48.99831)
)

xyjson = RJSONIO::toJSON(xy)

jsonX = paste(
  '{"type":"FeatureCollection","features":[
{"type":"Feature",
"properties":{"region_id":1, "region_name":"My Region"},
"geometry":{"type":"Polygon","coordinates": [ ',xyjson,' ]}}]}')

polys = RJSONIO::fromJSON(jsonX)
map = Leaflet$new()
map$tileLayer(provider = 'Stamen.TonerLite')
map$setView(c(49.1,13.5), zoom = 8)
map$geoJson(polys)
map