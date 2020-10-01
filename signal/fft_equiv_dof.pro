FUNCTION FFT_EQUIV_DOF, win_in, nn, noverlap
;+
; Name:
;   FFT_EQUIV_DOF
; Purpose:
;   Function to determine equivalent degrees of freedom for FFTs
;   based on the window, time series length, and number of overlapping
;   points. This code is based on the MATLAB code from:
;     http://pordlabs.ucsd.edu/sgille/sioc221a_f17/lecture16_notes.pdf
;   Formula for the calculation is from 
;     Percival and Walden: Spectral Analysis for Physical Applications, Cambridge University Press, 1993
; Inputs:
;   win      : Array containing values for window
;   nn       : Total number of points in the time series
;   noverlap : (Optional) Number of overlapping points; defaults to zero (0)
; Keywords:
;   None.
; Returns:
;   Returns equivalent degrees of freedom
;-
COMPILE_OPT IDL2


IF N_PARAMS() LT 2 THEN MESSAGE, 'Incorrect number of inputs'
IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = 0

win  = win_in / SQRT(TOTAL(win_in^2))

Ns   = win.LENGTH                 ; Length of segments; assumes same size as window
step = Ns - noverlap              ; Step, offset between segments
Nb   = (nn-Ns) / step + 1             ; Number of segments (or blocks) of data
NNb  = FLOAT(Nb)

;sumh = MAKE_ARRAY(Nb, VALUE=!Values.F_NaN)
;FOR i = 1, Nb-1 DO BEGIN
;  IF i*noverlap LT Ns THEN BEGIN
;    sumh[i] = (1-i/NNb)*ABS( TOTAL( win[0:Ns-i*noverlap-1] * win[i*noverlap:*] ) )^2
;  ENDIF
;ENDFOR

IF noverlap GT 0 THEN BEGIN
  sumh = MAKE_ARRAY(Nb, VALUE=!Values.F_NaN)
  FOR i = 1, Nb-1 DO $
    sumh[i] = (1-i/NNb)*ABS( TOTAL( win[0:noverlap-1] * win[-noverlap:*] ) )^2
ENDIF ELSE $
  sumh = !Values.F_NaN
STOP

RETURN, 2*Nb / (1 + 2*TOTAL(sumh, /NaN) )
RETURN, FLOOR( 2*Nb / (1 + 2*TOTAL(sumh, /NaN) ) )

END
