FUNCTION KW_LAPLACIAN, in_array, x, y


;+
; Name:
;		KW_LAPLACIAN
; Purpose:
;		To compute the laplacian of a given array. Developed mainly
;		for use in recreating Fig. 1 of Berry and Reeder and also because
;		it will be needed when finding the ITCZ if there method is to
;		be used.
; Author and History:
;		Kyle R. Wodzicki		Created 23 Sep. 2014
;-

COMPILE_OPT IDL2

IF SIZE(x, /N_DIMENSIONS) EQ 1 THEN BEGIN
	dims = [N_ELEMENTS(x), N_ELEMENTS(y)]
	x_2D = REBIN(x, dims)
	y_2D = REBIN(TRANSPOSE(y), dims)
ENDIF ELSE BEGIN
	x_2D = x
	y_2D = y
ENDELSE

x0 = SHIFT(x_2D, -1, 0) & x1 = SHIFT(x_2D, 1,  0)
y0 = SHIFT(y_2D,  0, 1) & y1 = SHIFT(y_2D, 0, -1)

d_x = KW_MAP_2POINTS(x0, y_2D, x1, y_2D, /METERS)									;Change in distance over x
d_y = KW_MAP_2POINTS(x_2D, y0, x_2D, y1, /METERS)									;Change in distance over y

grad_x = (SHIFT(in_array, -1, 0) - SHIFT(in_array, 1,  0)) / d_x	
grad_x = (SHIFT(grad_x,   -1, 0) - SHIFT(grad_x,   1,  0)) / d_x


grad_y = (SHIFT(in_array, 0, 1) - SHIFT(in_array, 0, -1)) / d_y
grad_y = (SHIFT(grad_y,   0, 1) - SHIFT(grad_y,   0, -1)) / d_y

; Depending on the arrangement of the latitude values (ERA is positive
; to negative where as TMI is negative to positive) we must subtract
; the change in y because of shifting
IF (x[0] GT y[-1]) THEN BEGIN
	laplace=grad_x+grad_y
ENDIF ELSE BEGIN
	laplace=grad_x-grad_y
ENDELSE

; Clean up edges
laplace[0,*]=!VALUES.F_NaN & laplace[-1,*]=!VALUES.F_NaN
laplace[*,0]=!VALUES.F_NaN & laplace[*,-1]=!VALUES.F_NaN

RETURN, laplace

END
