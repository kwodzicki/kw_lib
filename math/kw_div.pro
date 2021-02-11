FUNCTION KW_DIV, u, v, lon, lat

;+
; Name:
;		KW_DIV
; Purpose:
;		To compute the divergence of the wind using the 
;		u and v components.
; Keywords:
;		None.
; Author and History:
;		Kyle R. Wodzicki		Created 17 Sep. 2014
;
;     MODIFIED 06 Nov. 2014 by K.R.W.
;       Changed so able to handle data greater than 2-D. Assumes
;       dims 1 and 2 are the x and y data.
;-

COMPILE_OPT IDL2

IF (N_PARAMS() NE 4) THEN MESSAGE, 'Incorrect number of inputs!'      ;Check number of inputs

IF (SIZE(u,/N_DIMENSIONS) LT 2 OR SIZE(v, /N_DIMENSIONS) LT 2) THEN $ ;Check dimensions of input
  MESSAGE, 'U and V must be at least 2 dimensions!'

IF (MEAN(SIZE(u, /DIMENSIONS) EQ SIZE(v, /DIMENSIONS)) NE 1) THEN $   ;If not the same columns and rows
  MESSAGE, 'U and V arrays must be the same size!'

;Convert input longitude and latitude to 2-D arrays
IF (SIZE(lon, /N_DIMENSIONS) EQ 1) THEN BEGIN
	dims = [N_ELEMENTS(lon), N_ELEMENTS(lat)]
	lon_2D = REBIN(lon, dims)
	lat_2D = REBIN(TRANSPOSE(lat), dims)
ENDIF ELSE BEGIN
	lon_2D = lon
	lat_2D = lat 
ENDELSE

lon0 = SHIFT(lon_2D, -1, 0) & lon1 = SHIFT(lon_2D, 1,  0)
lat0 = SHIFT(lat_2D,  0, 1) & lat1 = SHIFT(lat_2D, 0, -1)

d_x = KW_MAP_2POINTS(lon0, lat_2D, lon1, lat_2D, /METERS)              ;Change in distance over x
d_y = KW_MAP_2POINTS(lon_2D, lat0, lon_2D, lat1, /METERS)              ;Change in distance over y

dims  = SIZE(u, /DIMENSIONS)                                          ;Get the dimensions of u
nDims = N_ELEMENTS(dims)                                              ;Get number of dimensions of u

d_x = REBIN(d_x, dims)                                                ;Rebin dx to corrent size
d_y = REBIN(d_y, dims)                                                ;Rebin dy to corrent size

x0_shift = INTARR(nDims) & x0_shift[0] = -1                           ;Set shifting for x0
x1_shift = INTARR(nDims) & x1_shift[0] =  1                           ;Set shifting for x1
y0_shift = INTARR(nDims) & y0_shift[1] =  1                           ;Set shifting for y0
y1_shift = INTARR(nDims) & y1_shift[1] = -1                           ;Set shifting for y1

grad_x = (SHIFT(u, x0_shift) - SHIFT(u, x1_shift)) / d_x              ;Shift to left - shift to right
grad_y = (SHIFT(v, y0_shift) - SHIFT(v, y1_shift)) / d_y              ;Shift down - shift up

; Depending on the arrangement of the latitude values (ERA is positive
; to negative where as TMI is negative to positive) we must subtract
; the change in y because of shifting
IF (lat[0] GT lat[-1]) THEN BEGIN
	divergence=grad_x+grad_y
ENDIF ELSE BEGIN
	divergence=grad_x-grad_y
ENDELSE

;Clean up the edges
divergence[ 0, *, *, *, *, *, *, *]=!VALUES.F_NaN
divergence[-1, *, *, *, *, *, *, *]=!VALUES.F_NaN
divergence[ *, 0, *, *, *, *, *, *]=!VALUES.F_NaN
divergence[ *,-1, *, *, *, *, *, *]=!VALUES.F_NaN


RETURN, divergence

END
