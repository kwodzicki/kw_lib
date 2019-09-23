FUNCTION KW_XCORR_V1, X, Y, Lag, $
  Covariance = Covariance, Double = doubleIn, $
  NORMALIZE = normalize
;+
; Name:
;   KW_XCORR
; Purpose:
;   An IDL function to compute the cross correlation Pxy(L) or cross
;   covariance Rxy(L) of two sample populations X and Y as a function
;   of the lag (L).
; Inputs:
;   X   : An n-element vector of type integer, float or double.
;   Y   : An n-element vector of type integer, float or double.
;   LAG : A scalar or n-element vector, in the interval [-(n-2), (n-2)],
;          of type integer that specifies the absolute distance(s) between
;          indexed elements of X.
; Keywords:
;   COVARIANCE : If set to a non-zero value, the sample cross
;                  covariance is computed.
;   DOUBLE     : If set to a non-zero value, computations are done in
;                  double precision arithmetic.
;   NORMALIZE  : Set to normalize the data:
;										For Pxy - Remove means and divide be variance of x and y
;                   For Rxy - Divide by N
; Author and History:
;   Kyle R. Wodzicki     Created 22 Mar. 2017
;
;   Adapted from C_CORRELATE with modification to match to xcorr and xcov
;     MATLAB functions
;-

COMPILE_OPT IDL2

typeX = SIZE(X, /TYPE)																													; Get data type of x input
typeY = SIZE(Y, /TYPE)																													; Get data type of y input
nX    = N_ELEMENTS(x)																														; Get number of elements in x

IF (nX NE N_ELEMENTS(y)) THEN $
	MESSAGE, "X and Y arrays must have the same number of elements."
IF (nX LT 2) THEN $
	MESSAGE, "X and Y arrays must contain 2 or more elements."

isComplex = (typeX EQ 6) OR (typeX EQ 9) OR (typeY EQ 6) OR (typeY EQ 9)				; Determine if any of the inputs are complex

;If the DOUBLE keyword is not set then the internal precision and
;result are identical to the type of input.
useDouble = (N_ELEMENTS(doubleIn) EQ 1) ? KEYWORD_SET(doubleIn) : $
  (typeX EQ 5 OR typeY EQ 5) OR (typeX EQ 9 OR typeY EQ 9)

nLag = N_ELEMENTS(Lag)
Cross = useDouble ? (isComplex ? DCOMPLEXARR(nLag) : DBLARR(nLag)) $
									:	(isComplex ? COMPLEXARR(nLag)  : FLTARR(nLag))

IF KEYWORD_SET(covariance) OR KEYWORD_SET(normalize) THEN BEGIN
	Xd = x - TOTAL(X, Double = useDouble) / nX ;Deviations
	Yd = y - TOTAL(Y, Double = useDouble) / nX
ENDIF ELSE BEGIN
	Xd = x
	Yd = y
ENDELSE

FOR k = 0L, nLag-1 DO $
	Cross[k] = (Lag[k] GE 0) ? $																									; Note the reversal of the variables for negative lags.
		TOTAL(Xd[Lag[k]:*] * Yd[0:nX - Lag[k] - 1L]) : $
		TOTAL(Xd[0:nX + Lag[k] - 1L] * Yd[-Lag[k]:*])

IF KEYWORD_SET(normalize) THEN $
	Cross = KEYWORD_SET(covariance) ? $
	  TEMPORARY(Cross) / nx : $
	  TEMPORARY(Cross) / SQRT(TOTAL(Xd^2)*TOTAL(Yd^2))

RETURN, useDouble ? Cross : (isComplex ? COMPLEX(Cross) : FLOAT(Cross))

END