FUNCTION KW_REGRESS, x, y, $
  VERBOSE     = verbose, $
  THRES       = thres,   $
  _REF_EXTRA  = ref_extra
;+ 
; Name:
;   KW_REGRESS
; Purpose:
;   A function to extend the IDL regress function. This function
;   adds checking to ensure that only finite data are used in the
;   regress function.
; Inputs:
;   x :   X values
;   y :   Y Values
; Outputs:
;   Returns the slope of the linear regression
; Keywords:
;   VERBOSE  : Print warning when less than 2 valid points found
;   THRES    : Set the threshold for the percentage of points that can be
;               NOT finite before a NaN is returned. Default is 50%.
;   Any keywords that REGRESS accepts
; Author and History:
;   Kyle R. Wodzicki     Created 05 Apr. 2016
;
; Modified:
;   01 Jun. 2016 by K.R.W. - Added the THRES keyword.
;-
COMPILE_OPT IDL2

IF (N_PARAMS() NE 2) THEN MESSAGE, 'Incorrect number of inputs!'
IF (N_ELEMENTS(thres) EQ 0) THEN thres = 0.5                                    ; Set default threshold

id = WHERE(FINITE(x) AND FINITE(y), CNT)
IF (FLOAT(CNT)/N_ELEMENTS(x) GE thres) AND (CNT GE 2) THEN $
  RETURN, REGRESS(x[id], y[id], _EXTRA = ref_extra) $
ELSE BEGIN
  IF KEYWORD_SET(verbose) THEN $
    MESSAGE, 'Less than two (2) valid data points found!', /CONTINUE
  RETURN, !Values.F_NaN
ENDELSE
END