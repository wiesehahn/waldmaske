##___________________________________________________
##
## Script name: ci2017_ni_validation.R
##
## Purpose of script:
## perform an independent validation of forest masks
## giving accuracy metrics based on independent sample data
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2021
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2021-05-10
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





##### load and transform BWI data ####
#____________________________________________________

# load ci data
ref_ci <- read.csv("Y:/Jens/large-file-storage/waldmaske/reference/ci2017/ref_ci.csv")

# as factor
cols <- c("tnr", "enr", "vbl", "bl", "aufnbl", "wa")
ref_ci[cols] <- lapply(ref_ci[cols], as.factor)

# filter niedersachsen
ref_ci <- ref_ci %>% filter(vbl %in% c("308", "316"))

ref_ci <- st_as_sf(x = ref_ci,
                    coords = c("lon", "lat"),
                    crs = CRS("+init=epsg:4326")) %>%
  st_transform(CRS("+init=epsg:25832"))



##### extract forest mask values and convert to 1/0 (Forest/No-Forest) ####
#____________________________________________________

#convert bwi -> 0/1
ref_comp <- ref_ci %>% mutate(bwi= as.factor(ifelse(wa==0, 0, 1)))

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

#extract fnews 2015 mask values and convert to 0/1
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/niklas/Version_05/V5_TCD_2015_Germany_10m_S2Al_32632_Mdlm_TCD50_2bit_FADSL_mmu25_2_0_TCD2018_WM_V5_2_0.tif")
ref_comp$fnews2015 <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(fnews2015= as.factor(if_else(fnews2015==1, 1, 0, missing = 0)))

#extract fnews 2018 mask values and convert to 0/1
img.class <- raster("Y:/Jens/large-file-storage/waldmaske/niklas/Version_05/V5_TCD_2018_Germany_10m_S2Al_32632_Mdlm_TCD50_2bit_FADSL_mmu25_2_0.tif")
ref_comp$fnews2018 <- raster::extract(img.class, ref_comp)
ref_comp <- ref_comp %>% mutate(fnews2018= as.factor(if_else(fnews2018==1, 1, 0, missing = 0)))

#save to rda file
save(ref_comp, file = here("data/interim/ci2017_ni_extracted.rda"))



##### calculate accuracies and create table ####
#____________________________________________________

# accuracy function
accuracy <- function(forestmask){
  cm <- caret::confusionMatrix(data = ref_comp %>% dplyr::select(starts_with(forestmask)) %>% st_drop_geometry() %>% pull(), reference = ref_comp$bwi)

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
                         accuracy("fnews2015"),
                         accuracy("fnews2018"))

#save to rda file
save(comparison_table, file = here("data/interim/ci2017_ni_accuracy.rda"))


