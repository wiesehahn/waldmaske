
//-----------------------------------------------------------------------------------------
// -------------------SET VARIABLES--------------------------------------------------------

var vars = require('users/wiesehahn/waldmaske:classification/00_variable_settings');

var assetID_ref_sampled = ee.String(vars.path).cat(ee.String(vars.name_ref_sampled));

var roi = vars.testarea;

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
  .filterMetadata('MGRS_TILE', 'equals', '32UNC')
  //.filterBounds(roi);

// reduce per season
var season1 = createSeasonCol(s2, vars.start1, vars.end1);
var season2 = createSeasonCol(s2, vars.start2, vars.end2);
var season3 = createSeasonCol(s2, vars.start3, vars.end3);
var season4 = createSeasonCol(s2, vars.start4, vars.end4);

// merge in one image
var composite = season1.addBands(season2).addBands(season3).addBands(season4);



//-----------------------------------------------------------------------------------------
// -------------------LOAD SAMPLED REFERENCE DATA------------------------------------------


var ref_sampled = ee.Collection.loadTable(assetID_ref_sampled.getInfo());
var label = 'class';

// split reference dataset in training and validation data.
var reference_random = ref_sampled.randomColumn('random');

// remap values in two classes (forest/ no-forest)
var reference_random = reference_random.remap({
  // [0:T3, 1:A, 2:S, 3:T1, 4:T2, 5:V1, 6:V2, 7:W]
  lookupIn:  [0,1,2,3,4,5,6,7], 
  // [0:Forest, 1:No-Forest]
  lookupOut: [0,1,1,0,0,1,1,1],
  columnName: 'class'});

var split = 0.7;  // 70% training, 30% validation.
var trainingPartition = reference_random.filter(ee.Filter.lt('random', split));
var validationPartition = reference_random.filter(ee.Filter.gte('random', split));


// --------------------------------------------------------------------------------------
// -------------------BUILD MODEL--------------------------------------------------------

// most important features as tested in '02_validation'
var importantBands = [
  "B3_p33_2",
  "NDWI_p33_1",
  "NDVI_p33_1",
  "B8_p33_1",
  "B5_p33_2",
  "NBRI_p33_1",
  "NDVI_p33_2",
  "NBRI_p33_2",
  "B6_p33_1",
  "B8A_p33_1",
  "B2_p33_2",
  "B7_p33_1"
];

//random forest classifier with input variables as tested in '02_validation'
var classifier = ee.Classifier.smileRandomForest({numberOfTrees:70,
                                            variablesPerSplit:3,
                                            minLeafPopulation:3, 
                                            bagFraction:0.5});

// train the classifier. 
var model = classifier.setOutputMode('CLASSIFICATION').train(trainingPartition, 'class', importantBands);



// --------------------------------------------------------------------------------------
// -------------------CLASSIFICATION-----------------------------------------------------


var composite = composite.select(importantBands);

// classify the image composite
var classified = composite.classify(model); 

// the path and name for the reference dataset.
// used in create_reference to save dataset as asset.
// used in create_classification_model to load dataset
var classification_path = 'users/wiesehahn/waldmaske/classification/';
// for map export name will be path/classification_date (e.g.users/wiesehahn/waldmaske/classification/classification_20190521)
var assetID_date = '20200519';
// export classification map
var assetID = ee.String(classification_path).cat(ee.String('map/classification_32unc_')).cat(ee.String(assetID_date));

Export.image.toAsset({
image: classified.uint8(),
description:  'Classification',
assetId: assetID.getInfo(), 
//region: roi,
scale: 10,
maxPixels: 1e12,
});



Map.centerObject(roi,8);
Map.addLayer(roi);


