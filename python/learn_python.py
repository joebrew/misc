# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

# http://www.youtube.com/watch?v=RrPZza_vZ3w

# python -i myprogram.py 
## runs the program and then drops you into interactive mode

# <codecell>


# <codecell>

s = "Hello world"
len(s)
s + "!"
s.upper()
s.replace("Hello", "Hello Cruel")

# <codecell>

x = "42"
y = 13

# <codecell>

int(x) + y

# <codecell>

# defining new function
def hello(name):
    print('Hello %s!' % name)

# <codecell>

hello('Guido')

# <codecell>

# latitude and longitude function
def distance(lat1, lat2):
    return 69 * abs(lat1-lat2)

# <codecell>

distance(41.980262, 42.031662)

# <codecell>

# use import to read in libraries

# <codecell>

### CODING CHALLENGE
# The traveling suitcase
import urllib

# <codecell>

u = urllib.urlopen('http://ctabustracker.com/bustime/map/getBusesForRoute.jsp?route=22')

# <codecell>

data = u.read()

# <codecell>

f = open('rt22.xml', 'wb')

# <codecell>

f.write(data)

# <codecell>

f.close()

# <codecell>

# Dave's office located at
# lat 41.980262
# lon = -87.668452

# <codecell>

# use the ElementTree library to parse the xml
import urllib
from xml.etree.ElementTree import parse
doc = parse('rt22.xml')

# <codecell>

# iterate over bus elements, extracting direction and latitude
for bus in doc.findall('bus'):
    d = bus.findtext('d')
    lat = float(bus.findtext('lat'))

# <codecell>

# use google's static map api to visualize
#import webbrowser
#webbrowser.open('http://...')

# <codecell>

# try to find every bus traveling north of office on route 22
daves_latitude = 41.98062
daves_longitude = -87.668452

# <codecell>

for bus in doc.findall('bus'):
    lat = float(bus.findtext('lat'))
    if lat >= daves_latitude:
        busid = bus.findtext('id')
        direction = bus.findtext('d')
        if direction.startswith('North'):
            print(busid, direction, lat)

# <codecell>

# MINUTE 45 http://www.youtube.com/watch?v=RrPZza_vZ3w

# <codecell>

# monitor.py
candidates = ['1865', '1383']
def distance(lat1, lat2):
    'Return distance in miles between two lats'
    return 69*abs(lat1-lat2)

# <codecell>

def monitor():
    u = urllib.urlopen('http://ctabustracker.com/bustime/map/getBusesForRoute.jsp?route=22')
    doc = parse(u)
    for bus in doc.findall('bus'):
        busid = bus.findtext('id')
        if busid in candidates:
            lat = float(bus.findtext('lat'))
            dis = distance(lat, daves_latitude)
            print busid, dis, 'miles'
            print '-'*10

# <codecell>

import time
while True:
    monitor()
    time.sleep(10)

# <codecell>


