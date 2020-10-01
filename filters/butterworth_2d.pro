FUNCTION BUTTERWORTH_2D, x, y, dx, dy, cutoff, ORDER = order
;+
; Name:
;   BUTTERWORTH_2D
; Purpose:
;   An IDL function to generate a 2D Butterworth filter.
; Inputs:
;   x      : Values along x-axis of data; typically columns of data; 1D
;   y      : Values along y-axis of data; typically rows of data; 1D
;   dx     : Spacing for x-values
;   dy     : Spacing for y-values
;   cutoff : Cut of frequency
; Outputs:
;   Returns 2D array containing filter coefficients
; Keywords:
;   ORDER   : Order of the filter, default is 4th order
; Author and History:
;   Kyle R. Wodzicki
;
; Notes:
;  From http://fourier.eng.hmc.edu/e101/lectures/Fourier_Analysis/node10.html
;-
COMPILE_OPT IDL2

IF N_ELEMENTS( order ) EQ 0 THEN order = 4

m  = N_ELEMENTS(x)
n  = N_ELEMENTS(y)

k0 = m / 2
l0 = m / 2

k  = REBIN(LONARR( m ), m, n)
l  = REBIN(REFORM(LONARR( n ), 1, n), m, n)

denom = 1 + ( ( (k - k0)^2 + (l-l0)^2 ) / cutoff^2 )^order

RETURN, 1.0 / denom

END