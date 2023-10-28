# usgs_get_stats.R

# Pulls back stats on specific rasters

library(plumber)
library(dplyr)
source("process_stats.R")

#Pre-load some defaults
yr <- "1985"
tmt <- '{"type": "FeatureCollection","features": [{"type":"Feature","geometry":{"type":"Polygon", "coordinates":[[[-113.7708501815736,44.02484886308309],[-113.72827816008923,44.012998290355185],[-113.72827816008923,43.989290038218556],[-113.76947689055797,43.96557231286773],[-113.81067562102677,43.9784205904029],[-113.81479549407364,44.01892387235876],[-113.80655574797986,44.03867153698515],[-113.7708501815736,44.02484886308309]]],"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]}, "properties":{"OBJECTID":1},"id":0, "crs":{"type":"link","properties":{"href":"http://spatialreference.org/ref/sr-org/6928/ogcwkt/","type":"ogcwkt"}},"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]},],}'
product <- "litter"

#* Return USGS Raster Stats
#* @param yr
#* @param tmt
#* @param product
#* @serializer json list(na="string")
#* @post /get_stats
function(yr = yr,
         tmt = tmt,
         product = product) {
  return( process_product(yr = yr, 
                          tmt = tmt, 
                          product = product) 
  )
}
