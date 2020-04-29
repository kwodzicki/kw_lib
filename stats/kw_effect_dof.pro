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

IF NOT KEYWORD_SET(Leith) THEN BEGIN
;  cxx = MATLAB_XCORR(x, x, SCALEOPT = 'COEFF', /COVARIANCE)							  ; Compute auto-covariance of x 
;  cyy = MATLAB_XCORR(y, y, SCALEOPT = 'COEFF', /COVARIANCE)							  ; Compute auto-covariance of x
;  cxy = MATLAB_XCORR(x, y, SCALEOPT = 'COEFF', /COVARIANCE)							  ; Compute cross-covariance of x and y
  varx  = VARIANCE(x)
  vary  = VARIANCE(y)
  cxx   = KW_XCORR(x, x, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x 
  cyy   = KW_XCORR(y, y, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute auto-covariance of x
  cxy   = KW_XCORR(x, y, SCALEOPT = 'COEFF', /COVARIANCE) 						  ; Compute cross-covariance of x and y
  ;denom = TOTAL( (cxx * cyy + cxy * REVERSE(cxy))/(varx*vary) )
  denom = TOTAL( cxx * cyy + cxy * REVERSE(cxy) )
  IF denom LT 1.0 THEN RETURN, !Values.F_NaN ELSE RETURN, n / denom
;  cxx = MATLAB_XCORR(x, x, /COVARIANCE)                                                   ; Compute auto-covariance of x 
;  cyy = MATLAB_XCORR(y, y, /COVARIANCE)                                                   ; Compute auto-covariance of x
;  cxy = MATLAB_XCORR(x, y, /COVARIANCE)                                                   ; Compute cross-covariance of x and y
;  RETURN, n / TOTAL( (cxx * cyy + cxy * REVERSE(cxy)) / (VARIANCE(x) * VARIANCE(y)) )                     ; Return effective degrees of freedom; 
;  varx = VARIANCE(x)
;  vary = VARIANCE(y)
;  cxx = MATLAB_XCORR(x, x, SCALEPLOT = 'coeff', /COVARIANCE) / varx                       ; Compute auto-covariance of x 
;  cyy = MATLAB_XCORR(y, y, SCALEPLOT = 'coeff', /COVARIANCE) / vary                       ; Compute auto-covariance of x
;  cxy = MATLAB_XCORR(x, y, SCALEPLOT = 'coeff', /COVARIANCE)                              ; Compute cross-covariance of x and y
;  cyx = MATLAB_XCORR(y, x, SCALEPLOT = 'coeff', /COVARIANCE)
;  RETURN, n / TOTAL( cxx*cyy + cxy * cyx / (varx * vary) )                                ; Return effective degrees of freedom; 
;  varx = VARIANCE(x)
;  vary = VARIANCE(y)
;  cxx = MATLAB_XCORR(x, x, /COVARIANCE) / varx                                            ; Compute auto-covariance of x 
;  cyy = MATLAB_XCORR(y, y, /COVARIANCE) / vary                                            ; Compute auto-covariance of x
;  cxy = MATLAB_XCORR(x, y, /COVARIANCE)                                                   ; Compute cross-covariance of x and y
;  cyx = MATLAB_XCORR(y, x, /COVARIANCE)
;  RETURN, n / TOTAL( cxx*cyy + cxy * cyx / (varx * vary) )                                ; Return effective degrees of freedom; 
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
