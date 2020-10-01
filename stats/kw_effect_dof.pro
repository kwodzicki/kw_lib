FUNCTION KW_EFFECT_DoF, x, y, LEITH = Leith
;+
; Name:
;   EFFECT_DoF
; Purpose:
;   An IDL function to compute the effective degrees of freedom of two records 
;   of equal length
; Inputs:
;   x   : Record 1
;   y   : record 2
;   lag : lag values
; Outputs:
;   Effective degress of freedom
; Keywords:
;   LEITH   : Set to reduce number of independent samples using the method of
;              Leith (1973), where samples are reduced by
;              N / (2 x e-folding of autocorrelation)
; Dependencies:
;   MATLAB_XCORR
; Author and History:
;   Kyle R. Wodzicki     Created 23 Mar. 2017
;-
COMPILE_OPT IDL2

n = N_ELEMENTS(x)																		  ; Get number of elements in x
IF (n NE N_ELEMENTS(y)) THEN $
	MESSAGE, "X and Y arrays must have the same number of elements."
IF (n LT 2) THEN $
	MESSAGE, "X and Y arrays must contain 2 or more elements."

IF ~KEYWORD_SET(Leith) THEN BEGIN
;  cxx   = KW_XCORR(x, x, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x 
;  cyy   = KW_XCORR(y, y, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x
;  cxy   = KW_XCORR(x, y, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute cross-covariance of x and y
;  denom = TOTAL( cxx * cyy + cxy * REVERSE(cxy) )
;  varx  = VARIANCE(x)
;  vary  = VARIANCE(y)
;  lags  = INDGEN( n * 2 - 1 ) - (n-1)
;  cxx   = KW_XCORR(x, x, SCALEOPT='UNBIASED', /COVARIANCE) 						  ; Compute auto-covariance of x 
;  cyy   = KW_XCORR(y, y, SCALEOPT='UNBIASED', /COVARIANCE) 						  ; Compute auto-covariance of x
;  cxy   = KW_XCORR(x, y, SCALEOPT='UNBIASED', /COVARIANCE) 						  ; Compute cross-covariance of x and y
;  cxx   = C_CORRELATE(x, x, lags, /COVARIANCE) 						  ; Compute auto-covariance of x 
;  cyy   = C_CORRELATE(y, y, lags, /COVARIANCE) 						  ; Compute auto-covariance of x
;  cxy   = C_CORRELATE(x, y, lags, /COVARIANCE) 						  ; Compute cross-covariance of x and y
;  denom = TOTAL( (cxx * cyy + cxy * REVERSE(cxy))/(varx*vary) )
  cxx   = KW_XCORR(x, x, SCALEOPT='COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x 
  cyy   = KW_XCORR(y, y, SCALEOPT='COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x
  cxy   = KW_XCORR(x, y, SCALEOPT='COEFF', /COVARIANCE) 						  ; Compute cross-covariance of x and y
  denom = TOTAL( cxx * cyy + cxy * REVERSE(cxy) )
  IF denom LT 1.0 THEN RETURN, !Values.F_NaN ELSE RETURN, n / denom
ENDIF ELSE BEGIN
  a_cor = MATLAB_XCORR(y, y, SCALEOPT = 'coeff', /COVARIANCE)
  id = WHERE(a_cor[n-1:*] LT (1.0/EXP(1)), CNT)
  IF (CNT GT 0) THEN $
  	RETURN, N / ( 2 * id[0] ) > 1 $
  ELSE $
;  	MESSAGE, 'Autocorrelation never falls below 1/e!', /CONTINUE
  	RETURN, 1
ENDELSE
END
