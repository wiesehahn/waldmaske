// load classification
var classification = ee.Image.load('users/wiesehahn/waldmaske/classification/map/classification_32unc_20200623');

// load open street map highways
var osm = ee.FeatureCollection('users/wiesehahn/waldmaske/osm-ways_ni');


// load state boundary
var ni = ee.FeatureCollection('users/wiesehahn/waldsterben/ni/geodata/nuts1_ni_hb');


// mask noforest
var clas_mask = classification.updateMask(classification.eq(0));

// clip to state boundary
var clas_ni = clas_mask.clip(ni);

// buffer lines
var addBuffer = function(feature) {
  return feature.buffer(5);
};
var osmBuffered = osm.map(addBuffer);

Map.centerObject(ni, 7)


// mask image by buffered lines
var mask = ee.Image.constant(1).clipToCollection(osmBuffered).mask();
var clas_clip = clas_ni.updateMask(mask.eq(0));



Export.image.toAsset({
image: clas_clip.uint8(),
description:  'export_clipped',
assetId: 'users/wiesehahn/waldmaske/classification/map/classification_32unc_20200623_clipped',
scale: 10,
maxPixels: 1e12,
});
