from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import numpy as np
 
# make sure the value of resolution is a lowercase L,
#  for 'low', not a numeral 1
map = Basemap(projection='ortho', lat_0=20, lon_0=-10,
              resolution='l', area_thresh=1000.0)
 
map.drawcoastlines()
map.drawlsmask(land_color='white',ocean_color='black',lakes=True)
 
plt.show()

m = Basemap(width=12000000,height=9000000,projection='lcc',
            resolution=None,lat_1=45.,lat_2=55,lat_0=50,lon_0=-107.)
m.etopo()
plt.show()