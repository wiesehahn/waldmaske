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
## Date Created: 2021-04-09
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

# load bwi data
ref_bwi <- read.csv("Y:/Jens/large-file-storage/waldmaske/reference/bwi/ref_bwi.csv", stringsAsFactors=TRUE) %>%
  # make no-forest 0
  dplyr::mutate(Wa = replace_na(Wa, 0))

# as factor
cols <- c("BestockTypLN", "BestockTypFein", "Wa", "Begehbar", "KurzD", "LangD", "KurzD_LN", "LangD_LN", "Vbl")
ref_bwi[cols] <- lapply(ref_bwi[cols], as.factor)

# filter niedersachsen
ref_bwi <- ref_bwi %>% filter(Vbl %in% c("308", "316"))

ref_bwi <- st_as_sf(x = ref_bwi,
                        coords = c("GK3_Rechts", "GK3_Hoch"),
                        crs = CRS("+init=epsg:31467")) %>%
  st_transform(CRS("+init=epsg:25832"))



# writeOGR(ref_bwi, "./data/reference/bwi",
#          "ref_bwi", driver="ESRI Shapefile")



##### extract forest mask values and convert to 1/0 (Forest/No-Forest) ####
#____________________________________________________

#convert bwi -> 0/1
ref_comp <- ref_bwi %>% mutate(bwi= as.factor(ifelse(Wa==0, 0, 1)))

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

dlm <- rbind(veg02 %>% select(OBJART_TXT, Shape),
             veg03 %>% select(OBJART_TXT, Shape) %>%
                       filter(OBJART_TXT=="AX_Gehoelz"))

ref_comp = st_join(ref_comp, dlm) %>%
  mutate(basis_dlm = as.factor(ifelse(is.na(OBJART_TXT), 0, 1))) %>%
  select(-OBJART_TXT)

#save to rda file
save(ref_comp, file = here("data/interim/bwi_ni_extracted.rda"))



##### calculate accuracies and create table ####
#____________________________________________________

# accuracy function
accuracy <- function(forestmask){
  cm <- caret::confusionMatrix(data = ref_comp %>% select(starts_with(forestmask)) %>% st_drop_geometry() %>% pull(), reference = ref_comp$bwi)

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
             accuracy("rf_osm"))

#save to rda file
save(comparison_table, file = here("data/interim/bwi_ni_accuracy.rda"))


