# Übersicht zu Wald/Nichtwald Kartierungen

## nutzbare Waldmasken 

[Copernicus HRL](https://land.copernicus.eu/pan-european/high-resolution-layers)
* für 2012, 2015 (alle 3 Jahre)
* aus Sentinel-1, Sentinel-2 (sowie Landsat-8 und VHR)
* 20m Auflösung (100m für Change Products)
* 2018 mit 10m Auflösung generiert über DIAS (Mundi Web Services) (Start: 22.01.2019, online ab ca Mitte Mai 2020)  
* Definition für Tree Cover Mask vorhanden
* Produkte: Tree Cover Density, Forest Type, Forest Additional Support Layer, Dominant Leaf Type, Tree Cover Density Change, Dominante Leaf Type Change

* TCD 
  * aus HR Bildern mit VHR Bildern und Orthophotos als Referenz in einer linearen Funktion
  * 1 Pixel MMU (20/10m)
  * 90% Accuracy [link](http://www.gofcgold.wur.nl/documents/CopernicusREDD/12_CopernicusHRlayers.pdf)
  
* DLT aus multitenmporalen Bildern mit Support Vector Mashine

* FTY erstellt nach FAO Walddefinition (20m-Version beinhaltet Stadt- und Agrarbäume, 100m-Version nicht)  
  20m Version besteht aus zwei Produkten:  
    1. DLT mit 0.5ha MMU und 10% TCD Grenzwert
    2. Support Layer (FADSL)
      * keine MMU
      * FADSL nutzt CORINE Land Cover und HRL imperviousness um Stadt und Agrarbäume auszuweisen

* Small Woody Features
  * wurden aus VHR Bildern extrahiert und beinhalten Hecken, Alleen, Baumgruppen (TOF) [Methode](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fland.copernicus.eu%2Fpan-european%2Fhigh-resolution-layers%2Fsmall-woody-features&data=02%7C01%7CKeri.Bloomfield%40eea.europa.eu%7Cace94925eabf406bface08d7c04fb831%7Cbe2e7beab4934de5bbc58b4a6a235600%7C1%7C0%7C637189320934401467&sdata=MYO61PoeavDbkYGaMFtQYS%2Bzs29GE1%2BE0Giuew%2BXxgw%3D&reserved=0)
  * für 2015 seit März 2020 verfügbar, als 5m Raster oder Vector und aggregierte Version als 100m Raster
  * mit TCD Waldmaske (>30% und morphologische Filter) maskiert, trotzdem manche Features doppelt und andere gar nicht kartiert.
  * Genauigkeit noch nicht validiert, 80% anvisiert (Stand: April 2020)

* High Resolution Vegetation Phenology and Productivity Layer seit Februar 2020 in Produktion


[LBM-DE](https://www.bkg.bund.de/DE/Ueber-das-BKG/Geoinformation/Fernerkundung/Landbedeckungsmodell/Herstellung/herstellung.html)
* Das BKG aktualisiert mit Hilfe von Fernerkundungsdaten alle drei Jahre das Digitale Landbedeckungsmodell für Deutschland (LBM-DE)
* Aufbauend auf Basis-DLM
* 2012, 2015, 2018
* Mindestkartierfläche 1 ha und die Mindestkartierbreite 15 Meter
* bisher wurden hauptsächlich RapidEye-Satellitenbilder genutzt, "zukünftig" Copernicus Sentinel Daten zur Aktualisierung


## Waldmasken aus Fernerkundungsdaten in anderen Studien

[Towards automated Forest Mapping](https://link.springer.com/chapter/10.1007/978-1-4939-7331-6_7)
* Übersicht zu Methoden und Studien

### LIDAR

[Waldabgrenzung mithilfe von 3D Fernerkundungsdaten am Beispiel der Walddefinition des Schweizerischen Landesforstinventares](https://ethz.ch/content/dam/ethz/special-interest/usys/ites/ites-dam/Education/Portal%20Forest%20and%20Landscape/Documents/MA_Abstracts_2019/Abstract_SamuelKueng.pdf)
* Waldmaske 2019 für den Kanton Bern
* 97% Overall Accuracy


### Stereobilder

[Wall-to-Wall Forest Mapping Based on DigitalSurface Models from Image-Based Point Clouds and a NFI Forest Definition](https://www.researchgate.net/publication/286453059_Wall-to-Wall_Forest_Mapping_Based_on_Digital_Surface_Models_from_Image-Based_Point_Clouds_and_a_NFI_Forest_Definition)
* aus Stereo Orthophotos (zusammen mit DTM und DLM)
* Auflösung 1m
* für die ganze Schweiz
* 97% Overall Accuracy


### Satellitenbilder (passiv)

[JRC Forest Map](https://earthzine.org/pan-european-forest-maps-derived-from-optical-satellite-imagery)
* 2000, 2006
* 25m Auflösung
* aus Landsat-7 ETM+ (2000) und IRS-LISS-3, SPOT4/5 Bildern (2006)
* CORINE Land Cover als Trainingsdaten
* LUCAS und eForest (Daten der NFIs) Daten zur Validierung
* k-NN Model (2000) und ANN Model (2006)
* 90.8% Overall Accuracy (2000) und 84% Overall Accuracy (2006)

[Satellitengestutzte Waldflachenkartierung fur die Bundeswaldinventur](https://ediss.sub.uni-hamburg.de/volltexte/2007/3172/pdf/070111_oehmichen_dissertation.pdf)
* für Testgebiete
* nach BWI-Definitoion
* aus Quickbird und Landsat (7)
* zusätzlich mit ATKIS Daten korrigiert
* referenziert mit BWI-Daten
* 93-97% Genauigkeit

[Tree cover mapping based on Sentinel-2 images demonstrate high thematic accuracy in Europe](https://www.sciencedirect.com/science/article/pii/S0303243419306087)
* für Testgebiete in Europa
* unüberwachte k-means Klassifikation von einzelnen Sentinel-2 Szenen
* Genauigkeit bis 90% (999 Pixel als Referenz)

[Mapping pan-European land cover using Landsat spectral-temporal metrics and the European LUCAS survey](https://www.sciencedirect.com/science/article/abs/pii/S0034425718305546?via%3Dihub)
* aus Landsat-8 Daten (1 Jahr und 3 Jahre)
* 'used annual and seasonal spectral-temporal metrics and environmental features'
* MMU 30x30m
* LUCAS Daten als Referenz
* 12 LULC classes für ganz Europa
* 75.1% Overall Accuracy


### Satellitenbilder (aktiv)

[Forest area derivation from Sentinel-1 data](https://www.isprs-ann-photogramm-remote-sens-spatial-inf-sci.net/III-7/227/2016/isprs-annals-III-7-227-2016.pdf)
* Waldmaske für Testgebiet in Österreich
* Sentinel-1A
* Otsu  thresholding  and  K-means  clustering
* 10m Auflösung und 500m² MMU
* 92% Overall Accuracy
* kann verbeesert werden wenn Stadtgebiete ausgeschlossen werden

[Annual seasonality in Sentinel-1 signal for forest mapping and forest type classification](https://www.tandfonline.com/doi/abs/10.1080/01431161.2018.1479788)
* für Testgenbiete
* aus Sentinel-1 Zeitreihen
* Methodik basiert auf time series similarity measures
* 86-91% Overall Accuracy (forest/non-forest) 
* 85% Overall Accuracy (non-forest, coniferous and broadleaf forest)
* Copernicus HRL als Referenz

[High Resolution Forest Maps from Interferometric TanDEM-X and Multitemporal Sentinel-1 SAR Data](https://link.springer.com/article/10.1007/s41064-017-0040-1)
* für Testgebiete in Deutschland und Kanada
* Sentinel-1 und TanDEM-X
* Random Forest Klassifikation
* ca 85 - 95% Genauigkeit

[The global forest/non-forest map from TanDEM-X interferometric SAR data](https://www.sciencedirect.com/science/article/pii/S0034425717305795#s0095)
* globale Waldmaske
* 50m Auflösung
* aus TanDEM-X Bildern 
* Genauigkeit => 90%


## Waldmaske als Nebenprodukt

[Forest Stand Species Mapping Using the Sentinel-2 Time Series](https://www.mdpi.com/2072-4292/11/10/1197/pdf)
* eine Sentinel-2 Szene mit Random Forest in Wald/Nichtwald klassifiziert

[Forest Type Identification with Random Forest UsingSentinel-1A, Sentinel-2A, Multi-Temporal Landsat-8and DEM Data](https://www.mdpi.com/2072-4292/10/6/946/pdf)
* zunächste Segmentierung mit Landsat-8, Sentinel-2 und Sentinel-1 Bildern
* dann Ableitung von Vegetation durch NDVI-Grenzwert für Segmente
* dann Wald/Nichtwald Unterscheidung der Vegetation durch Random Forest Klassifizierung von DEM und S-2 Metriken der Segmente
* Genauigkeit 99%

[Intra-annual reflectance composites from Sentinel-2 and Landsat for national-scale crop and land cover mapping](http://publzalf.ext.zalf.de/publications/a1eb1367-6281-412c-b489-1801d78feddf.pdf)
* für Deutschland
* 30m Auflösung
* 12 LULC Klassen
* LUCAS und LPIS Daten als Referenz
* aus Sentinel-2A und Landsat-8 mutlisensor-Kompositen (10-Tages, Saison- und Jahreskompositen)
* mit Random Forest Classifier
* 81% Overall Accuracy

## Referenzdaten

[LUCAS](https://ec.europa.eu/eurostat/de/web/lucas/data/primary-data/2018)
* 2018
* Walddefinition vorhanden
* georeferenzierte frei verfügbare Referenzdaten
* genaue Soll- und Ist-Koordinaten sind vorhanden
* [Beispielstudie](https://www.sciencedirect.com/science/article/pii/S0303243419307317)

[Recent Advances in Forest Observation with Visual Interpretation of Very High-Resolution Imagery](https://link.springer.com/article/10.1007/s10712-019-09533-z)
* Tools und Methoden zur Nutzung von VHR Bildern als Referenz
(Geo-Wiki, LACO-Wiki, Collect Earth)

[VHR_Image_2018](https://spacedata.copernicus.eu/web/cscda/data-offer/core-datasets/-/asset_publisher/SMEFUkzOylMw/content/optical-vhr-multispectral-and-panchromatic-coverage-over-europe-vhr_image_2018-?_101_INSTANCE_SMEFUkzOylMw_redirect=%2Fweb%2Fcscda%2Fdata-offer%2Fcore-datasets)
* 2-4m Auflösung
* über Copernicus (mit Anmeldung evtl.)

[The Potential of Open Geodata for Automated Large-Scale Land Use and Land Cover Classification](https://www.mdpi.com/2072-4292/11/19/2249/htm)
* Studie zur Nutzung von Open Data als Referenz zur LULC Klassifizierung
* anhand von Random Forest Klassifiuierung mit Landsat 7/8 


## Basisdaten Zusammenfassung

ALK (Automatisierte Liegenschaftskarte)
* digitaler Nachfolger der analogen Liegenschaftskarte/Flurkarte
* quasi Geodaten der Flurstücke
* bildet zusammen mit ALB das Liegenschaftskataster

ALB (Amtliches Liegenschaftsbuch)
* digitaler Nachfolger des Katasterbuchwerks
* quasi Attributdaten der Flurstücke
* bildet zusammen mit ALK das Liegenschaftskataster

ALKIS (Amtliches  Liegenschaftskatasterinformationssystem)
* Geobasisdaten zur Beschreibung der Liegenschaften (Flurstücke, Gebäude, Eigentumsangaben, etc.)
* Zusammenführung von ALK  und ALB
* ALKIS und ABK beruhen auf gemeinsamem Datenbestand

DGK (Deutsche Grundkarte)
* gewöhnlich 1:5000 (DGK5)
* Bindeglied zwischen Kataster und DTK25
* früher eigenständig gepflegtes Rasterdatenprodukt
* aus ALK
* DGK5 in ABK überführt
* Nachfolger aus ALKIS Daten

ABK (Amtliche Basiskarte)
* soll z.B. in NRW die DGK ablösen (weiterentwicklung der DGK)
* Schnittstelle zwischen der eigentumsorientierten Liegenschaftskarte und den topographischen Landeskartenwerken
* aus ALKIS Daten

DLM (Digitales Landschaftsmodell)
* Basis für ATKIS
* Basis-DLM (früher DLM25) 1 : 10.000-25.000
* Daten für ATKIS-DLM überwiegend aus analogen amtlichen Topographischen Karten
* Aktualisierung je nach Objektart mindestens alle 5 Jahre

ATKIS (Amtliches Topographisch Kartographisches Informationssystem)
* Geobasisdaten zur Beschreibung der Topographie der Eroberfläche (Straßen- und Schienennetz, Gewässer, Nutzungsflächen, kommunale Gebietseinheiten, Relief u. a.)
* objektbasiert als DLM (ATKIS-Bestandsdaten)
* kartographisch und generalisiert als DTK
* enthält auch DGMs und DOPs

AFIS (Amtliches Festpunktinformationssystem)
* enthält Geobasisdaten für den geodätischen Raumbezug (Lagefestpunkte, Höhenfestpunkte und Schwerefestpunkte)

AAA-Modell (AFIS-ALKIS-ATKIS-Modell)
* einheitliches Datenmodell zur Verknüpfung der Daten

CORINE LAND COVER
* 44 Klassen (37 in Deutschland)
* 1990, 2000, 2006, 2012, 2018
* Europaweit ist MMU 25ha 
* seit CLC2012 mit MMU 1ha aus LBM-DE abgeleitet
* mit MMU 5ha (seit 2020), 10ha und 25ha frei verfügbar

## Politischer Wille zur Nutzung von Fernerkundungsdaten
[BMEL](https://www.bmel.de/SharedDocs/Downloads/DE/Broschueren/Fernerkundung.html)
* Potenzial von zukünftigen Anwendungsoptionen der Fernerkundung laut TI-WO u.a.
  * Erfassung der Waldfläche und Waldflächenänderungen
  * Erfassung von Bäumen außerhalb des Waldes


