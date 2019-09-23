FUNCTION KW_GRID_DATA, z, x, y, LIMIT = limit, DX = dx, DY = dy, $
  WEIGHTS = weights, $
  XVALS   = lons, $
  YVALS   = lats
;+
; Name:
;   KW_GRID_DATA
; Purpose:
;   A function to grid data to a fixed grid.
; Inputs:
;   z :   Variable to grid
;   x :   Longitude values
;   y :   Latitude values
; Outputs:
;   Returns a structure with grid box means, medians, counts, and
;   reference longitudes and latitudes. Lon/Lat values are for 
;   grid box centers.
; Keywords:
;   LIMIT   : Set to define the domain. Use the convention
;             [latMin, lonMin, latMax, lonMax]. Default is full globe.
;   DX      : Set default grid spacing in longitude. Default is 1.5.
;   DY      : Set default grid spacing in latitude.  Default is 1.5.
;   XVALS   : Set to a named variable to return x-values to.
;   YVALS   : Set to a named variable to return y-values to.
; Author and History:
;   Kyle R. Wodzicki     Created 22 Mar. 2016
;-

COMPILE_OPT IDL2

IF (N_PARAMS()        NE 3) THEN MESSAGE, 'Incorrect number of inputs!'

;=== Set default values
IF (N_ELEMENTS(dx)    EQ 0) THEN dx    = 1.5
IF (N_ELEMENTS(dy)    EQ 0) THEN dy    = 1.5
IF (N_ELEMENTS(limit) EQ 0) THEN limit = [-90, 0, 90, 360]

IF (limit[1] LT 0)        THEN limit[1]     = limit[1]+360
IF (limit[3] LT 0)        THEN limit[3]     = limit[3]+360
IF (limit[3] LT limit[1]) THEN limit[1:*:2] = limit[-1:0:-2]

dims = SIZE(z, /DIMENSIONS)
IF (N_ELEMENTS(dims) EQ 2) THEN BEGIN
	IF (SIZE(x, /N_DIMENSIONS) EQ 1) THEN x2d = REBIN(x, dims) ELSE x2d = x
	IF (SIZE(y, /N_DIMENSIONS) EQ 1) THEN y2d = REBIN(REFORM(y, 1, dims[1]), dims) ELSE y2d = y
ENDIF ELSE BEGIN
	x2d = x
	y2d = y
ENDELSE

id = WHERE(x2d LT 0, CNT)
IF (CNT GT 0) THEN x2d[id] = x2d[id] + 360
lon_bins = dx * FINDGEN(360/dx + 1)
lat_bins = dy * FINDGEN(180/dy + 1) - 90

lon_id = WHERE(lon_bins GE limit[1] AND lon_bins LE limit[3], lon_CNT)
lat_id = WHERE(lat_bins GE limit[0] AND lat_bins LE limit[2], lat_CNT)
IF (lon_CNT GT 0) THEN lon_bins = lon_bins[lon_id]
IF (lat_CNT GT 0) THEN lat_bins = lat_bins[lat_id]

lons = lon_bins[0:-2]+dx/2.0
lats = lat_bins[0:-2]+dx/2.0

nLon = N_ELEMENTS(lons)
nLat = N_ELEMENTS(lats)

var_tot  = MAKE_ARRAY(nLon, nLat, Value=!Values.D_NaN)
var_mean = MAKE_ARRAY(nLon, nLat, Value=!Values.F_NaN)
var_wtd  = MAKE_ARRAY(nLon, nLat, Value=!Values.F_NaN)
var_med  = MAKE_ARRAY(nLon, nLat, Value=!Values.F_NaN)
var_cnt  = LONARR(nLon, nLat)

weight_mean = N_ELEMENTS(weights) NE 0
lat_hist = HISTOGRAM(y2d, MIN=lat_bins[0], MAX=lat_bins[-1], BINSIZE=dy, $
  REVERSE_INDICES=lat_ri)

FOR j = 0, nLat-1 DO BEGIN
  IF (lat_hist[j] EQ 0) THEN CONTINUE
  lat_id = lat_ri[ lat_ri[j]:lat_ri[j+1]-1 ]
  lon_hist = HISTOGRAM(x2d[lat_id], MIN=lon_bins[0], MAX=lon_bins[-1], $
    BINSIZE=dx, REVERSE_INDICES=lon_ri)
  FOR i = 0, nLon-1 DO BEGIN
    IF (lon_hist[i] EQ 0) THEN CONTINUE
    IF (lon_hist[i] EQ 1) THEN BEGIN
    	lon_id = lon_ri[ lon_ri[i]:lon_ri[i+1]-1 ]
      id     = lat_id[ lon_id ]
      var_tot[i,j]  = z[id]
      var_mean[i,j] = z[id]
      IF weight_mean EQ 1 THEN var_wtd[i,j] = z[id]
      var_med[i,j]  = z[id]
      var_cnt[i,j]  = 1
    ENDIF ELSE BEGIN      
      lon_id = lon_ri[ lon_ri[i]:lon_ri[i+1]-1 ]
      id     = lat_id[ lon_id ]
      var_tot[i,j]  = TOTAL(z[id], /DOUBLE)
      var_mean[i,j] = MEAN(z[id], /NaN)
      IF weight_mean EQ 1 THEN $
        IF TOTAL(weights[id]) GT 0 THEN $
          var_wtd[i,j] = WTD_MEAN(z[id], weights[id])
      var_med[i,j]  = MEDIAN(z[id])
      var_cnt[i,j]  = N_ELEMENTS(id)
    ENDELSE
  ENDFOR
ENDFOR

RETURN,  {LON     : lons,     $
          LAT     : lats,     $
          COUNT   : var_cnt,  $
          TOTAL   : var_tot,  $
          MEAN    : var_mean, $
          WTD     : var_wtd,  $
          MEDIAN  : var_med}

END