# Random Forest Classification

Scripts used to perform a random forest classification of forest and non-forest areas within Google Earth Engine Environment.


Links below will redirect to scripts in GEE (most recent version)

[*00_variable_settings*](https://code.earthengine.google.com/?accept_repo=users%2Fwiesehahn%2Fwaldmaske&scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F00_variable_settings)
(defines overall variables like feature-bands, time-periods and paths)

[*01_reference_export*](https://code.earthengine.google.com/?scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F01_reference_export)
(collects reference data for defined variables and save as asset)

[*02_validation*](https://code.earthengine.google.com/?scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F02_validation)
(builds, tunes and validates the model)

[*03_classification*](https://code.earthengine.google.com/?scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F03_classification)
(uses tuned model to claasify region of interest, e.g. testarea)

[*04_display_results*](https://code.earthengine.google.com/?scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F04_display_results)
(visualizes the classification)

[*05_mask_streets*](https://code.earthengine.google.com/?scriptPath=users%2Fwiesehahn%2Fwaldmaske%3Aclassification%2F05_mask_streets)
(uses osm data to mask ways)

*Validation overall accuracy:
0.9715045592705167*
