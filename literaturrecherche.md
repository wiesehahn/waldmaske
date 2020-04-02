
[BKG](https://www.bkg.bund.de/DE/Ueber-das-BKG/Geoinformation/Fernerkundung/fernerkundung.html)
* Das BKG aktualisiert mit Hilfe von Fernerkundungsdaten alle drei Jahre das Digitale Landbedeckungsmodell für Deutschland (LBM-DE)
  * Mindestkartierfläche jedoch einen Hektar und die Mindestkartierbreite 15 Meter
  * bisher wurden hauptsächlich RapidEye-Satellitenbilder genutzt, "zukünftig" Copernicus 
 
[BMEL](Programm des BMEL zur FernerkundungChancen für Land-, Forst- und Fischereiwirtschaft, für Politik und Verwaltung)
* Potenzial von zukünftigen Anwendungsoptionen der Fernerkundung laut TI-WO u.a.
  * Erfassung der Waldfläche und Waldflächenänderungen
  * Erfassung von Bäumen außerhalb des Waldes


## Waldmasken aus Fernerkundungsdaten in anderen Studien

### LIDAR

### Satellitenbilder
[JRC Forest Type Map]()
* 2006
* 25m Auflösung


[Copernicus HRL](https://land.copernicus.eu/pan-european/high-resolution-layers)
* für 2012, 2015 (alle 3 Jahre)
* aus Sentinel-1, Sentinel-2 (sowie Landsat-8 und VHR)
* 20m Auflösung (100m für Change Products)
* Definition für Tree Cover Mask vorhanden
* Produkte: Tree Cover Density, Forest Type, Forest Additional Support Layer, Dominant Leaf Type, Tree Cover Density Change, Dominante Leaf Type Change
* TCD aus HR Bildern mit VHR Bildern und Orthophotos als Referenz in einer linearen Funktion
* DLT aus multitenmporalen Bildern mit Support Vector Mashine
* FTY erstellt nach FAO Walddefinition (20m-Version beinhaltet Stadt- und Agrarbäume, 100m-Version nicht)
* FADSL nutzt CORINE Land Cover und HRL imperviousness um Stadt und Agrarbäume auszuweisen
* Small Woody Features wurden aus VHR Bildern extrahiert und beinhalten Hecken, Alleen Baumgruppen (TOF)

## Referenzdaten

