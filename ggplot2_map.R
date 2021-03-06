library(ggplot2)
if (require("maps")) {
  # Create a lat-long dataframe from the maps package
  nz <- map_data("nz")
  nzmap <- ggplot(nz, aes(x=long, y=lat, group=group)) +
    geom_polygon(fill="white", colour="black")
  
  # Use cartesian coordinates
  nzmap
  # With default mercator projection
  nzmap + coord_map()
  # Other projections
  nzmap + coord_map("cylindrical")
  nzmap + coord_map("azequalarea",orientation=c(-36.92,174.6,0))
  
  states <- map_data("state")
  usamap <- ggplot(states, aes(x=long, y=lat, group=group)) +
    geom_polygon(fill="white", colour="black")
  
  # Use cartesian coordinates
  usamap
  # With mercator projection
  usamap + coord_map()
  # See ?mapproject for coordinate systems and their parameters
  usamap + coord_map("gilbert")
  usamap + coord_map("lagrange")
  
  # For most projections, you'll need to set the orientation yourself
  # as the automatic selection done by mapproject is not available to
  # ggplot
  usamap + coord_map("orthographic")
  usamap + coord_map("stereographic")
  usamap + coord_map("conic", lat0 = 30)
  usamap + coord_map("bonne", lat0 = 50)
  
  # World map, using geom_path instead of geom_polygon
  world <- map_data("world")
  worldmap <- ggplot(world, aes(x=long, y=lat, group=group)) +
    geom_path() +
    scale_y_continuous(breaks=(-2:2) * 30) +
    scale_x_continuous(breaks=(-4:4) * 45)
  
  # Orthographic projection with default orientation (looking down at North pole)
  worldmap + coord_map("ortho")
  # Looking up up at South Pole
  worldmap + coord_map("ortho", orientation=c(-90, 0, 0))
  # Centered on New York (currently has issues with closing polygons)
  worldmap + coord_map("ortho", orientation=c(41, -74, 0))
}