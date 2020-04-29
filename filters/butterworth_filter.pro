FUNCTION BUTTERWORTH_FILTER, omega, cutoff, order, gain, HIPASS = hipass
;+
; Name:
;   BUTTERWORTH_FILTER 
; Purpose:
;   An IDL function to generate gain values for a low-pass Butterworth filter.
; Inputs:
;   omega  : Frequencies of spectra
;   cutoff : Frequency of the cutoff (approximately the -3dB frequency)
;   order  : Order of the filter. Default is 4th order
;   gain   : DC gain, i.e., gain at zero frequency. Default is zero
; Outputs:
;   Returns an array of amplitude values for the filter
; Keywords:
;   HIPASS  : Set to return hi-pass filter. Default is low-pass.
; Author and History:
;   Kyle R. Wodzicki     Created 11 Aug. 2017
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(order) EQ 0 THEN order = 4
IF N_ELEMENTS(gain)  EQ 0 THEN gain  = 1.0

IF KEYWORD_SET(hipass) THEN $
  RETURN, gain / ( 1.0 + (cutoff / omega)^(2*order) ) $
ELSE $
  RETURN, gain / ( 1.0 + (omega / cutoff)^(2*order) )


END