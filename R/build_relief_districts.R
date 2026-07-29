#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------------------
# build_relief_districts.R - prepare Rwanda district geometry without application-only attributes.
#
# INPUT:
#   - GEOMETRY: World Bank "Rwanda Admin Boundaries and Villages" District.shp (30 districts,
#     fields Dist_ID/District, CC BY 4.0), supplied as argument 1 and reprojected to EPSG:4326.
# OUTPUT: a 30-feature EPSG:4326 GeoJSON with one property, `district`.
#
# FAIL-CLOSED: hard-stops if the shapefile is absent or does not contain exactly
# 30 uniquely named district features. No partial GeoJSON is written.
#
# USAGE: Rscript R/build_relief_districts.R <District.shp> [out_geojson]
#         Requires: terra.
# ---------------------------------------------------------------------------------------
suppressWarnings(suppressMessages({ library(terra) }))
args   <- commandArgs(trailingOnly = TRUE)
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
SHP <- if (length(args) >= 1 && nzchar(args[1])) args[1] else ""
OUT <- if (length(args) >= 2 && nzchar(args[2])) args[2] else
  file.path(ROOT, "generated", "relief_districts.geojson")
TOL    <- 0.002   # simplify tolerance in degrees (~200 m) - national-scale relief view

# Load + reproject + simplify district geometry.
if (!nzchar(SHP) || !file.exists(SHP)) {
  stop(sprintf(paste0("FAIL-CLOSED: district shapefile not found at:\n  %s\n",
                      "This is the owner-populated World Bank 'Rwanda Admin Boundaries and Villages' ",
                      "District.shp (CC BY 4.0), kept out of Git. Drop District.shp/.shx/.dbf/.prj there ",
                      "(or pass its path as arg 1) and re-run. No GeoJSON written."), SHP))
}
v <- vect(SHP)
if (!("District" %in% names(v))) stop(sprintf("FAIL-CLOSED: shapefile lacks a 'District' field; has: %s", paste(names(v), collapse = ", ")))
v <- project(v, "EPSG:4326")
v <- simplifyGeom(v, tolerance = TOL)
nvert <- nrow(crds(v))
cat(sprintf("geometry: %d features, %d vertices after simplify (tol %.4f deg)\n", nrow(v), nvert, TOL))
if (nvert > 20000) cat(sprintf("NOTE: %d vertices exceeds the 20k soft budget; raise TOL if the file is heavy.\n", nvert))

gdist   <- as.character(v$District)
if (nrow(v) != 30L || anyNA(gdist) || any(!nzchar(gdist)) || anyDuplicated(gdist))
  stop("FAIL-CLOSED: expected 30 uniquely named district features.")

# Keep only the public boundary identifier; no WorldPop/application-only attribute.
v <- v[, "District"]
names(v)[names(v) == "District"] <- "district"
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf("wrote %d-district geometry GeoJSON -> %s (%s)\n",
            nrow(v), OUT, format(structure(file.info(OUT)$size, class = "object_size"), units = "auto")))
