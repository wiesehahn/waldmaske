
//-----------------------------------------------------------------------------------------
// -------------------SET VARIABLES--------------------------------------------------------

var vars = require('users/wiesehahn/waldmaske:classification/00_variable_settings');

var gaul = ee.FeatureCollection("FAO/GAUL_SIMPLIFIED_500m/2015/level1");
  
var DE = gaul.filter(ee.Filter.eq('ADM0_NAME', 'Germany'));

//var HB = DE.filter(ee.Filter.eq('ADM1_NAME', 'Bremen'));
//var NI = DE.filter(ee.Filter.eq('ADM1_NAME', 'Niedersachsen'));

var roi = DE;

var assetID_ref_raw = ee.String(vars.path).cat(ee.String(vars.name_ref_raw));
var assetID_ref_sampled = ee.String(vars.path).cat(ee.String(vars.name_ref_sampled));


//-----------------------------------------------------------------------------------------
// -------------------LOAD REFERENCE DATA--------------------------------------------------

var ref_raw = ee.Collection.loadTable(assetID_ref_raw.getInfo());
var ref_raw = ref_raw.filterBounds(roi);
var label = 'class';

print('number of reference points', ref_raw.size());

//-----------------------------------------------------------------------------------------
// -------------------SENTINEL-2 IMAGE COLLECTION------------------------------------------

//++++ FUNCTIONS ++++//

// Function to get S2-Surface Reflectance Collection and join Cloud Mask
var getS2_SR_CLOUD_PROBABILITY = function () {
  var innerJoined = ee.Join.inner().apply({
    primary: ee.ImageCollection("COPERNICUS/S2_SR"),
    secondary: ee.ImageCollection("COPERNICUS/S2_CLOUD_PROBABILITY"),
    condition: ee.Filter.equals({
      leftField: 'system:index',
      rightField: 'system:index'
    })
  });
  var mergeImageBands = function (joinResult) {
    return ee.Image(joinResult.get('primary'))
          .addBands(joinResult.get('secondary'));
  };
  var newCollection = innerJoined.map(mergeImageBands);
  return ee.ImageCollection(newCollection)
  .select(['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12', 'SCL', 'probability']);
};


// Function to mask clouds using Sentinel Hub cloud mask and mask cloud shadows using SCL band.
var maskClouds = function(image) {
  var cloudProbabilityThreshold = 40;
  var scl = image.select('SCL'); 
  var shadow = scl.eq(3); // 3 = cloud shadow
  var cloudMask = image.select('probability').lt(cloudProbabilityThreshold).and((shadow).neq(1));
  return image.updateMask(cloudMask);
};

// add indices
var addIndices = function(image) {
    var ndvi = image.normalizedDifference(['B8', 'B4']).rename("NDVI"); // normalized difference vegetation index
    var ndwi = image.normalizedDifference(['B3', 'B8']).rename("NDWI"); // normalized difference water index
    var nbri = image.normalizedDifference(['B8', 'B12']).rename("NBRI"); // normalized burn ratio index
    var ndmi = image.normalizedDifference(['B8', 'B11']).rename("NDMI"); // normalized difference moisture index

  return(image.addBands(ndvi).addBands(ndwi).addBands(nbri).addBands(ndmi).float());
};

// reduce collection per season
var createSeasonCol = function(collection, doy_start, doy_end){
  return collection
  .filter(ee.Filter.calendarRange(doy_start, doy_end, 'day_of_year'))
  .map(maskClouds)
  .select(['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12'])
  .map(addIndices)
  .reduce(ee.Reducer.percentile([33]),16);
};


//++++ END OF FUNCTIONS ++++//

// Load Sentinel-2 surface reflectance data 
var s2 = getS2_SR_CLOUD_PROBABILITY()
  .filter(ee.Filter.calendarRange(2019,2019, 'year'))
  .filterBounds(roi);

// reduce per season
var season1 = createSeasonCol(s2, vars.start1, vars.end1);
var season2 = createSeasonCol(s2, vars.start2, vars.end2);
var season3 = createSeasonCol(s2, vars.start3, vars.end3);
var season4 = createSeasonCol(s2, vars.start4, vars.end4);

// merge in one image
var composite = season1.addBands(season2).addBands(season3).addBands(season4);

print('number of image bands', composite.bandNames().size());

//-----------------------------------------------------------------------------------------
// -------------------SAMPLE REFERENCE DATA------------------------------------------------

// export reference data to avoid timeouts

var reference = composite.sampleRegions({ 
   collection: ref_raw,
   properties: [label],
   scale: 10,
   tileScale: 16,
   geometries: true
});

Export.table.toAsset({
  collection: reference,
  description: 'export_reference_to_asset',
  assetId: assetID_ref_sampled.getInfo()});

