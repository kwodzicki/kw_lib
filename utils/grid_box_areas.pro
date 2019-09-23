FUNCTION SRFC_AREA_SPHERE, lat
  COMPILE_OPT IDL2, HIDDEN
  RETURN, EARTH_RADIUS(lat, DOUBLE=1)^2 * COS(lat)
END

FUNCTION GRID_BOX_AREAS, in_lon, in_lat, $
  DEGREE = degree, $
  DOUBLE = double
;+
; Name:
;   GRID_BOX_AREAS
; Purpose:
;   A function to compute the area of grid boxes on the surface
;   of the earth.
; Inputs:
;   lon  : Array of longitudes specifying the boundaries of the grid
;          boxes in longitude.
;   lat  : Array of latitudes specifying the boundaries of the grid
;          boxes in latitude.
; Outputs:
;   Returns array of size [nlon-1, nlat-1] where every point is the
;   area of a given gridbox centered at $
;   [ (lon[n]+lon[n+1])/2, (lat[m]+lat[m+1])/2 ]
; Keywords:
;   DEGREE  : Set if input longitudes and latitudes are in degress.
;   DOUBLE  : Set to perform all arithmetic in double precision.
; Author and History:
;   Kyle R. Wodzicki     Created 11 Apr. 2016
;-
  COMPILE_OPT IDL2

  IF KEYWORD_SET(double) THEN BEGIN
    lon = DOUBLE(in_lon)
    lat = DOUBLE(in_lat)
    c   = !DPI/180.D00        ; Conversion for degrees to radians
  ENDIF ELSE BEGIN
    lon = in_lon
    lat = in_lat
    c   = !PI/180.E00         ; Conversion for degrees to radians
  ENDELSE
  
  IF KEYWORD_SET(degree) THEN BEGIN
    lon = TEMPORARY(lon) * c
    lat = TEMPORARY(lat) * c
  ENDIF

  nLon = N_ELEMENTS(lon)
  nLat = N_ELEMENTS(lat)
  fill = KEYWORD_SET(double) ? !Values.D_NaN : !Values.F_NaN
  area = MAKE_ARRAY(nLon-1, nLat-1, VALUE = fill)
  
  FOR j = 0, nLat-2 DO $
    area[*,j] = QROMB('SRFC_AREA_SPHERE', lat[j], lat[j+1], DOUBLE=double)
  IF (area[0] LT 0) THEN area = -1 * TEMPORARY(area)
  RETURN, TEMPORARY(area) * REBIN(lon[1:*]-lon[0:-2], nLon-1, nLat-1)
END