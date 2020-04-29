FUNCTION KW_COHERENCE, time, xx, yy, _EXTRA = _extra
;+
; Name:
;   KW_COHERENCE
; Purpose:
;   A function to compute cherence of two time series
; Inputs:
;   time   : Array of time values associated with data
;   xx     : Data for first time series
;   yy     : Data fro second time series
; Keywords:
;   All keywords accepted by FFT() function
; Returns:
;   Coherence spectra for time series
;-
COMPILE_OPT IDL2

Sxx = KW_PSD(time, xx,     _EXTRA = _extra)
Syy = KW_PSD(time, yy,     _EXTRA = _extra)
Sxy = KW_PSD(time, xx, yy, _EXTRA = _extra)
RETURN, ABS(Sxy)^2 / ( Sxx * Syy )
;RETURN, ABS(Sxy)^2 / SQRT( Sxx * Syy )

END 
