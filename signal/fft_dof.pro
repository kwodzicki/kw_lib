FUNCTION FFT_DOF, n, nperseg, noverlap
;+
; Name:
;   FFT_DOF
; Purpose:
;   Degress of freedom for FFT based on lenght of time series,
;   length of segments, and number of overlapping pints.
;   Note that this assumes that all segments are independent.
; Inputs:
;   n        : Number of points in time series
;   nperseg  : Number of points per segment
;   noverlap : Number of overlapping points
; Keywords:
;   None.
; Returns:
;   Number of degress of freedom
;-

COMPILE_OPT IDL2

IF N_PARAMS()           LT 2 THEN MESSAGE, 'Incorrect number of inputs'
IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = 0

step = nperseg - noverlap

RETURN, 2 * (n - noverlap) / step

END 
