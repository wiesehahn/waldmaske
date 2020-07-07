# Open Street Map 

use of OSM data to mask out features (e.g. streets)



sources used:

- https://overpass-turbo.eu/
(to query data from OSM)

simple example [query](https://overpass-turbo.eu/s/Voa) to get certain highways

- https://taginfo.openstreetmap.org/
(to get information about data values/tags)

- https://wiki.openstreetmap.org/wiki/Map_Features
(to get information about data values/tags)

- https://towardsdatascience.com/loading-data-from-openstreetmap-with-python-and-the-overpass-api-513882a27fd0
(how to use overpass api with python)

Using the QuickOSM plugin with QGIS data with the following query can be downloaded. To reduce data amount save the layer without attributes as permanent layer.
```
<osm-script output="json" output-config="">
    <id-query {{geocodeArea:goettingen}} into="area_0"/>
  <query into="_" type="way">
    <has-kv k="highway" modv="" v=""/>
    <has-kv k="highway" modv="not" regv="footway|path|bridleway|steps"/>
    <has-kv k="tracktype" modv="not" regv="grade4|grade5"/>
   <area-query from="area_0"/>
  </query>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
  <recurse from="_" into="_" type="down"/>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="skeleton" n="" order="quadtile" s="" w=""/>
</osm-script>
```
