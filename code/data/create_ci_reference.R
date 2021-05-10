##___________________________________________________
##
## Script name: create_ci_reference.R
##
## Purpose of script: create reference data set from forest inventory data after carbon inventory 2017.
##
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

## use renv for reproducability

## run `renv::init()` at project start inside the project directory to initialze
## run `renv::snapshot()` to save the project-local library's state (in renv.lock)
## run `renv::history()` to view the git history of the lockfile
## run `renv::revert(commit = "abc123")` to revert the lockfile
## run `renv::restore()` to restore the project-local library's state (download and re-install packages)

## In short: use renv::init() to initialize your project library, and use
## renv::snapshot() / renv::restore() to save and load the state of your library.

##___________________________________________________

## install and load required packages

## to install packages use: (better than install.packages())
# renv::install("packagename")

renv::restore()
library(spdplyr)
library(sf)
library(here)

##___________________________________________________

## load functions into memory
# source("code/functions/some_script.R")

##___________________________________________________




##### load and transform BWI data (CI 2017) ####
#____________________________________________________

ecke <- read.csv2("Y:/Jens/large-file-storage/waldmaske/reference/ci2017/b3_ecke.csv")

vorkl <- read.csv2("Y:/Jens/large-file-storage/waldmaske/reference/ci2017/b3f_ecke_vorkl.csv")

gps <- read.csv2("Y:/Jens/large-file-storage/waldmaske/reference/ci2017/bv_gps.csv")

# merge data
ci <- ecke %>%
  left_join(vorkl, by = c("tnr", "enr", "vbl")) %>%
  left_join(gps, by = c("tnr", "enr", "vbl"))


# as factor
cols <- c("vbl", "bl", "aufnbl", "wa")
ci[cols] <- lapply(ci[cols], as.factor)

# filter niedersachsen and valid forest/no-forest
ci <- ci %>% filter(vbl %in% c("308", "316"),
                    wa %in% c("0", "3", "4", "5"))



# calculate distance between soll and ist coordinates
soll <- st_as_sf(x = ci,
                 coords = c("soll_x_gk3", "soll_y_gk3"),
                 crs = CRS("+init=epsg:31467")) %>%
  st_transform(CRS("+init=epsg:25832"))


ist <- st_as_sf(x = ci,
                coords = c("lon_med", "lat_med"),
                crs = CRS("+init=epsg:4326"),
                na.fail = FALSE) %>%
  st_transform(CRS("+init=epsg:25832"))


ci$distance <- as.numeric(st_distance(soll, ist, by_element = TRUE))

# use ist-coordinates if distance from soll-coordinate is less than 50m, otherwise use soll-coordinate
# (some coordinates are most likely measured for the wrong corner and hence are app 150m away from soll-coordinate)
ci <- ci %>% mutate(lon = if_else(distance < 50, lon_med, soll_x_wgs84, missing = soll_x_wgs84),
                      lat = if_else(distance < 50, lat_med, soll_y_wgs84, missing = soll_y_wgs84))



ci <- ci %>% select(tnr, enr, vbl, bl, aufnbl, wa, lon, lat)


# save file
dir.create("Y:/Jens/large-file-storage/waldmaske/reference/ci2017", recursive =T)
write.csv(ci, "Y:/Jens/large-file-storage/waldmaske/reference/ci2017/ref_ci.csv")
