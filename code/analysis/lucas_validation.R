##___________________________________________________
##
## Script name: validation.R
##
## Purpose of script:
## perform an independent validation of forest masks
## giving accuracy metrics based on independent sample data
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2021
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2021-04-23
##
## Notes:
##
##
##___________________________________________________

library(rgdal)
library(raster)
library(tidyverse)
library(spdplyr)
library(sf)
library(here)

##___________________________________________________

## load functions into memory
# source("code/functions/some_script.R")

##___________________________________________________





##### load and transform LUCAS data ####
#___________________________________________________

# load LUCAS data
ref_lucas <- read.csv("Y:/Jens/large-file-storage/waldmaske/reference/lucas/lucas_filtered.csv", stringsAsFactors=TRUE)

# set crs and reproject
ref_lucas <- st_as_sf(x = ref_lucas,
                        coords = c("longitude", "latitude"),
                        crs = CRS("+init=epsg:4326")) %>%
  st_transform(CRS("+init=epsg:25832"))

# load Niedersachsen and reproject
niedersachsen <- readRDS(url("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_DEU_1_sf.rds")) %>%
  filter(NAME_1 == "Niedersachsen") %>%
  st_transform(st_crs(ref_lucas))

# clip LUCAS to NI
ref_lucas <- ref_lucas %>%
  st_intersection(niedersachsen) %>%
  select(POINT_ID, class, label)


##### extract forest mask values and convert to 1/0 (Forest/No-Forest) ####
#____________________________________________________

#convert lucas -> 0/1
ref_comp <- ref_lucas %>% mutate(lucas= as.factor(ifelse(class %in% c(0,3,4), 1, 0)))

#extract own mask values
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/classification_32unc_20200623_clipped.tif")
ref_comp$rf_osm <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(rf_osm= as.factor(rf_osm))

#extract mundialis mask values and convert to 0/1
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/mundialis_incora/classification_map_germany_2019_v0_1.tif")
ref_comp$mundialis <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(mundialis= as.factor(ifelse(mundialis==10, 1, 0)))

#extract copernicus mask values and convert to 0/1
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/copernicus_hrl/DLT_2018_010m_de_03035_v020/DLT_2018_010m_de_v020.tif")
ref_comp$copernicus_hrl <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(copernicus_hrl= as.factor(ifelse(copernicus_hrl==0, 0, 1)))

#extract basis-dlm values and convert to 0/1
#ogrListLayers("K:/aktiver_datenbestand/ni/lverm/basis_dlm/stand_2019_0604/daten/20180930_nba_bkg_bdlm_ni_V4.2.gdb")
veg02 <- st_read("K:/aktiver_datenbestand/ni/lverm/basis_dlm/stand_2019_0604/daten/20180930_nba_bkg_bdlm_ni_V4.2.gdb", layer = "veg02_f")
veg03 <- st_read("K:/aktiver_datenbestand/ni/lverm/basis_dlm/stand_2019_0604/daten/20180930_nba_bkg_bdlm_ni_V4.2.gdb", layer = "veg03_f")

dlm <- rbind(veg02 %>% dplyr::select(OBJART_TXT, Shape),
             veg03 %>% dplyr::select(OBJART_TXT, Shape) %>%
                       filter(OBJART_TXT=="AX_Gehoelz"))

ref_comp = st_join(ref_comp, dlm) %>%
  mutate(basis_dlm = as.factor(ifelse(is.na(OBJART_TXT), 0, 1))) %>%
  dplyr::select(-OBJART_TXT)

#extract fnews mask values and convert to 0/1
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/niklas/Version_05/V5_TCD_2015_Germany_10m_S2Al_32632_Mdlm_TCD50_2bit_FADSL_mmu25_2_0_TCD2018_WM_V5_2_0.tif")
ref_comp$fnews <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(fnews= as.factor(if_else(fnews==1, 1, 0, missing = 0)))

#save to rda file
save(ref_comp, file = here("data/interim/lucas_ni_extracted.rda"))

##### calculate accuracies and create table ####
#____________________________________________________

# accuracy function
accuracy <- function(forestmask){
  cm <- caret::confusionMatrix(data = ref_comp %>% dplyr::select(starts_with(forestmask)) %>% st_drop_geometry() %>% pull(), reference = ref_comp$lucas)

  df <- data.frame(Waldmaske = forestmask) %>%
    mutate(Datenpunkte = sum(cm$table),
           OA = cm$overall[[1]],
           UA_Nichtwald = cm$table[1,1]/(cm$table[1,1]+cm$table[1,2]),
           UA_Wald = cm$table[2,2]/(cm$table[2,1]+cm$table[2,2]),
           PA_Nichtwald = cm$table[1,1]/(cm$table[1,1]+cm$table[2,1]),
           PA_Wald = cm$table[2,2]/(cm$table[1,2]+cm$table[2,2]))
  return(df)
}

comparison_table<- rbind(accuracy("basis_dlm"),
             accuracy("mundialis"),
             accuracy("copernicus_hrl"),
             accuracy("rf_osm"),
             accuracy("fnews"))

#save to rda file
save(comparison_table, file = here("data/interim/lucas_ni_accuracy.rda"))

