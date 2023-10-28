# get_api_stats.R

# Makes a request from plumber API with several parameters

library(httr)
library(jsonlite)
library(tibble)

get_api_stats <- function(yr = "1985",
                          tmt = '{"type": "FeatureCollection","features": [{"type":"Feature","geometry":{"type":"Polygon", "coordinates":[[[-113.7708501815736,44.02484886308309],[-113.72827816008923,44.012998290355185],[-113.72827816008923,43.989290038218556],[-113.76947689055797,43.96557231286773],[-113.81067562102677,43.9784205904029],[-113.81479549407364,44.01892387235876],[-113.80655574797986,44.03867153698515],[-113.7708501815736,44.02484886308309]]],"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]}, "properties":{"OBJECTID":1},"id":0, "crs":{"type":"link","properties":{"href":"http://spatialreference.org/ref/sr-org/6928/ogcwkt/","type":"ogcwkt"}},"bbox":[-113.81479549407364,43.96557231286773,-113.72827816008923,44.03867153698515]},],}',
                          product = "litter") {
  # Build the query from the parameters that are passed in
  baseURL <- "http://posit2:3939/usgs_api/get_stats?"
  query <- sprintf("yr=%s&tmt=%s&product=%s", yr, tmt, product)
  
  POST_response <- httr::POST(
    "http://posit2:3939/usgs_api/get_stats?",
    add_headers(
      "accept: application/json"
    ),
    body = query
  )
  
  response_json <- httr::content(POST_response,
                                 "text", 
                                 encoding = "UTF-8")
  
  response_data <- jsonlite::fromJSON(response_json,
                                      simplifyVector = TRUE,
                                      flatten = FALSE)
  
  return( tibble::rownames_to_column(response_data, "name") )
}


