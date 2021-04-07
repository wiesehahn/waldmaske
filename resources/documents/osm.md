# Open Street Map 

use of OSM data to mask out features (e.g. streets)



sources used:

- https://overpass-turbo.eu/  
(to query data from OSM) - simple example [query](https://overpass-turbo.eu/s/Voa) to get certain highways

- https://taginfo.openstreetmap.org/  
(to get information about data values/tags)

- https://wiki.openstreetmap.org/wiki/Map_Features  
(to get information about data values/tags)

- https://towardsdatascience.com/loading-data-from-openstreetmap-with-python-and-the-overpass-api-513882a27fd0  
(how to use overpass api with python)


Using the following query, data can be downloaded from overpass-api
```
[out:json];

area["ISO3166-2"="DE-NI"]->.suchgebiet;

(
  way
  ["highway"]
  [highway!~"footway|path|bridleway|steps"]
  [tracktype!~"grade4|grade5"]
  (area.suchgebiet);
);
out skel geom qt;
```

This query was executed from a python script inside a colab notebook. Further the data was converted to GeoJSON FeatureCollection and then to shapefile in this notebook. [colab notebook](https://github.com/wiesehahn/waldmaske/blob/master/notebooks/query_osm.ipynb)  

The shapefile was zipped and uploaded to Google Earth Engine for the masking process. [GEE script](https://github.com/wiesehahn/waldmaske/blob/master/scripts/gee/05_mask_streets.js)


