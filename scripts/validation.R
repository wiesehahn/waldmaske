library(rgdal)


# load bwi data
ref_bwi <- read.csv("./data/reference/bwi/ref_bwi.csv", stringsAsFactors=TRUE)

# as factor
cols <- c("BestockTypLN", "BestockTypFein", "Wa", "Begehbar", "KurzD", "LangD", "KurzD_LN", "LangD_LN")
ref_bwi[cols] <- lapply(ref_bwi[cols], as.factor)


# make spatial object
ref_bwi.sp<- SpatialPointsDataFrame(coords = ref_bwi[,c("GK3_Rechts", "GK3_Hoch")], data = ref_bwi, proj4string = CRS("+init=epsg:31467"))

# transform
ref_bwi.sp <- spTransform(ref_bwi.sp, CRS("+init=epsg:4326"))




writeOGR(ref_bwi.sp, "./data/reference/bwi",
         "ref_bwi", driver="ESRI Shapefile")



img.class <- raster("C:/Users/jwiesehahn/Arbeit/projects/waldmaske/data/classification/classification_32unc_20200623_clipped.tif")


ref.class.bwi <- raster::extract(img.class, ref_bwi.sp, df=TRUE)

ref.class.bwi <- merge(ref.class.bwi, ref_bwi.sp@data ,by.x="ID", by.y="X", all = TRUE)

# rename columns
colnames(ref.class.bwi)[2] <- "classification"

ref.class.bwi <- ref.class.bwi %>% rename(reference = BA)



#mapview(ref.class.sp, zcol="reference", col.regions = pal.ref)

library(spdplyr)
misclassified <- ref.class.bwi %>% mutate(result = if_else(classification != reference,"wrong", "right"))
#mapview(misclassified, zcol="result", col.regions = c("green", "red"))
