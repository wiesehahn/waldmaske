library(rgdal)
library(raster)
library(tidyverse)
library(spdplyr)


# load bwi data
ref_bwi <- read.csv("Y:/Jens/large-file-storage/waldmaske/reference/bwi/ref_bwi.csv", stringsAsFactors=TRUE)

# make no-forest 0
ref_bwi <- ref_bwi %>%  dplyr::mutate(Wa = replace_na(Wa, 0))

# as factor
cols <- c("BestockTypLN", "BestockTypFein", "Wa", "Begehbar", "KurzD", "LangD", "KurzD_LN", "LangD_LN", "Vbl")
ref_bwi[cols] <- lapply(ref_bwi[cols], as.factor)

# filter niedersachsen
ref_bwi <- ref_bwi %>% filter(Vbl %in% c("308", "316"))

# make spatial object
ref_bwi.sp<- SpatialPointsDataFrame(coords = ref_bwi[,c("GK3_Rechts", "GK3_Hoch")], data = ref_bwi, proj4string = CRS("+init=epsg:31467"))

# transform
ref_bwi.sp <- spTransform(ref_bwi.sp, CRS("+init=epsg:4326"))


# writeOGR(ref_bwi.sp, "./data/reference/bwi",
#          "ref_bwi", driver="ESRI Shapefile")


img.class <- raster("Y:/Jens/large-file-storage/waldmaske/classification_32unc_20200623_clipped.tif")

ref.class <- raster::extract(img.class, ref_bwi.sp, sp=TRUE)

ref.class <- ref.class %>% mutate(reference = case_when(Wa %in% c(3,4,5,10) ~ 1,
                                                        Wa == 0 ~ 0),
                                  classification = classification_32unc_20200623_clipped)

ref.class$classification <- as.factor(ref.class$classification)
ref.class$reference <- as.factor(ref.class$reference)

ref.class <- ref.class %>% mutate(result = as.factor(if_else(classification != reference,"wrong", "right")))


# error matrix
cm<- caret::confusionMatrix(data = ref.class$classification, reference = ref.class$reference)
cm.df <- as.data.frame.matrix(cm$table)

cm.df %>%
  knitr::kable("html", escape = F, rownames = T,)%>%
  kableExtra::kable_styling("hover", full_width = F)

print(cm$overall[1:2])


#vizualize
mapview::mapview(ref.class, zcol="result", col.regions = c("green", "red"))
