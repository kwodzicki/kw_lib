FUNCTION KW_GRID_DATA_V2, z, x, y
;+
; Name:
;   KW_GRID_DATA_V2
; Purpose:
;   A function to grid data. Version 2
; Author and History:
;   Kyle R. Wodzicki     Created 25 Aug. 2016
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

grid_index = MAKE_ARRAY(dims, VALUE = -1LL)

FOR i = 0, N_ELEMENTS(lon_bins)-2 DO $
  FOR j = 0, N_ELEMENTS(lat_bins)-2 DO BEGIN
    ii = i & jj = j
    box_id = WHERE(x GE lon_bins[i] AND x LE lon_bins[i+1] AND $
                   y GE lat_bins[j] AND y LE lat_bins[j+1], box_CNT)
    IF box_CNT EQ 0 THEN CONTINUE
    ;=== Look at the western boundary of box 
    west = WHERE(x[box_id] EQ lon_bins[i], west_CNT, COMPLEMENT=not_west, NCOMPLEMENT=not_west_CNT)
    IF (west_CNT GT 0) THEN BEGIN
      west = box_id[west]
      ll = WHERE(y[west] EQ lat_bins[j], ll_CNT, COMPLEMENT=not_ll, NCOMPLEMENT=not_ll_CNT)
      IF (ll_cnt GT 0) THEN BEGIN
        ll = west[ll]
        r = RANDOMU(seed, ll_CNT)
        id1 = WHERE(r LT 0.25, CNT1)               & IF CNT1 GT 0 THEN grid_index[ll[id1]] = ii-1 + nLon*jj-1
        id2 = WHERE(r GE 0.25 AND r LT 0.5,  CNT2) & IF CNT2 GT 0 THEN grid_index[ll[id2]] = ii   + nLon*jj-1
        id3 = WHERE(r GE 0.5  AND r LT 0.75, CNT3) & IF CNT3 GT 0 THEN grid_index[ll[id3]] = ii-1 + nLon*jj
        id4 = WHERE(r GE 0.75, CNT4)               & IF CNT4 GT 0 THEN grid_index[ll[id4]] = ii   + nLon*jj
      ENDIF      
      ul = WHERE(y[west] EQ lat_bins[j+1], ul_CNT, COMPLEMENT=not_ul, NCOMPLEMENT=not_ul_CNT)
      IF (ul_cnt GT 0) THEN BEGIN
        ul = west[ul]
        r = RANDOMU(seed, ul_CNT)
        id1 = WHERE(r LT 0.25, CNT1)               & IF CNT1 GT 0 THEN grid_index[ul[id1]] = ii-1 + nLon*jj+1
        id2 = WHERE(r GE 0.25 AND r LT 0.5,  CNT2) & IF CNT2 GT 0 THEN grid_index[ul[id2]] = ii   + nLon*jj+1
        id3 = WHERE(r GE 0.5  AND r LT 0.75, CNT3) & IF CNT3 GT 0 THEN grid_index[ul[id3]] = ii-1 + nLon*jj
        id4 = WHERE(r GE 0.75, CNT4)               & IF CNT4 GT 0 THEN grid_index[ul[id4]] = ii   + nLon*jj
      ENDIF
      IF (not_LL_CNT GT 0) THEN west = west[not_ll]                             ; Remove points that are at the lower left boundary
      IF (not_UL_CNT GT 0) THEN west = west[not_ul]                             ; Remove points that are at the lower left boundary
      west_CNT = N_ELEMENTS(west)
      r = RANDOMU(seed, west_CNT)
			id1 = WHERE(r LT 0.5, CNT1, COMPLEMENT=id2, NCOMPLEMENT=CNT2)
			IF CNT1 GT 0 THEN grid_index[west[id1]] = i-1 + nLon*j
			IF CNT2 GT 0 THEN grid_index[west[id2]] = i   + nLon*j
    ENDIF
    
    
;    west = WHERE(x[box_id] EQ lon_bins[i], west_CNT, COMPLEMENT=not_west, NCOMPLEMENT=not_west_CNT)
;    IF (west_CNT GT 0) THEN BEGIN
;      west = box_id[west]
;      ll = WHERE(y[west] EQ lat_bins[j], ll_CNT, COMPLEMENT=not_ll, NCOMPLEMENT=not_ll_CNT)
;      IF (ll_cnt GT 0) THEN BEGIN
;        ll = west[ll]
;        r = RANDOMU(seed, ll_CNT)
;        id1 = WHERE(r LT 0.25, CNT1)               & IF CNT1 GT 0 THEN grid_index[ll[id1]] = ii-1 + nLon*jj-1
;        id2 = WHERE(r GE 0.25 AND r LT 0.5,  CNT2) & IF CNT2 GT 0 THEN grid_index[ll[id2]] = ii   + nLon*jj-1
;        id3 = WHERE(r GE 0.5  AND r LT 0.75, CNT3) & IF CNT3 GT 0 THEN grid_index[ll[id3]] = ii-1 + nLon*jj
;        id4 = WHERE(r GE 0.75, CNT4)               & IF CNT4 GT 0 THEN grid_index[ll[id4]] = ii   + nLon*jj
;      ENDIF      
;      ul = WHERE(y[west] EQ lat_bins[j+1], ul_CNT, COMPLEMENT=not_ul, NCOMPLEMENT=not_ul_CNT)
;      IF (ul_cnt GT 0) THEN BEGIN
;        ul = west[ul]
;        r = RANDOMU(seed, ul_CNT)
;        id1 = WHERE(r LT 0.25, CNT1)               & IF CNT1 GT 0 THEN grid_index[ul[id1]] = ii-1 + nLon*jj+1
;        id2 = WHERE(r GE 0.25 AND r LT 0.5,  CNT2) & IF CNT2 GT 0 THEN grid_index[ul[id2]] = ii   + nLon*jj+1
;        id3 = WHERE(r GE 0.5  AND r LT 0.75, CNT3) & IF CNT3 GT 0 THEN grid_index[ul[id3]] = ii-1 + nLon*jj
;        id4 = WHERE(r GE 0.75, CNT4)               & IF CNT4 GT 0 THEN grid_index[ul[id4]] = ii   + nLon*jj
;      ENDIF
;      IF (not_LL_CNT GT 0) THEN west = west[not_ll]                             ; Remove points that are at the lower left boundary
;      IF (not_UL_CNT GT 0) THEN west = west[not_ul]                             ; Remove points that are at the lower left boundary
;      west_CNT = N_ELEMENTS(west)
;      r = RANDOMU(seed, west_CNT)
;			id1 = WHERE(r LT 0.5, CNT1, COMPLEMENT=id2, NCOMPLEMENT=CNT2)
;			IF CNT1 GT 0 THEN grid_index[west[id1]] = i-1 + nLon*j
;			IF CNT2 GT 0 THEN grid_index[west[id2]] = i   + nLon*j
;    ENDIF
    
    IF (not_west_CNT  GT 0) THEN id = box_id[not_west]
;    IF (not_east_CNT  GT 0) THEN id = box_id[not_east]
;    IF (not_north_CNT GT 0) THEN id = box_id[not_north]
;    IF (not_south_CNT GT 0) THEN id = box_id[not_south]
    
    grid_index[id] = i + nLon*j
  ENDFOR






FOR k = 0, N_ELEMENTS(var_cnt)-1 DO BEGIN
  id = WHERE(grid_index EQ k, CNT)
  IF CNT EQ 0 THEN CONTINUE
  Col = k MOD nLon
  Row = k / nLon
  
  var_cnt[col, row]  = CNT
  var_tot[col, row]  = TOTAL(z[id], /DOUBLE, /NaN)
  var_mean[col, row] = MEAN(z[id], /NaN) 
  var_med[col, row]  = MEDIAN(z[id])
ENDFOR

RETURN,  {LON     : lons,     $
          LAT     : lats,     $
          COUNT   : var_cnt,  $
          TOTAL   : var_tot,  $
          MEAN    : var_mean, $
;          WTD     : var_wtd,  $
          MEDIAN  : var_med}
END