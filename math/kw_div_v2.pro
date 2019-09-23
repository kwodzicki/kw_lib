FUNCTION KW_DIV_V2, in_u, in_v, in_lon, in_lat, $
  DERIVATIVE = derivative, $
  ORDER      = order, $
  VECTORS    = vectors

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
;     MODIFIED 23 Mar. 2015 by Kyle R. Wodzicki.
;       Modified to higher order finite differencing.
;-

COMPILE_OPT IDL2
IF (N_PARAMS() LT 3) THEN MESSAGE, 'Incorrect number of inputs!'      ;Check number of inputs

IF (N_PARAMS() EQ 3) THEN BEGIN                                       ; IF only u, lon, lat input, shift to correct locations
  lat = DOUBLE(in_lon) & lon = DOUBLE(in_v) 
  v   = DOUBLE(in_u)   & u   = DOUBLE(in_u)
ENDIF ELSE BEGIN
  u   = DOUBLE(in_u)   & v   = DOUBLE(in_v)
  lon = DOUBLE(in_lon) & lat = DOUBLE(in_lat)
ENDELSE

IF (N_ELEMENTS(order)      EQ 0) THEN order      = 6                            ;Set order of the central finite difference
IF (N_ELEMENTS(derivative) EQ 0) THEN derivative = 1
IF (derivative GT 1)             THEN vectors    = 0

IF (SIZE(u,/N_DIMENSIONS) LT 2 OR SIZE(v, /N_DIMENSIONS) LT 2) THEN $ ;Check dimensions of input
  MESSAGE, 'U and V must be at least 2 dimensions!'

IF (MEAN(SIZE(u, /DIMENSIONS) EQ SIZE(v, /DIMENSIONS)) NE 1) THEN $   ;If not the same columns and rows
  MESSAGE, 'U and V arrays must be the same size!'

;Convert input longitude and latitude to 2-D arrays
dims = [N_ELEMENTS(lon), N_ELEMENTS(lat)]
dy   = REBIN(KWMAP_2POINTS(INTARR(dims[1]-1), lat[0:-2], INTARR(dims[1]-1), lat[1:*], /METERS), dims)
dx = []
FOR i = 0, dims[1]-1 DO BEGIN & $
  tmp_lat = REPLICATE(lat[i], dims[0]) & $
  dx = [[dx], [KWMAP_2POINTS(lon, tmp_lat, SHIFT(lon, 1), tmp_lat, /METERS)]] & $
ENDFOR

dims   = SIZE(u, /DIMENSIONS)                                          ;Get the dimensions of u
nDims  = N_ELEMENTS(dims)                                              ;Get number of dimensions of u
dx     = REBIN(dx, dims)
dy     = REBIN(dy, dims)

co  = FINITE_DIFF_COEFFICIENT(derivative, order)
nCo = N_ELEMENTS(co)

;=== Compute derivatives
IF (nCo EQ 3) THEN BEGIN
  xshift = INTARR(nDims, 3) & yshift = INTARR(nDims, 3)
  FOR i = -1, 1 DO BEGIN
    xshift[0,i+1] = i * (-1)
    yshift[1,i+1] = i 
  ENDFOR
  
  grad_x = (co[0] * SHIFT(u, xshift[*,0]) + co[1] * SHIFT(u, xshift[*,1]) + $
            co[2] * SHIFT(u, xshift[*,2]))/dx^derivative
  grad_y = (co[0] * SHIFT(v, yshift[*,0]) + co[1] * SHIFT(v, yshift[*,1]) + $
						co[2] * SHIFT(v, yshift[*,2]))/dy^derivative
ENDIF ELSE IF (nCo EQ 5) THEN BEGIN
  xshift = INTARR(nDims, 5) & yshift = INTARR(nDims, 5)
  FOR i = -2, 2 DO BEGIN
    xshift[0,i+2] = i * (-1)
    yshift[1,i+2] = i 
  ENDFOR
  
  grad_x = (co[0] * SHIFT(u, xshift[*,0]) + co[1] * SHIFT(u, xshift[*,1]) + $
            co[2] * SHIFT(u, xshift[*,2]) + co[3] * SHIFT(u, xshift[*,3]) + $
            co[4] * SHIFT(u, xshift[*,4]))/dx^derivative
  grad_y = (co[0] * SHIFT(v, yshift[*,0]) + co[1] * SHIFT(v, yshift[*,1]) + $
						co[2] * SHIFT(v, yshift[*,2]) + co[3] * SHIFT(v, yshift[*,3]) + $
						co[4] * SHIFT(v, yshift[*,4]))/dy^derivative
ENDIF ELSE IF (nCo EQ 7) THEN BEGIN
  xshift = INTARR(nDims, 7) & yshift = INTARR(nDims, 7)
  FOR i = -3, 3 DO BEGIN
    xshift[0,i+3] = i * (-1)
    yshift[1,i+3] = i 
  ENDFOR
  
  grad_x = (co[0] * SHIFT(u, xshift[*,0]) + co[1] * SHIFT(u, xshift[*,1]) + $
            co[2] * SHIFT(u, xshift[*,2]) + co[3] * SHIFT(u, xshift[*,3]) + $
            co[4] * SHIFT(u, xshift[*,4]) + co[5] * SHIFT(u, xshift[*,5]) + $
            co[6] * SHIFT(u, xshift[*,6]))/dx^derivative
  grad_y = (co[0] * SHIFT(v, yshift[*,0]) + co[1] * SHIFT(v, yshift[*,1]) + $
						co[2] * SHIFT(v, yshift[*,2]) + co[3] * SHIFT(v, yshift[*,3]) + $
            co[4] * SHIFT(v, yshift[*,4]) + co[5] * SHIFT(v, yshift[*,5]) + $
            co[6] * SHIFT(v, yshift[*,6]))/dy^derivative
ENDIF ELSE IF (nCo EQ 9) THEN BEGIN
  xshift = INTARR(nDims, 9) & yshift = INTARR(nDims, 9)
  FOR i = -4, 4 DO BEGIN
    xshift[0,i+4] = i * (-1)
    yshift[1,i+4] = i 
  ENDFOR
  
  grad_x = (co[0] * SHIFT(u, xshift[*,0]) + co[1] * SHIFT(u, xshift[*,1]) + $
            co[2] * SHIFT(u, xshift[*,2]) + co[3] * SHIFT(u, xshift[*,3]) + $
            co[4] * SHIFT(u, xshift[*,4]) + co[5] * SHIFT(u, xshift[*,5]) + $
            co[6] * SHIFT(u, xshift[*,6]) + co[7] * SHIFT(u, xshift[*,7]) + $
            co[8] * SHIFT(u, xshift[*,8]))/dx^derivative
  grad_y = (co[0] * SHIFT(v, yshift[*,0]) + co[1] * SHIFT(v, yshift[*,1]) + $
						co[2] * SHIFT(v, yshift[*,2]) + co[3] * SHIFT(v, yshift[*,3]) + $
            co[4] * SHIFT(v, yshift[*,4]) + co[5] * SHIFT(v, yshift[*,5]) + $
            co[6] * SHIFT(v, yshift[*,6]) + co[7] * SHIFT(v, yshift[*,7]) + $
            co[8] * SHIFT(v, yshift[*,8]))/dy^derivative
ENDIF

; Depending on the arrangement of the latitude values (ERA is positive
; to negative where as TMI is negative to positive) we must subtract
; the change in y because of shifting
IF KEYWORD_SET(vectors) THEN BEGIN
  grad = (lat[0] GT lat[-1]) ? {U_Comp : grad_x, V_Comp : grad_y} $
                             : {U_Comp : grad_x, V_Comp : -1*grad_y}
  RETURN, grad
ENDIF

IF (lat[0] GT lat[-1]) THEN BEGIN
	divergence=grad_x+grad_y
ENDIF ELSE BEGIN
	divergence=grad_x-grad_y
ENDELSE

;Clean up the edges
divergence[ 0:nCo-1,    *, *, *, *, *, *, *]=!VALUES.F_NaN
divergence[(-1*nCo):-1, *, *, *, *, *, *, *]=!VALUES.F_NaN
divergence[ *, 0:nCo-1,    *, *, *, *, *, *]=!VALUES.F_NaN
divergence[ *,(-1*nCo):-1, *, *, *, *, *, *]=!VALUES.F_NaN


RETURN, divergence

END