Notes on USGS raster stats API
==============================

Step 1: exercise the process_product() function by itself
```
# Test the code that backs the usgs_get_stats.R 
source("process_stats.R")

geojson <- '{"type": "FeatureCollection","features": [{"type":"Feature","geometry":{"type":"Polygon", "coordinates":[[[-113.7708501815736,44.02484886308309],[-113.72827816008923,44.012998290355185],[-113.72827816008923,43.989290038218556],[-113.76947689055797,43.96557231286773],[-113.81067562102677,43.9784205904029],[-113.81479549407364,44.01892387235876],[-113.80655574797986,44.03867153698515],[-113.7708501815736,44.02484886308309]]],"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]}, "properties":{"OBJECTID":1},"id":0, "crs":{"type":"link","properties":{"href":"http://spatialreference.org/ref/sr-org/6928/ogcwkt/","type":"ogcwkt"}},"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]},],}'
product <- "litter"
year <- "1985"

process_product(yr = 1985, tmt = geojson, product = "litter")
```

Step 2: publish the API and figure out the request syntax

```
curl -X POST "http://posit2:3939/usgs_api/get_stats?yr=1985&tmt=%7B%22type%22%3A%20%22FeatureCollection%22%2C%22features%22%3A%20%5B%7B%22type%22%3A%22Feature%22%2C%22geometry%22%3A%7B%22type%22%3A%22Polygon%22%2C%20%22coordinates%22%3A%5B%5B%5B-113.7708501815736%2C44.02484886308309%5D%2C%5B-113.72827816008923%2C44.012998290355185%5D%2C%5B-113.72827816008923%2C43.989290038218556%5D%2C%5B-113.76947689055797%2C43.96557231286773%5D%2C%5B-113.81067562102677%2C43.9784205904029%5D%2C%5B-113.81479549407364%2C44.01892387235876%5D%2C%5B-113.80655574797986%2C44.03867153698515%5D%2C%5B-113.7708501815736%2C44.02484886308309%5D%5D%5D%2C%22bbox%22%3A%5B-113.81479549407364%2C43.96557231286773%2C-113.72827816008923%2C44.03867153698515%5D%7D%2C%20%22properties%22%3A%7B%22OBJECTID%22%3A1%7D%2C%22id%22%3A0%2C%20%22crs%22%3A%7B%22type%22%3A%22link%22%2C%22properties%22%3A%7B%22href%22%3A%22http%3A%2F%2Fspatialreference.org%2Fref%2Fsr-org%2F6928%2Fogcwkt%2F%22%2C%22type%22%3A%22ogcwkt%22%7D%7D%2C%22bbox%22%3A%5B-113.81479549407364%2C43.96557231286773%2C-113.72827816008923%2C44.03867153698515%5D%7D%2C%5D%2C%7D&product=litter" -H  "accept: application/json" -d ""
```

Step 3: Write a function that can pass in the request and parse the response from the API, initially single-threaded

```
library(foreach)
source("get_api_stats.R")

years <- c(1985:2021)
years <- c(1985:1990)

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
results <- foreach(i=years, 
                   .combine = rbind,
                   .packages = c("jsonlite", "httr", "tibble")) %do% {
                   get_api_stats(yr=i, tmt=tmt, product = "litter")
}

print(results)
```

Step 4: Parallelize and go to the races

- makeCluster(20) = 15.89927 secs for all years, one product
- makeCluster(16) = 17.7 secs 
- makeCluster(12) = 18.04021 secs
- makeCluster(8) = 22.11904 secs
- makeCluster(4) = 35.27146 secs
- makeCluster(1) = 2.020714 mins

