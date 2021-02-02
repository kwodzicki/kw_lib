FUNCTION GLOBAL_MEAN, valsIn, lonIn, latIn, LIMIT=limit
;+
; Name:
;   GLOBAL_MEAN
; Purpose:
;   Compute area-weighted global mean of variable based on 
;   latitude weighting
; Inputs:
;   valsIn  : Array of values to average; must be [lon, lat, *, *, etc.]
;   lonIn   : Longitude values; corresponds to zeroth dimension of valsIn
;   latIn   : Latitude values; corresponds to first dimension of valsIn
; Keywords:
;   LIMIT   : limiting bounds
; Returns:
;   Area-weighted mean
;-

COMPILE_OPT IDL2

IF N_ELEMENTS(limit) NE 4 THEN limit = [-90, 0, 90, 360]                        ; Set default limit

lon    = (lonIn + 360.0) MOD 360.0                                              ; Make sure longitudes are 0-360
lat    = latIn                                                                  ; Set latitude
lonID  = WHERE(lon GE limit[1] AND lon LE limit[3], lonCNT)                     ; Find longitudes in limit
latID  = WHERE(lat GE limit[0] AND lat LE limit[2], latCNT)                     ; Find latitudes in limit

vals   = valsIn[lonID, latID, *, *, *, *, *, *]                                 ; Filter data to lon/lat limit
type   = vals.TYPECODE                                                          ; Get type

fid    = WHERE(FINITE(vals) EQ 0, fcnt)                                         ; Locate non-finite values
lat    = REBIN(REFORM(lat[latID], 1, latCNT), lonCNT, latCNT)                   ; Rebin latitude to [nlon, nlat]

weight = COS( lat * !DTOR )                                                     ; Compute weights
weight = REBIN(weight, vals.DIM)                                                ; Rebin weights to shape of vals

vals   = TOTAL(TOTAL(vals*weight, 1, /NaN, /DOUBLE), 1, /NaN, /DOUBLE)          ; Scale vals by weight and sum over first 2 dimensions
IF fcnt GT 0 THEN weight[fid] = !Values.F_NaN                                   ; If non-finite values; set weights at those values to NaN
tot    = TOTAL(TOTAL(weight, 1, /NaN, /DOUBLE), 1, /NaN, /DOUBLE)               ; Total weights over first 2 dimensions

RETURN, FIX(vals / tot, TYPE=type)                                              ; Compute mean and fix to input type
 
END
