#!/usr/bin/env Rscript
# relief_geojson_common.R - shared helper for building the experimental 3D-relief drape layers'
# LOCAL GeoJSON from committed synthetic CSVs. Offline data-prep only; NOT sourced by app.R.
#
# GOVERNANCE (no-PII red line, esp. under autonomous work): write_points_geojson ALLOW-LISTS output
# properties - ONLY the caller-named columns reach the client GeoJSON; every other row column is
# dropped. Callers pass the minimal set the popup + paint need (coords + a label/category/value).
# Descriptive, non-operational; the derived GeoJSON is git-ignored + served same-origin (zero external).

suppressWarnings(suppressMessages({ library(jsonlite) }))

# rows: data.frame. lng/lat: coordinate column names. props: NAMED character vector
# c(out_property = source_column, ...) = the ALLOW-LIST of properties to emit (nothing else leaves the
# row). out: output path. round_coords: coordinate decimal places (default 5 ~ 1 m). digits: property
# numeric rounding (default 3). Fail-CLOSED: errors (writes nothing) if a source column is missing or
# no row has a valid coordinate.
write_points_geojson <- function(rows, lng, lat, props, out, round_coords = 5, digits = 3, extra = NULL) {
  # Strict allow-list contract: props must be fully + uniquely named (a partial/duplicate name would
  # emit a malformed/colliding property). Fail-closed before anything is written.
  stopifnot(is.data.frame(rows), lng %in% names(rows), lat %in% names(rows), length(props) > 0,
            !is.null(names(props)), all(nzchar(names(props))), !anyDuplicated(names(props)))
  miss <- setdiff(unname(props), names(rows))
  if (length(miss) > 0) stop(sprintf("FAIL-CLOSED: allow-listed source column(s) missing from data: %s", paste(miss, collapse = ", ")))
  x <- suppressWarnings(as.numeric(rows[[lng]])); y <- suppressWarnings(as.numeric(rows[[lat]]))
  ok <- is.finite(x) & is.finite(y) & x >= -180 & x <= 180 & y >= -90 & y <= 90
  rows <- rows[ok, , drop = FALSE]; x <- round(x[ok], round_coords); y <- round(y[ok], round_coords)
  if (nrow(rows) == 0) stop(sprintf("FAIL-CLOSED: no valid coordinate rows for %s (cols %s/%s).", out, lng, lat))
  feats <- lapply(seq_len(nrow(rows)), function(i) {
    p <- setNames(lapply(names(props), function(nm) {   # ONLY the allow-listed properties - never the whole row
      v <- rows[[props[[nm]]]][i]
      if (is.numeric(v)) round(v, digits) else v
    }), names(props))
    list(type = "Feature", geometry = list(type = "Point", coordinates = c(x[i], y[i])), properties = p)
  })
  gj  <- list(type = "FeatureCollection", features = feats)
  if (length(extra)) gj <- c(gj, extra)   # optional top-level foreign members (RFC 7946 6.1), e.g. a provenance stamp
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(out)) file.remove(out)
  writeLines(as.character(jsonlite::toJSON(gj, auto_unbox = TRUE, na = "null", digits = NA)), out)
  cat(sprintf("wrote %d-feature points GeoJSON -> %s (%s; props: %s)\n",
              nrow(rows), out, format(structure(file.info(out)$size, class = "object_size"), units = "auto"),
              paste(names(props), collapse = ", ")))
  invisible(nrow(rows))
}

# LineString GeoJSON writer for the 3D relief (roads / waterways = PUBLIC ODbL line geometry). Each input
# line becomes a LineString Feature with **ZERO per-feature data properties** (`properties:{}`). This is a
# public-geometry layer with NO data channel - so, unlike the facilities points, there is nothing to allow-
# list, redact, or content-validate at offer time (governance-by-construction: no property can carry PII or
# any claim). `lines` = a list where each element is an N x 2 [lng,lat] coordinate set (matrix OR list of
# pairs, e.g. a road payload's nested arrays). Fail-CLOSED: a line with <2 valid coordinates is dropped;
# writes nothing (errors) if no line survives. round_coords = coordinate decimals; extra = optional top-level
# members (RFC 7946 6.1) - kept for parity with write_points_geojson, not required for roads.
write_lines_geojson <- function(lines, out, round_coords = 5, extra = NULL) {
  stopifnot(is.list(lines), length(lines) > 0)
  empty_props <- setNames(list(), character(0))   # -> "properties":{} (a valid, data-free GeoJSON object)
  feats <- lapply(lines, function(ln) {
    m <- tryCatch(
      # Always build a FRESH 2-col matrix: a 1-row line must stay a 1x2 matrix (not drop to a vector), so the
      # nrow(m) < 2 guard cleanly SKIPS it instead of erroring. Matrix input is transposed so its row-major
      # [lng,lat] order survives byrow=TRUE; list input (a payload's nested [lng,lat] arrays) unlists.
      matrix(as.numeric(if (is.matrix(ln)) t(ln) else unlist(ln, use.names = FALSE)), ncol = 2, byrow = TRUE),
      error = function(e) NULL, warning = function(w) NULL)
    if (is.null(m) || nrow(m) < 2) return(NULL)
    keep <- is.finite(m[, 1]) & is.finite(m[, 2]) & m[, 1] >= -180 & m[, 1] <= 180 & m[, 2] >= -90 & m[, 2] <= 90
    m <- m[keep, , drop = FALSE]
    if (nrow(m) < 2) return(NULL)
    # coordinates = the rounded N x 2 matrix; jsonlite serializes a matrix as [[lng,lat],...] (GeoJSON order)
    # in C - far faster than a per-vertex R loop for multi-100k-vertex line layers. unname drops X/Y colnames.
    list(type = "Feature", geometry = list(type = "LineString", coordinates = unname(round(m, round_coords))), properties = empty_props)
  })
  # unname: a named `lines` input (e.g. from split(), names "1".."N") would otherwise make jsonlite
  # serialize `features` as a JSON OBJECT {"1":..} instead of an ARRAY [..] - which MapLibre reads as zero
  # features (renders nothing). Force an unnamed list so `features` is always a GeoJSON array.
  feats <- unname(Filter(Negate(is.null), feats))
  if (length(feats) == 0) stop(sprintf("FAIL-CLOSED: no valid LineString features for %s.", out))
  # `extra` (e.g. a provenance/freshness stamp) is written as the FIRST top-level member(s), BEFORE the big
  # `features` array, so the offer-time validator can read the stamp from the file's LEADING bytes without
  # parsing the whole (multi-MB) FeatureCollection.
  gj <- if (length(extra)) c(list(type = "FeatureCollection"), extra, list(features = feats))
        else list(type = "FeatureCollection", features = feats)
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(out)) file.remove(out)
  writeLines(as.character(jsonlite::toJSON(gj, auto_unbox = TRUE, na = "null", digits = NA)), out)
  cat(sprintf("wrote %d-feature LineString GeoJSON -> %s (%s; ZERO data properties)\n",
              length(feats), out, format(structure(file.info(out)$size, class = "object_size"), units = "auto")))
  invisible(length(feats))
}

# OFFER-TIME FRESHNESS check for the roads LINE layer (a REAL owner-data layer). The relief geojson is built
# offline; if the 2D road payload is later regenerated but this file is NOT rebuilt, it would silently drift
# from the validated 2D network while the gate still says "authorized". So the build stamps the FIRST top-
# level members {road_payload_id, road_feature_count}; this reads ONLY the file's LEADING bytes (never the
# multi-MB body) and compares them to the CURRENT road payload manifest values (supplied by the caller).
# Mismatch / missing stamp -> FALSE (fail-closed = not offered). A staleness detector, NOT anti-tamper.
relief_line_geojson_fresh <- function(path, expected_id, expected_count, id_key, count_key, read_bytes = 2048L) {
  isTRUE(tryCatch({
    if (length(path) != 1L || is.na(path) || !nzchar(path) || !file.exists(path)) return(FALSE)
    con <- file(path, "rb"); on.exit(close(con))
    head <- rawToChar(readBin(con, "raw", n = read_bytes))
    idm <- regmatches(head, regexec(sprintf('"%s"[[:space:]]*:[[:space:]]*"([^"]*)"', id_key), head))[[1]]
    ctm <- regmatches(head, regexec(sprintf('"%s"[[:space:]]*:[[:space:]]*([0-9]+)', count_key), head))[[1]]
    if (length(idm) < 2L || length(ctm) < 2L) return(FALSE)
    identical(idm[[2]], as.character(expected_id)) &&
      identical(as.integer(ctm[[2]]), as.integer(expected_count))
  }, error = function(e) FALSE))
}
# Roads freshness = the generic head-read with the road stamp keys (unchanged behavior for the roads layer).
relief_roads_geojson_fresh <- function(path, expected_payload_id, expected_feature_count, read_bytes = 2048L) {
  relief_line_geojson_fresh(path, expected_payload_id, expected_feature_count,
                            "road_payload_id", "road_feature_count", read_bytes)
}

# Per-group COUNT + mean CENTROID for a district-aggregate point layer. COUNT comes from EVERY row with a
# non-empty group value - a missing/invalid coordinate does NOT reduce the count (the event still happened
# in that group; this mirrors the 2D district_burden_map, which counts before averaging coordinates).
# The CENTROID is the mean of VALID-coordinate rows only. Returns data.frame(<group>, <lng>, <lat>, count)
# for groups that have >=1 valid coordinate; groups with a count but no placeable centroid are returned via
# attr(., "dropped") (never silently undercounted). Fail-closed if there are no valid-coordinate rows at all.
relief_count_centroid <- function(df, group, lng, lat) {
  stopifnot(is.data.frame(df), all(c(group, lng, lat) %in% names(df)))
  g <- as.character(df[[group]]); keep <- !is.na(g) & nzchar(g)
  g <- g[keep]; df <- df[keep, , drop = FALSE]
  if (!nrow(df)) stop("FAIL-CLOSED: no rows with a non-empty group value.")
  cnt <- as.data.frame(table(g), stringsAsFactors = FALSE); names(cnt) <- c(group, "count")
  x <- suppressWarnings(as.numeric(df[[lng]])); y <- suppressWarnings(as.numeric(df[[lat]]))
  ok <- is.finite(x) & is.finite(y)
  if (!any(ok)) stop("FAIL-CLOSED: no rows with valid coordinates to place any centroid.")
  cen <- aggregate(cbind(x, y) ~ g, data.frame(g = g[ok], x = x[ok], y = y[ok]), mean)
  names(cen) <- c(group, lng, lat)
  out <- merge(cen, cnt, by = group)          # placed groups carry their FULL count (incl. missing-coord rows)
  out$count <- as.integer(out$count)
  attr(out, "dropped") <- setdiff(cnt[[group]], cen[[group]])
  out
}

# The KNOWN INSTITUTIONAL facility kinds that KEEP their `name` in the client GeoJSON. Single source of
# truth shared by the build (relief_facility_prepare drops names for non-institutional kinds) AND the
# offer-time validator (relief_facility_geojson_ok rejects a served file carrying a name on a non-
# institutional kind) - so the build rule and the runtime guard cannot drift.
relief_facility_institutional_kinds <- function() c("facility", "retail_dispensing")

# Facility POINT rows for the 3D relief, from the governance-approved health-facilities payload features
# (which are ALREADY the allow-listed 2D display set). Returns data.frame(lon, lat, name, category, kind).
# STRICT NO-PII rule (org policy "Never Include PII"): for the `practitioner` facility_kind - the OSM
# doctors/dentist office category where a facility `name` can be a PERSON'S name (e.g. a bare surname) -
# the name is DROPPED (the popup shows the generic category only). Institutional kinds (facility /
# retail_dispensing) keep their name; a schema-level allow-list alone would NOT catch a person's name
# sitting in an allowed field, so this is a value-level rule. Fail-closed if a required field is absent.
relief_facility_prepare <- function(features) {
  features <- as.data.frame(features, stringsAsFactors = FALSE)
  need <- c("display_name", "display_category", "facility_kind", "latitude", "longitude")
  miss <- setdiff(need, names(features))
  if (length(miss) > 0) stop(sprintf("FAIL-CLOSED: facility payload lacks required field(s): %s", paste(miss, collapse = ", ")))
  kind <- as.character(features$facility_kind)
  name <- as.character(features$display_name); name[is.na(name)] <- ""
  # NO-PII (NA-safe): keep a name ONLY for the known INSTITUTIONAL kinds; DROP it for practitioner (doctor/
  # dentist - a facility name there may be a PERSON'S name) AND for any unknown/NA kind. Uses %in% (not ==)
  # so an NA facility_kind never yields an NA subscript (which would error in `name[...] <- ""` assignment).
  name[!(kind %in% relief_facility_institutional_kinds())] <- ""
  data.frame(
    lon      = suppressWarnings(as.numeric(features$longitude)),
    lat      = suppressWarnings(as.numeric(features$latitude)),
    name     = name,
    category = as.character(features$display_category),
    kind     = kind,
    stringsAsFactors = FALSE)
}

# OFFER-TIME content validator for the health-facilities GeoJSON (a REAL owner-data layer). Its git-ignored
# geojson is built OFFLINE, so the runtime must NOT trust it by mere existence + authorization. Re-verifies,
# on the SERVED file, the governance invariants that make it safe to offer (fail-closed = FALSE on ANY doubt):
#   1. parses as a GeoJSON FeatureCollection;
#   2. ALLOW-LIST: every feature's properties are a subset of {name, category, kind} - no extra / PII fields;
#   3. NO-PII: no feature whose `kind` is NOT institutional carries a non-empty `name` (mirrors the build's
#      relief_facility_prepare via the SHARED relief_facility_institutional_kinds() - they cannot drift);
#   4. FRESHNESS (only if expected_contract_version is supplied): the top-level `contract_version` stamp the
#      build embedded must equal the currently-approved 2D payload contract version - catches a STALE geojson
#      left after the payload was regenerated. This is a staleness detector, NOT anti-tamper (a hand-editor
#      could forge the stamp); invariants 2-3 are the anti-PII control (they hold regardless of provenance).
relief_facility_geojson_ok <- function(path, expected_contract_version = NULL,
                                       allowed = c("name", "category", "kind")) {
  ok <- tryCatch({
    stopifnot(length(path) == 1L, !is.na(path), nzchar(path), file.exists(path))
    gj <- jsonlite::fromJSON(path, simplifyVector = FALSE)
    stopifnot(identical(gj$type, "FeatureCollection"), !is.null(gj$features))
    if (!is.null(expected_contract_version))
      stopifnot(identical(as.character(gj$contract_version), as.character(expected_contract_version)))
    inst <- relief_facility_institutional_kinds()
    good <- vapply(gj$features, function(f) {
      p <- f$properties
      if (length(p) > 0 && !all(names(p) %in% allowed)) return(FALSE)   # allow-list: no extra/PII fields
      nm <- p[["name"]]; has_name <- is.character(nm) && length(nm) == 1L && !is.na(nm) && nzchar(nm)
      kd <- if (is.null(p[["kind"]])) NA_character_ else as.character(p[["kind"]])[1]
      !(has_name && !(kd %in% inst))                                    # NO-PII: name only on institutional kinds
    }, logical(1))
    all(good)
  }, error = function(e) FALSE)
  isTRUE(ok)
}
