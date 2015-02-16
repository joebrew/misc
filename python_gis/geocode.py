# PACKAGE: https://github.com/DenisCarriere/geocoder
import geocoder
import os
import pandas as pd
import re
import matplotlib.image as mpimg
import numpy as np
import platform

# Read in and combine hierarchical addresses fields
# Separated by commas
# e.g.: 530 NW 2nd Street, Gainesvill, FL, USA
# Name your pandas dataframe "dat" and name the 
# combined address field "address"

# Sort and clean
address = sorted(set(dat['address']))

# Make dataframe for each geocoder
template = pd.DataFrame(data = 
    {'address' : address,
    'ok' : '',
    'lat' : '',
    'lng' : '', 
    'confidence' : '',
    'quality' : '',
    'fields_used' : ''
    })

# Make a pd.df for each of the geocoders
arc = template.copy()
bing = template.copy()
geonames = template.copy()
google = template.copy()
here = template.copy()
mapquest = template.copy()
opencage = template.copy()
osm = template.copy()
tomtom = template.copy()
yahoo = template.copy()


# Define function for geocoding
def multi_geo(df = None, fun = geocoder.google):
    # Make sure df has been assigned
    try:
        df
    except NameError():
        df = template.copy()

    # Loop through each row to geocode
    for i in df.index:
        # isolate address
        add = df['address'][i]

        # stop if no address
        if pd.isnull(add):
            continue

        #split into its pieces
        add_split = add.split(',')

        # try to geocode
        gc = fun(add)

        #if it didn't work, chop off first part and try again
        #until it works
        while not gc.ok:
            if len(add_split) == 1:
                break
            else:
                add_split = add_split[1:]
                new_add = ','.join(add_split)
                gc = fun(new_add)
        # If not broken, populate the df
        if gc.ok:
            df['lat'][i] = gc.lat
            df['lng'][i] = gc.lng
            df['confidence'][i] = gc.confidence
            df['quality'][i] = gc.quality
            df['fields_used'][i] = len(add_split)
        print 'geocoding row ' + str(i) + ' of ' + str(len(df.index))
    return(df)


# Geocode #####
write_dir = 'data/sketches_data/geo/geocoders_comparison/pytest'
os.chdir(write_dir)

# ArcGIS
arc = multi_geo(df = arc, fun = geocoder.arcgis)
arc.to_csv('arc.csv')

# Bing
bing = multi_geo(df = bing, fun = geocoder.bing)
bing.to_csv('bing.csv')

# Geonames
geonames = multi_geo(df = geonames, fun = geocoder.geonames)
geonames.to_csv('geonames.csv')

# Google
google = multi_geo(df = google, fun = geocoder.google)
google.to_csv('google.csv')

# HERE
here = multi_geo(df = here, fun = geocoder.here)
here.to_csv('here.csv')

# Mapquest
mapquest = multi_geo(df = mapquest, fun = geocoder.mapquest)
mapquest.to_csv('mapquest.csv')

# Opencage
opencage = multi_geo(df = opencage, fun = geocoder.opencage)
opencage.to_csv('opencage.csv')

# OSM
osm = multi_geo(df = osm, fun = geocoder.osm)
osm.to_csv('osm.csv')

# Tom-tom
tomtom = multi_geo(df = tomtom, fun = geocoder.tomtom)
tomtom.to_csv('tomtom.csv')

# yahoo
yahoo = multi_geo(df = yahoo, fun = geocoder.yahoo)
yahoo.to_csv('yahoo.csv')