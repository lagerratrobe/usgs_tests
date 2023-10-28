# Tests the entire workflow

library(foreach)
library(doParallel)
source("get_api_stats.R")

years <- c(1985:2021)

products <- c('litter', 
              'non_sagebrush_shrub', 
              'perennial_herbaceous', 
              'shrub', 
              'tree', 
              'herbaceous', 
              'sagebrush', 
              'bare_ground', 
              'annual_herbaceous')

# Treatment is going to be the same for all of these
tmt = '{"type": "FeatureCollection","features": [{"type":"Feature","geometry":{"type":"Polygon", "coordinates":[[[-113.7708501815736,44.02484886308309],[-113.72827816008923,44.012998290355185],[-113.72827816008923,43.989290038218556],[-113.76947689055797,43.96557231286773],[-113.81067562102677,43.9784205904029],[-113.81479549407364,44.01892387235876],[-113.80655574797986,44.03867153698515],[-113.7708501815736,44.02484886308309]]],"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]}, "properties":{"OBJECTID":1},"id":0, "crs":{"type":"link","properties":{"href":"http://spatialreference.org/ref/sr-org/6928/ogcwkt/","type":"ogcwkt"}},"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]},],}'

# get back some results
{
  t1 <- Sys.time()
  cl <- makeCluster(1)
  registerDoParallel(cl)
  
  results <- foreach(i=years, 
                     .combine = rbind,
                     .packages = c("jsonlite", "httr", "tibble")) %dopar% {
                       # actual API call is being made here
                       get_api_stats(yr=i, tmt=tmt, product = "litter")
                     }
  stopCluster(cl)
  t2 <- Sys.time()
  print(t2 - t1)
}
