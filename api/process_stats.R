#first, load up some libs
library(sf)
library(terra)
library(geojsonsf)
library(jsonlite)
library(iterators)


gdalinopts <- "-co NUM_THREADS=8 -co SPARSE_OK=YES"

years <- c(1985:2021)
prefix <-
  c(
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/litter/rcmap_litter_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/shrub/rcmap_shrub_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/tree/rcmap_tree_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/herb/rcmap_herbaceous_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/sage/rcmap_sagebrush_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/bare/rcmap_bare_ground_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/non_sagebrush_shrub/rcmap_non_sagebrush_shrub_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/perennial_herbaceous/rcmap_perennial_herbaceous_",
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/mrlc/data/MRLC-CurrentViewer-Layers/anhb/rcmap_annual_herbaceous_"
  )
names(prefix) <- c('litter', 'shrub', 'tree', 'herbaceous', 'sagebrush', 'bare_ground', 'non_sagebrush_shrub', 'perennial_herbaceous', 'annual_herbaceous')

process_product <- function(yr, tmt, product) {
  products  <- c(product)
  years <- c(yr)
  urltab <- expand.grid(x = products, y = years)
  urllist <- paste0(prefix[products], urltab$y, '.tif')
  
  shape <- vect(read_sf(tmt, as_tibble = FALSE))
  
  rcmapbrick <- sds()
  for (i in 1:length(urltab$x)) {
    rcmapbrick[i] <- rast(urllist[i], vsi = TRUE, opts = gdalinopts)
  }
  
  
  names(rcmapbrick) <- paste0(urltab$x, "_", urltab$y)
  namelist <- paste0(names(rcmapbrick), '.tif')
  pshape <- terra::project(shape, rcmapbrick)
  
  rcmapbrickcrop <- crop(rcmapbrick, pshape)
  
  outrasts <- sds()
  for (j in 1:length(rcmapbrickcrop)) {
    if (global(rcmapbrickcrop[j], "max", na.rm = TRUE) == 101) {
      subst(rcmapbrickcrop[j], 101, NA)
    }
    outrasts[j] <- mask(rcmapbrickcrop[j], mask = pshape, touches = TRUE)
    
  }
  #let's get some stats, then output a summary CSV
  statlist <- vector("list", length = length(outrasts))
  medlist <- vector("list", length = length(outrasts))
  for (k in 1:length(outrasts)) {
    statlist[[k]] <-
      global(outrasts[k], c("mean", "sd", "isNA", "notNA"), na.rm = TRUE)
    medlist[[k]] <- global(outrasts[k], fun = quantile, na.rm = TRUE)
  }
  layerstats <- do.call(rbind, statlist)
  layerquant <- do.call(rbind, medlist)
  lstatsall <- cbind(layerstats, layerquant)
  cn <-
    c(
      "Mean",
      "Std. Dev.",
      "NA Cells",
      "Value Cells",
      "Min",
      "25% Quintile",
      "Median",
      "75% Quintile",
      "Max"
    )
  colnames(lstatsall) <- cn
  return(lstatsall)
  
}

