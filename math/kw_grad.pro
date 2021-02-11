FUNCTION KW_GRAD, in_array, lon, lat, VECTORS=vectors

;+
; Name:
;		KW_DIV
; Purpose:
;		To compute the gradient of a given input variable. Assumes
;   on a Lat/Lon grid. Just returns magnitude of the gradient.
; Inputs:
;   in_array   : Array of data to determine gradient of.
;   lon        : Longitude points corresponding to data.
;   lat        : Latitude points corresponding to data.
; Outputs:
;   Returns array of same dimension as in_array if Vectors keyword
;   not set. This array contains the magnitude of the gradient.
;   If using the VECTORS keyword, an array with dimensions one 
;   greater than in_array is returned, with the last dimension
;   determining if the u component, index 0, or the
;   v component, index 1.
; Keywords:
;		VECTORS  : If set, returns a structure with the u and v
;              components of the gradient. Else, returns the
;              maginitude of the gradient.
; Author and History:
;		Kyle R. Wodzicki		Created 17 Sep. 2014
;     MODIFIED 14 Jan. 2015 - Added support for up to 4-D arrays.
;-

COMPILE_OPT IDL2

;Convert input longitude and latitude to 2-D arrays
IF SIZE(lon, /N_DIMENSIONS) EQ 1 THEN BEGIN
	dims = [N_ELEMENTS(lon), N_ELEMENTS(lat)]
	lon_2D = REBIN(lon, dims)
	lat_2D = REBIN(TRANSPOSE(lat), dims)
ENDIF ELSE BEGIN
	lon_2D = lon
	lat_2D = lat
ENDELSE

lon0 = SHIFT(lon_2D, -1,  0) & lon1 = SHIFT(lon_2D, 1, 0)
lat0 = SHIFT(lat_2D,  0, -1) & lat1 = SHIFT(lat_2D, 0, 1)

d_lon = KW_MAP_2POINTS(lon0, lat_2D, lon1, lat_2D, /METERS)						;Change in distance over x
d_lat = KW_MAP_2POINTS(lon_2D, lat0, lon_2D, lat1, /METERS)						;Change in distance over y

dims = SIZE(in_array, /DIMENSIONS)

d_lon = REBIN(d_lon, dims) & d_lat = REBIN(d_lat, dims)

IF (N_ELEMENTS(dims) EQ 4) THEN BEGIN
  x_1 = [-1, 0, 0, 0] & x_2 = [1,  0, 0, 0]
  y_1 = [ 0, 1, 0, 0] & y_2 = [0, -1, 0, 0]
ENDIF ELSE IF (N_ELEMENTS(dims) EQ 3) THEN BEGIN
  x_1 = [-1, 0, 0] & x_2 = [1,  0, 0]
  y_1 = [ 0, 1, 0] & y_2 = [0, -1, 0]
ENDIF ELSE BEGIN
  x_1 = [-1, 0] & x_2 = [1,  0] &  y_1 = [ 0, 1] & y_2 = [0, -1]
ENDELSE

grad_x = (SHIFT(in_array, x_1) - SHIFT(in_array, x_2))/d_lon      ;Shift to left - shift to right
grad_y = (SHIFT(in_array, y_1) - SHIFT(in_array, y_2))/d_lat      ;Shift down - shift up

;Clean up the edges
grad_x[0,*,*,*]=!VALUES.F_NaN & grad_x[-1,*,*,*]=!VALUES.F_NaN
grad_y[*,0,*,*]=!VALUES.F_NaN & grad_y[*,-1,*,*]=!VALUES.F_NaN

; Depending on the arrangement of the latitude values (ERA is positive
; to negative where as TMI is negative to positive) we must subtract
; the change in y because of shifting
IF ~KEYWORD_SET(vectors) THEN grad = SQRT(grad_x^2 + grad_y^2) $
ELSE BEGIN
	IF (lat[0] GT lat[-1]) THEN $
	  grad = {U_Comp : grad_x, $
	          V_Comp : grad_y} $
	ELSE $
		grad = {U_Comp :    grad_x, $
	          V_Comp : -1*grad_y}
ENDELSE

RETURN, grad

END
