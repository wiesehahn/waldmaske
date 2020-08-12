// --------------------------------------------------------------------------------------
// -------------------VARIABLE SELECTION-------------------------------------------------


// set bandnames to use in classification as prediction variables.
// choose from ['B2','B3','B4','B5','B6','B7','B8','B8A','B11','B12','NDVI','NDWI','NBRI','NDMI','SAVI'
//             ,'VV','VH','VV_VH','VV_variance','VH_variance'].
//exports.usedBands = ['B2','B3','B4','B8'];

// B*_p33 -> 33 percentile from doy 1-90
// B*_p33_1 -> 33 percentile from doy 90-150
// B*_p33_2 -> 33 percentile from doy 150-270
// B*_p33_3 -> 33 percentile from doy 270-330
exports.usedBands = ['B2_p33','B3_p33','B4_p33','B5_p33','B6_p33','B7_p33','B8_p33','B8A_p33','B11_p33','B12_p33','NDVI_p33','NDWI_p33','NBRI_p33','NDMI_p33',
'B2_p33_1','B3_p33_1','B4_p33_1','B5_p33_1','B6_p33_1','B7_p33_1','B8_p33_1','B8A_p33_1','B11_p33_1','B12_p33_1','NDVI_p33_1','NDWI_p33_1','NBRI_p33_1','NDMI_p33_1',
'B2_p33_2','B3_p33_2','B4_p33_2','B5_p33_2','B6_p33_2','B7_p33_2','B8_p33_2','B8A_p33_2','B11_p33_2','B12_p33_2','NDVI_p33_2','NDWI_p33_2','NBRI_p33_2','NDMI_p33_2',
'B2_p33_3','B3_p33_3','B4_p33_3','B5_p33_3','B6_p33_3','B7_p33_3','B8_p33_3','B8A_p33_3','B11_p33_3','B12_p33_3','NDVI_p33_3','NDWI_p33_3','NBRI_p33_3','NDMI_p33_3'];


// set date range for composite creation.
// season 1
exports.start1 = ee.Number(1);
exports.end1 = ee.Number(90);
// season 2
exports.start2 = ee.Number(90);
exports.end2 = ee.Number(150);
// season 3
exports.start3 = ee.Number(150);
exports.end3 = ee.Number(270);
// season 4
exports.start4 = ee.Number(270);
exports.end4 = ee.Number(330);



// testarea for classification
exports.testarea = ee.Geometry.Polygon(
        [[[9.940686323657957, 51.5633863622234],
          [9.940686323657957, 51.504442609479455],
          [10.057416059986082, 51.504442609479455],
          [10.057416059986082, 51.5633863622234]]], null, false);


// the path where to store results.
// used in create_reference to save dataset as asset.
// used in create_classification_model to load dataset
exports.path = 'users/wiesehahn/waldmaske/classification/';
exports.name_ref_raw = 'reference/lucas_filtered';
exports.name_ref_sampled = "reference/lucas_sampled_de";
exports.name_map = 'map/classification_test_sample_lucas';

// for map export name will be path/classification_date (e.g.users/wiesehahn/classification_20190521)
exports.assetID_date = '20200511';
