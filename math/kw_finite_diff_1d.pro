FUNCTION KW_FINITE_DIFF_1D, z_in, x_in, $ 
  DIMENSION  = dimension,  $
  DERIVATIVE = derivative, $ 
  ORDER      = order,      $
  LONGITUDE  = longitude,  $
  LATITUDE   = latitude,   $
  DOUBLE     = double 

;+
; Name:
;		KW_FINITE_DIFF_1D
; Purpose:
;		A function to perform central finite differencing on a 2D array.
;   differencing is performed both in d/dx and d/dy.
; Inputs:
;   z_in  : 2D array of data that will be worked on.
;   x_in  : Locations of data in the x direction. Must be equally spaced.
;   y_in  : Locations of data in the y direction. Must be equally spaced.
; Keywords:
;		DERIVATIVE : Set the order of the derivate to take. Default is 1
;   ORDER      : Set the order of accuracy. Default is 4.
;   LAT_LON    : Set if x_in and y_in are latitude/longitude values
;   GLOBAL     : Set if data is global. This will eliminate boundary issues.
;                 If this keyword is not/cannot be used, then data near
;                 boundaries are replaced with NaN Characters.
;   DOUBLE     : Set to return values in double precision
;
; Dependencies:
;   FINITE_DIFF_COEFFICIENT : This function simply returns coefficients for
;     finite differencing.
;   KW_MAP_2POINTS : This function is identical to the standard IDL function
;     MAP_2POINTS, however, it allows arrays to be input.
; Note:
;   All calculations are performed using double precision, however, data will
;   be returned as floats unless the DOULBE keyword is set.
;
; Author and History:
;		Kyle R. Wodzicki		Created 19 May 2016
;-

COMPILE_OPT IDL2
IF (N_PARAMS() LT 3) THEN MESSAGE, 'Incorrect number of inputs!'                ;Check number of inputs

;=== Set some defaults
IF (N_ELEMENTS(order)      EQ 0) THEN order      = 6
IF (N_ELEMENTS(derivative) EQ 0) THEN derivative = 1
IF KEYWORD_SET(double) THEN type = 5 ELSE type = 4

;=== Get coefficients for finite differencing
Co  = FINITE_DIFF_COEFFICIENT(derivative, order)
nCo = N_ELEMENTS(Co)/2

;=== Convert all values to double
z = DOUBLE(z_in)
x = DOUBLE(x_in)

;=== Make sure that x and y inputs are of same dimensions as z
dims = SIZE(z, /DIMENSION)

;=== Shift data incase it is global
sp = [dims[0]/2, 0]
new_z = MAKE_ARRAY(dims+nCo*2, VALUE=!VALUES.D_NaN)
new_z[0,     nCo] = z[-1*nCo:-1,*]
new_z[nCo,   nCo] = z
new_z[-1*nCo,nCo] = z[0:nCo-1,*]
new_z[nCo,0]      = REVERSE(SHIFT(z[*,1:nCo],       sp),2)
new_z[nCo,-1*nCo] = REVERSE(SHIFT(z[*,-1*nCo-1:-2], sp),2)
z = TEMPORARY(new_z)
new_x = MAKE_ARRAY(dims+nCo*2, VALUE=!VALUES.D_NaN)
new_x[0,     nCo] = x[-1*nCo:-1,*]
new_x[nCo,   nCo] = x
new_x[-1*nCo,nCo] = x[0:nCo-1,*]
new_x[nCo,0]      = REVERSE(SHIFT(x[*,1:nCo],       sp),2)
new_x[nCo,-1*nCo] = REVERSE(SHIFT(x[*,-1*nCo-1:-2], sp),2)
x = TEMPORARY(new_x)

;=== Compute x and y spacing. Use KW_MAP_2POINTS if LAT_LON is set
IF KEYWORD_SET(lat_lon) THEN BEGIN
  dx = KW_MAP_2POINTS(x, y, SHIFT(x, [1,0]), y, /KILOMETERS)                     ; Distance, in kilometers, between grid points in longitude
 	dy = KW_MAP_2POINTS(x, y, x, SHIFT(y, [0,1]), /KILOMETERS)                     ; Distance, in kilometers, between grid points in latitude
ENDIF ELSE BEGIN
  dx = SHIFT(x, [1, 0]) - x                                                    ; Distance, between points in x direction
  dy = SHIFT(y, [0, 1]) - y                                                    ; Distance, between points in y direction
ENDELSE

ddx = DBLARR(dims+2*nCo)                                                        ; Initialize array to store changes in x in
ddy = DBLARR(dims+2*nCo)                                                        ; Initialize array to store changes in y in

xshift = INTARR(2, 2*nCo+1)                                                     ; Initialize array to store how to shift in x
yshift = INTARR(2, 2*nCo+1)                                                     ; Initialize array to store how to shift in y

FOR i = -1*nCo, nCo DO BEGIN                                                    ; Iterate to fill in shifting indices
 xshift[0,i+nCo] = i * (-1)
 yshift[1,i+nCo] = i 
ENDFOR

IF (y_in[0] LT y_in[-1]) THEN yshift = -1 * yshift                              ; Account for ordering of latitudes

;FOR i = 0, 2*nCo DO BEGIN                                                       ; Compute values for each finite difference coefficient and add it to give arrays
;  ddx = ddx + Co[i] * SHIFT(z, xshift[*,i])                                     ; Sum changes in x
;  ddy = ddy + Co[i] * SHIFT(z, yshift[*,i])                                     ; Sum changes in y
;ENDFOR

FOR i = 0, 2*nCo DO BEGIN                                                       ; Compute values for each finite difference coefficient and add it to give arrays
  ddx += Co[i] * SHIFT(z, xshift[*,i])                                          ; Sum changes in x
  ddy += Co[i] * SHIFT(z, yshift[*,i])                                          ; Sum changes in y
ENDFOR

ddx = (TEMPORARY(ddx)/dx^derivative)[nCo:-1*nCo-1,nCo:-1*nCo-1]     			   		; Perform final calculation and convert to changer per meter
ddy = (TEMPORARY(ddy)/dy^derivative)[nCo:-1*nCo-1,nCo:-1*nCo-1]			      		  ; Perform final calculation and convert to changer per meter

IF KEYWORD_SET(lat_lon) THEN BEGIN
	ddx = TEMPORARY(ddx) * 1.0E-3
	ddy = TEMPORARY(ddy) * 1.0E-3
ENDIF

IF NOT KEYWORD_SET(global) THEN BEGIN                                           ; Clean up boundaries if data is NOT global
  ddx[0:nCo-1,  *]  = !Values.D_NaN
  ddx[-1*nCo:-1,*]  = !Values.D_NaN
  ddx[*, 0:nCo-1]   = !Values.D_NaN
  ddx[*, -1*nCo:-1] = !Values.D_NaN
  ddy[0:nCo-1,  *]  = !Values.D_NaN
  ddy[-1*nCo:-1,*]  = !Values.D_NaN
  ddy[*, 0:nCo-1]   = !Values.D_NaN
  ddy[*, -1*nCo:-1] = !Values.D_NaN
ENDIF

RETURN, {DDX : FIX(ddx, TYPE = type), DDY : FIX(ddy, TYPE = type)}              ; Return values
END
