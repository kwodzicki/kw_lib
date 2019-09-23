FUNCTION FINITE_DIFF_COEFFICIENT, derivative, order
; Function to return the Central finite difference coefficients for calculation

IF (derivative EQ 1) THEN BEGIN
  CASE order OF
    2    : co = [-1.0D0/2.0D0,0.0D0,1.0D0/2.0D0]
    4    : co = [1.0D0/12.0D0,-2.0D0/3.0D0,0.0D1,2.0D0/3.0D0,-1.0D0/12.0D0]
    6    : co = [-1.0D0/60.0D0,3.0D0/20.0D0,-3.0D0/4.0D0,0.0D2,3.0D0/4.0D0,-3.0D0/20.0D0,1.0D0/60.0D0]
    8    : co = [1.0D0/280.0D0,-4.0D0/105.0D0,1.0D0/5.0D0,-4.0D0/5.0D0,0.0D3,4.0D0/5.0D0,-1.0D0/5.0D0,4.0D0/105.0D0,-1.0D0/280.0D0]
    ELSE : MESSAGE, 'Order not found!!!'
  ENDCASE
ENDIF ELSE IF (derivative EQ 2) THEN BEGIN
  CASE order OF
    2    : co = [1.0D0,-2.0D0,1.0D0]
    4    : co = [-1/12,4.0D0/3.0D0,-5.0D0/2.0D0,4.0D0/3.0D0,-1.0D0/12.0D0]
    6    : co = [1.0D0/90.0D0,-3.0D0/20.0D0,3.0D0/2.0D0,-49.0D0/18.0D0,3.0D0/2.0D0,-3.0D0/20.0D0,1.0D0/90.0D0]
    8    : co = [-1.0D0/560.0D0,8.0D0/315.0D0,-1.0D0/5.0D0,8.0D0/5.0D0,-205.0D0/72.0D0,8.0D0/5.0D0,-1.0D0/5.0D0,8.0D0/315.0D0,-1.0D0/560.0D0]
    ELSE : MESSAGE, 'Order not found!!!'
  ENDCASE
ENDIF ELSE IF (derivative EQ 3) THEN BEGIN
  CASE order OF
    2    : co = [-1.0D0/2.0D0,1.0D0,0.0D0,-1.0D0,1.0D0/2.0D0]
    4    : co = [1.0D0/8.0D0,-1.0D0,13.0D0/8.0D0,0.0D0,-13.0D0/8.0D0,1.0D0,-1.0D0/8.0D0]
    6    : co = [-7.0D0/240.0D0,3.0D0/10.0D0,-169.0D0/120.0D0,61.0D0/30.0D0,0.0D0,-61.0D0/30.0D0,169.0D0/120.0D0,-3.0D0/10.0D0,7.0D0/240.0D0]
    ELSE : MESSAGE, 'Order not found!!!'
  ENDCASE
ENDIF ELSE IF (derivative EQ 4) THEN BEGIN
  CASE order OF
    2    : co = [1.0D0,-4.0D0,6.0D0,-4.0D0,1.0D0]
    4    : co = [-1.0D0/6.0D0,2.0D0,-13.0D0/2.0D0,28.0D0/3.0D0,-13.0D0/2.0D0,2.0D0,-1.0D0/6.0D0]
    6    : co = [7.0D0/240.0D0,-2.0D0/5.0D0,169.0D0/60.0D0,-122.0D0/15.0D0,91.0D0/8.0D0,-122.0D0/15.0D0,169.0D0/60.0D0,-2.0D0/5.0D0,7.0D0/240.0D0]
    ELSE : MESSAGE, 'Order not found!!!'
  ENDCASE
ENDIF

RETURN, co
END

FUNCTION KW_DIV_1D, in_val, in_x, $
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
IF (N_PARAMS() LT 2) THEN MESSAGE, 'Incorrect number of inputs!'      ;Check number of inputs

val = DOUBLE(in_val)
x   = in_x

;IF (N_PARAMS() EQ 3) THEN BEGIN                                       ; IF only u, lon, lat input, shift to correct locations
;  lat = DOUBLE(in_lon) & lon = DOUBLE(in_v) 
;  v   = DOUBLE(in_u)   & u   = DOUBLE(in_u)
;ENDIF ELSE BEGIN
;  u   = DOUBLE(in_u)   & v   = DOUBLE(in_v)
;  lon = DOUBLE(in_lon) & lat = DOUBLE(in_lat)
;ENDELSE

IF (N_ELEMENTS(order)      EQ 0) THEN order      = 6                            ;Set order of the central finite difference
IF (N_ELEMENTS(derivative) EQ 0) THEN derivative = 1
IF (derivative GT 1)             THEN vectors    = 0

;IF (SIZE(u,/N_DIMENSIONS) LT 2 OR SIZE(v, /N_DIMENSIONS) LT 2) THEN $ ;Check dimensions of input
;  MESSAGE, 'U and V must be at least 2 dimensions!'
;
;IF (MEAN(SIZE(u, /DIMENSIONS) EQ SIZE(v, /DIMENSIONS)) NE 1) THEN $   ;If not the same columns and rows
;  MESSAGE, 'U and V arrays must be the same size!'

dims   = SIZE(val, /DIMENSIONS)                                          ;Get the dimensions of u
nDims  = N_ELEMENTS(dims)                                              ;Get number of dimensions of u
dx     = x - SHIFT(x,1)

co  = FINITE_DIFF_COEFFICIENT(derivative, order)
nCo = N_ELEMENTS(co)

;=== Compvalte derivatives
IF (nCo EQ 3) THEN BEGIN
  xshift = REVERSE(INDGEN(3)-1)
  
  grad_x = (co[0] * SHIFT(val, xshift[0]) + co[1] * SHIFT(val, xshift[1]) + $
            co[2] * SHIFT(val, xshift[2]))/dx^derivative
ENDIF ELSE IF (nCo EQ 5) THEN BEGIN
  xshift = REVERSE(INDGEN(5)-2)
  
  grad_x = (co[0] * SHIFT(val, xshift[0]) + co[1] * SHIFT(val, xshift[1]) + $
            co[2] * SHIFT(val, xshift[2]) + co[3] * SHIFT(val, xshift[3]) + $
            co[4] * SHIFT(val, xshift[4]))/dx^derivative
ENDIF ELSE IF (nCo EQ 7) THEN BEGIN
  xshift = REVERSE(INDGEN(7)-3)
  
  grad_x = (co[0] * SHIFT(val, xshift[0]) + co[1] * SHIFT(val, xshift[1]) + $
            co[2] * SHIFT(val, xshift[2]) + co[3] * SHIFT(val, xshift[3]) + $
            co[4] * SHIFT(val, xshift[4]) + co[5] * SHIFT(val, xshift[5]) + $
            co[6] * SHIFT(val, xshift[6]))/dx^derivative
ENDIF ELSE IF (nCo EQ 9) THEN BEGIN
  xshift = REVERSE(INDGEN(9)-4)
  
  grad_x = (co[0] * SHIFT(val, xshift[0]) + co[1] * SHIFT(val, xshift[1]) + $
            co[2] * SHIFT(val, xshift[2]) + co[3] * SHIFT(val, xshift[3]) + $
            co[4] * SHIFT(val, xshift[4]) + co[5] * SHIFT(val, xshift[5]) + $
            co[6] * SHIFT(val, xshift[6]) + co[7] * SHIFT(val, xshift[7]) + $
            co[8] * SHIFT(val, xshift[8]))/dx^derivative
ENDIF


;Clean valp the edges
grad_x[0:nCo-1]=!VALUES.F_NaN
grad_x[-1*nCo-1:-1]=!VALUES.F_NaN

RETURN, grad_x

END