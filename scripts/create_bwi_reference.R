library(RODBC)
library(dplyr)

# get data from data base
con <- odbcConnectAccess("C:/Users/jwiesehahn/Arbeit/data/inventory/bwi2012/bwi_all.mdb")

query <- "
SELECT b0_ecke.Tnr, b0_ecke.Enr, b0_ecke.Vbl, b3_ecke_w.Wa, b3_bestock.BestockTypFein, b3_bestock.BestockTypLN, b3_ecke_w.Begehbar
FROM (b0_ecke
LEFT JOIN b3_ecke_w ON (b0_ecke.Enr = b3_ecke_w.Enr) AND (b0_ecke.Tnr = b3_ecke_w.Tnr))
LEFT JOIN b3_bestock ON (b0_ecke.Enr = b3_bestock.Enr) AND (b0_ecke.Tnr = b3_bestock.Tnr)
WHERE (((b0_ecke.InvE3)=1));
"

data <- sqlQuery( con , query)


# get data from meta data base
con_meta <- odbcConnectAccess("C:/Users/jwiesehahn/Arbeit/data/inventory/bwi20150320_alle_metadaten/bwi20150320_alle_metadaten.mdb")

query_meta1 <- "
SELECT ICode AS BestockTypFein, KurzD, LangD
FROM x_BestockTypFein"

data_meta1 <- sqlQuery( con_meta , query_meta1)

query_meta2 <- "
SELECT ICode AS BestockTypLN, KurzD, LangD
FROM x_BestockTypLN"

data_meta2 <- sqlQuery( con_meta , query_meta2)


# get coordinate data
bwi_koordinaten_ni <- read.csv2("C:/Users/jwiesehahn/Arbeit/data/inventory/bwi_koordinaten_ni.csv")
bwi_koordinaten_ni <- bwi_koordinaten_ni %>% select(tnr,enr, GK3_Rechts, GK3_Hoch) %>% rename(Tnr=tnr, Enr=enr)


# merge data frames
dat_bwi <- merge(data, data_meta1, by="BestockTypFein", all.x = TRUE)
dat_bwi <- merge(dat_bwi, data_meta2, by="BestockTypLN", all.x = TRUE, suffixes = c("", "_LN"))
dat_bwi <- merge(dat_bwi, bwi_koordinaten_ni, by= c("Tnr", "Enr"))



#group data and get values per tree group for pure stands in Niedersachsen
bwi <- dat_bwi %>%
  mutate(BA = case_when(KurzD %in% c("KI-R", "KI-L", "KI-N") ~ "Kiefer",
                        KurzD %in% c("LA-R", "LA-L", "LA-N") ~ "Laerche",
                        KurzD %in% c("FI-R", "FI-L", "FI-N") ~ "Fichte",
                        KurzD %in% c("EI-R", "EI-L", "EI-N") ~ "Eiche",
                        KurzD %in% c("BU-R", "BU-L", "BU-N") ~ "Buche",
                        KurzD %in% c("DGL-R", "DGL-L", "DGL-N") ~ "Douglasie"))


# save file
dir.create("./data/reference/bwi", recursive =T)
write.csv(bwi, "./data/reference/bwi/ref_bwi.csv")

odbcCloseAll()
