
# read german LUCAS data from web source
lucas <- read.csv(url("https://ec.europa.eu/eurostat/cache/lucas/DE_2018_20200213.CSV"))

# filter data similar to [Weigand et. al, 2020](https://www.sciencedirect.com/science/article/pii/S0303243419307317)
library("dplyr")
lucas_filtered <- lucas %>%
  filter(
  # landcover not equal to certain classes
    !LC1 %in% c("A13", "A30", "B55", "B71", "B72", "B73", "B74", "B75",  "B83", "D10", "E10", "E30", "F40", "G50", "H21", "H22", "H23", "A22"),
  # plots with certain cover
    LC1_PERC > 75,
  #plots with one landcover only
    LC2 == 8,
  # patches >= 0.1 ha
    PARCEL_AREA_HA >1,
  # forest patches wider than 20m
    FEATURE_WIDTH != 1,
  # only plots assessed on the point
    OBS_DIRECT == 1) %>%
  # merge classes
  mutate(
    class = as.numeric(case_when(
      startsWith(as.character(LC1), "C3")            ~ 0,
      startsWith(as.character(LC1), "A")             ~ 1,
      LC1 %in% c("F10", "F20", "F30")                ~ 2,
      LC1 %in% c("C10", "B71", "B72", "B73", "B74")  ~ 3,
      LC1 %in% c("C21", "C22", "C23")                ~ 4,
      LC1 %in% c("B84", "D20", "E20", "H11", "H12")  ~ 5,
      startsWith(as.character(LC1), "B")             ~ 6,
      startsWith(as.character(LC1), "G")             ~ 7,
      TRUE                                           ~ 99
    )),
    label = as.factor(case_when(
      startsWith(as.character(LC1), "C3")            ~ "T3",
      startsWith(as.character(LC1), "A")             ~ "A",
      LC1 %in% c("F10", "F20", "F30")                ~ "S",
      LC1 %in% c("C10", "B71", "B72", "B73", "B74")  ~ "T1",
      LC1 %in% c("C21", "C22", "C23")                ~ "T2",
      LC1 %in% c("B84", "D20", "E20", "H11", "H12")  ~ "V1",
      startsWith(as.character(LC1), "B")             ~ "V2",
      startsWith(as.character(LC1), "G")             ~ "W",
      TRUE                                           ~ "other"
    )))



# save filtered data
lucas_filtered %>%
  select(POINT_ID, latitude = TH_LAT, longitude = TH_LONG, class, label) %>%
  write.csv(.,file = "Y:/Jens/large-file-storage/waldmaske/reference/lucas/lucas_filtered.csv", row.names = FALSE)

