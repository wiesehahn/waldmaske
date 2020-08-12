//-------------------------------SET LOADING OPTIONS---------------------------------------------------------------
var classification_path = 'users/wiesehahn/waldmaske/classification/';
var assetID_date = '20200519';

//--------------------------------CLASSIFICATIONS-------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

var assetID_classification = ee.String(classification_path).cat(ee.String('map/classification_32unc_')).cat(ee.String(assetID_date));
var classification = ee.Image.load(assetID_classification.getInfo());

//--------------------------------STYLE AND LEGEND------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

// style and legend for 2 classes
var colors = ['309330',
              'e6e06a'];

var names = ["0 - Wald",
             "1 - Nichtwald"]; 

var palette = ee.List(colors);

// add legend
var legend = ui.Panel({style: {position: 'bottom-left'}}); 
  legend.add(ui.Label({   
  value: "Land Cover Classification",   
  style: {     
    fontWeight: 'bold',     
    fontSize: '16px',     
    margin: '0 0 4px 0',     
    padding: '0px'   
    } 
  })); 
  
// Iterate classification legend entries 
var entry; for (var x = 0; x<2; x++){   
  entry = [     
    ui.Label({style:{color:colors[x],margin: '0 0 4px 0'}, value: 'o'}),
    ui.Label({       
      value: names[x],       
      style: {         
        margin: '0 0 4px 4px'  
      }     
    })   
    ];   
    legend.add(ui.Panel(entry, ui.Panel.Layout.Flow('horizontal'))); } 




//--------------------------------VISUALIZATION---------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

 // mapping
 Map.add(legend);
 Map.centerObject(classification,9);
 
 // classifications 
 Map.addLayer(classification, {min: 0, max: 1, palette: colors}, 'classification - S2 (2 classes)', true);

 
