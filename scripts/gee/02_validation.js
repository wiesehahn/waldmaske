
//-----------------------------------------------------------------------------------------
// -------------------SET VARIABLES--------------------------------------------------------

//var vars = require('users/wiesehahn/waldmaske:classification/00_variable_settings');
//var assetID_ref_sampled = ee.String(vars.path).cat(ee.String(vars.name_ref_sampled));

var assetID_ref_sampled = "users/wiesehahn/waldmaske/classification/reference/lucas_sampled_de";
var usedBands = ['B2_p33','B3_p33','B4_p33','B5_p33','B6_p33','B7_p33','B8_p33','B8A_p33','B11_p33','B12_p33','NDVI_p33','NDWI_p33','NBRI_p33','NDMI_p33',
'B2_p33_1','B3_p33_1','B4_p33_1','B5_p33_1','B6_p33_1','B7_p33_1','B8_p33_1','B8A_p33_1','B11_p33_1','B12_p33_1','NDVI_p33_1','NDWI_p33_1','NBRI_p33_1','NDMI_p33_1',
'B2_p33_2','B3_p33_2','B4_p33_2','B5_p33_2','B6_p33_2','B7_p33_2','B8_p33_2','B8A_p33_2','B11_p33_2','B12_p33_2','NDVI_p33_2','NDWI_p33_2','NBRI_p33_2','NDMI_p33_2',
'B2_p33_3','B3_p33_3','B4_p33_3','B5_p33_3','B6_p33_3','B7_p33_3','B8_p33_3','B8A_p33_3','B11_p33_3','B12_p33_3','NDVI_p33_3','NDWI_p33_3','NBRI_p33_3','NDMI_p33_3'];


//-----------------------------------------------------------------------------------------
// -------------------LOAD SAMPLED REFERENCE DATA------------------------------------------


var ref_sampled = ee.Collection.loadTable(assetID_ref_sampled);
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

/* --------------------------------------------------------------------------------------
1. Tune Hyperparameters more or less around default settings using all features (bands)
  a) Number of trees
  b) Variables per Split
  c) Minimal Leaf Population

2. Build Model using best perforimg Hyperparameters from 1)

3. Perform Feature selection

4. Build Model using perforimg Hyperparameters from 1) and best performing features from 3)

5. Tune Hyperparameters again around best performing Hyperparameters from 1) and using selected features from 3(
  a) Number of trees
  b) Variables per Split
  c) Minimal Leaf Population

6. Build Model using results from 5)

7. Evaluate Model
---------------------------------------------------------------------------------------*/

// -------------------Parameter tuning I--------------------------------------------------

//Number of Trees
var numTrees = ee.List.sequence(10, 100, 10);

var accuracies = numTrees.map(function(t) {
  var classifier =  ee.Classifier.smileRandomForest({numberOfTrees:t,
                                            variablesPerSplit:2,
                                            minLeafPopulation:10,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: usedBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Number of Trees', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: numTrees
}));

// variables per split
var numVars = ee.List([2,3,5,8,12]);

var accuracies = numVars.map(function(t) {
  var classifier = ee.Classifier.smileRandomForest({numberOfTrees:50,
                                            variablesPerSplit:t,
                                            minLeafPopulation:10,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: usedBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Variables per Split', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: numVars
}));

// Min Leaf Popultaion
var minLeaf = ee.List([2,3,5,8,12]);

var accuracies = minLeaf.map(function(t) {
  var classifier = ee.Classifier.smileRandomForest({numberOfTrees:50,
                                            variablesPerSplit:10,
                                            minLeafPopulation:t,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: usedBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Minimal Leaf Population', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: minLeaf
}));


// -------------------Build Model I------------------------------------------------------

//random forest classifier with input variables as tested above
var classifier = ee.Classifier.smileRandomForest({numberOfTrees:50,
                                            variablesPerSplit:10,
                                            // https://groups.google.com/d/msg/google-earth-engine-developers/qxVRHoI_R8c/AX-mxrrDEAAJ
                                            minLeafPopulation:3,
                                            bagFraction:0.5});


// train the classifier.
var model = classifier.setOutputMode('CLASSIFICATION').train(trainingPartition, 'class', usedBands);

var dict_rf = model.explain();

print('RF Explain:',dict_rf);


// -------------------Variable Selection-------------------------------------------------

// Compute variable importance
var variable_importance_rf = ee.Feature(null, ee.Dictionary(dict_rf).get('importance'));

// Display variable importance results
var chart_rf =
  ui.Chart.feature.byProperty(variable_importance_rf)
    .setChartType('ColumnChart')
    .setOptions({
      title: 'Random Forest Variable Importance',
      legend: {position: 'none'},
      hAxis: {title: 'Bands'},
      vAxis: {title: 'Importance'}
    });

print(chart_rf);



// -------------------Build Model II------------------------------------------------------


// subselect features to most important seasons (visually from chart above)
// *_1: summer (doy 90-150)
// *_2: autumn (doy 150-270)
var subselectionBands = [
  'B2_p33_1','B3_p33_1','B4_p33_1','B5_p33_1','B6_p33_1','B7_p33_1','B8_p33_1','B8A_p33_1','B11_p33_1','B12_p33_1','NDVI_p33_1','NDWI_p33_1','NBRI_p33_1','NDMI_p33_1',
  'B2_p33_2','B3_p33_2','B4_p33_2','B5_p33_2','B6_p33_2','B7_p33_2','B8_p33_2','B8A_p33_2','B11_p33_2','B12_p33_2','NDVI_p33_2','NDWI_p33_2','NBRI_p33_2','NDMI_p33_2',
  ];

// train the classifier on subselection
var model = classifier.setOutputMode('CLASSIFICATION').train(trainingPartition, 'class', subselectionBands);
var dict_rf = model.explain();

// get first x bands by importance
var imp = ee.Dictionary(dict_rf.get('importance'));
var keys = imp.keys();
var values = imp.values();
var importantBands = keys.sort(values).reverse().slice(0,12);

print('most important bands:', importantBands);

// train the classifier with most important bands
var model = classifier.setOutputMode('CLASSIFICATION').train(trainingPartition, 'class', importantBands);



// -------------------Parameter tuning II-------------------------------------------------

//Number of Trees
var numTrees = ee.List.sequence(10, 100, 10);

var accuracies = numTrees.map(function(t) {
  var classifier =  ee.Classifier.smileRandomForest({numberOfTrees:t,
                                            variablesPerSplit:10,
                                            minLeafPopulation:3,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: importantBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Number of Trees', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: numTrees
}));

// variables per split
var numVars = ee.List([2,3,5,8,12]);

var accuracies = numVars.map(function(t) {
  var classifier = ee.Classifier.smileRandomForest({numberOfTrees:50,
                                            variablesPerSplit:t,
                                            minLeafPopulation:3,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: importantBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Variables per Split', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: numVars
}));

// Min Leaf Popultaion
var minLeaf = ee.List([2,3,5,8,12]);

var accuracies = minLeaf.map(function(t) {
  var classifier = ee.Classifier.smileRandomForest({numberOfTrees:50,
                                            variablesPerSplit:10,
                                            minLeafPopulation:t,
                                            bagFraction:0.5})
    .train({
      features: trainingPartition,
      classProperty: 'class',
      inputProperties: importantBands
    });
  return validationPartition
    .classify(classifier)
    .errorMatrix('class', 'classification')
    .accuracy();
});

print('Parameter Tuning - Minimal Leaf Population', ui.Chart.array.values({
  array: ee.Array(accuracies),
  axis: 0,
  xLabels: minLeaf
}));



// -------------------Build Model III----------------------------------------------------

//random forest classifier with input variables as tested above
var classifier = ee.Classifier.smileRandomForest({numberOfTrees:70,
                                            variablesPerSplit:3,
                                            // https://groups.google.com/d/msg/google-earth-engine-developers/qxVRHoI_R8c/AX-mxrrDEAAJ
                                            minLeafPopulation:3,
                                            bagFraction:0.5});

// train the classifier.
var model = classifier.setOutputMode('CLASSIFICATION').train(trainingPartition, 'class', importantBands);



// -------------------Validate Model----------------------------------------------------

// classify the validation data.
var validation_classification = validationPartition.classify(model);

// create error matrix
var errorMatrix = validation_classification.errorMatrix('class', 'classification');
print('Model Performance',
'predictor variables: ', importantBands,
'model', model.explain());
print('Validation Error Matrix', errorMatrix);
print('Validation overall accuracy: ', errorMatrix.accuracy());
