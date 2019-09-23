FUNCTION KW_C_Correlate, X, Y, Lag, $
  Covariance = Covariance, Double = doubleIn, $
  NORMALIZE = normalize
;+
; NAME:
;       KW_C_CORRELATE
;
; PURPOSE:
;       This function computes the cross correlation Pxy(L) or cross
;       covariance Rxy(L) of two sample populations X and Y as a function
;       of the lag (L).
;
; CATEGORY:
;       Statistics.
;
; CALLING SEQUENCE:
;       Result = C_correlate(X, Y, Lag)
;
; INPUTS:
;       X:    An n-element vector of type integer, float or double.
;
;       Y:    An n-element vector of type integer, float or double.
;
;     LAG:    A scalar or n-element vector, in the interval [-(n-2), (n-2)],
;             of type integer that specifies the absolute distance(s) between
;             indexed elements of X.
;
; KEYWORD PARAMETERS:
;       COVARIANCE:    If set to a non-zero value, the sample cross
;                      covariance is computed.
;
;       DOUBLE:        If set to a non-zero value, computations are done in
;                      double precision arithmetic.
;
; EXAMPLE
;       Define two n-element sample populations.
;         x = [3.73, 3.67, 3.77, 3.83, 4.67, 5.87, 6.70, 6.97, 6.40, 5.57]
;         y = [2.31, 2.76, 3.02, 3.13, 3.72, 3.88, 3.97, 4.39, 4.34, 3.95]
;
;       Compute the cross correlation of X and Y for LAG = -5, 0, 1, 5, 6, 7
;         lag = [-5, 0, 1, 5, 6, 7]
;         result = c_correlate(x, y, lag)
;
;       The result should be:
;         [-0.428246, 0.914755, 0.674547, -0.405140, -0.403100, -0.339685]
;
;   Adapted from C_CORRELATE with modification to match to xcorr and xcov
;     MATLAB functions
;-

COMPILE_OPT IDL2

typeX = SIZE(X, /TYPE)
typeY = SIZE(Y, /TYPE)
nX    = N_ELEMENTS(x)

IF (nX NE N_ELEMENTS(y)) THEN $
	MESSAGE, "X and Y arrays must have the same number of elements."

IF (nX LT 2) THEN $
	MESSAGE, "X and Y arrays must contain 2 or more elements."

isComplex = (typeX EQ 6) OR (typeX EQ 9) OR (typeY EQ 6) OR (typeY EQ 9)

;If the DOUBLE keyword is not set then the internal precision and
;result are identical to the type of input.
useDouble = (N_ELEMENTS(doubleIn) eq 1) ? $
	 KEYWORD_SET(doubleIn) : $
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

;FOR k = 0L, nLag-1 DO $
;	Cross[k] = (Lag[k] GE 0) ? $															; Note the reversal of the variables for negative lags.
;		TOTAL(Xd[0:nX - Lag[k] - 1L] * Yd[Lag[k]:*]) : $
;		TOTAL(Yd[0:nX + Lag[k] - 1L] * Xd[-Lag[k]:*])
FOR k = 0L, nLag-1 DO $
	Cross[k] = (Lag[k] GE 0) ? $															; Note the reversal of the variables for negative lags.
		TOTAL(Xd[Lag[k]:*] * Yd[0:nX - Lag[k] - 1L]) : $
		TOTAL(Xd[0:nX + Lag[k] - 1L] * Yd[-Lag[k]:*])

IF KEYWORD_SET(normalize) THEN $
	Cross = KEYWORD_SET(covariance) ? $
	  TEMPORARY(Cross) / nx : $
	  TEMPORARY(Cross) / SQRT(TOTAL(Xd^2)*TOTAL(Yd^2))


RETURN, useDouble ? Cross : (isComplex ? COMPLEX(Cross) : FLOAT(Cross))

END