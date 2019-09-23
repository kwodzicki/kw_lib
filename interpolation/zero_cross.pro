FUNCTION ZERO_CROSS, x, y
;+
; Name:
;   ZERO_CROSS
; Purpose:
;   An IDL function to locate y-axis zero crossing using
;   linear interpolation
; Inputs:
;   x : 1D array of x-values
;   y : 1D array of y-values
; Outputs:
;   Returns an array with x values the correspond to zero crossings
; Keywords:
;   None.
; Author and history:
;   Kyle R. Wodzicki     Created 12 Mar. 2019
;-
COMPILE_OPT IDL2

cross = LIST()                                                                  ; Initialize list
FOR i = 0, N_ELEMENTS(x)-2 DO $                                                 ; Iterate over all values
  IF y[i] EQ 0 THEN $                                                           ; If y[i] EQ 0, then it is a crossing
  	cross.ADD, x[i] $                                                           ; Add x[i] to cross list
  ELSE IF ((y[i] GT 0) AND (y[i+1] LT 0)) OR $
          ((y[i] LT 0) AND (y[i+1] GT 0)) THEN $                                ; Else, if y[i] and y[i+1] straddle y=0
  	cross.ADD, x[i] - y[i] * (x[i+1]-x[i]) / DOUBLE(y[i+1]-y[i])                ; Interpolate to x-value where y=0

RETURN, cross.ToArray(/No_Copy)                                                 ; Convert list to array and return array
END