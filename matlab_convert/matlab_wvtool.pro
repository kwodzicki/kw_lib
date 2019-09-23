PRO MATLAB_WVTOOL, window_in, OVERPLOT = overplot, POSITION = position, _EXTRA = extra
;+
; Name:
;   WVTOOL
; Purpose:
;   An IDL procedure designed to work like the WVTOOL command in MatLab
; Inputs:
;   window_in : Values for the window to plot
; Keywords:
;		Overplot : Set to plot over existing window
; Author and History:
;   Kyle R. Wodzicki     Created 10 Apr. 2017
;-

COMPILE_OPT IDL2

n = N_ELEMENTS(window_in)																												; Get the size of the input data

IF N_ELEMENTS(position) EQ 0 THEN $																							; Set up figure positions if the POSITION keyword is NOT set
	position = cgLayout([2,1], OYMARGIN=[4, 2], OXMARGIN=[4,2], XGAP=6, ASPECT=1)

KWPLOT, INDGEN(n), window_in, $																									; Plot the window in the time domain
	POSITION = position[*,0], $
	xStyle   = 1, $
	yRange   = [0, 1.1], $
	yStyle   = 1, $
	xTitle   = 'Samples', $
	yTitle   = 'Amplitude (arb.)', $
	NoErase  = KEYWORD_SET(overplot), $
	_EXTRA = extra

nn     = 2^12																																		; Set nn for padding the filter
n_diff = nn- n																																	; Compute how many zeros must be padded

yyy = FFT( [window_in, FLTARR(n_diff)] )																				; Pad the window and compute the forward transform
yyy = 20 * ALOG10( ABS( yyy / MAX(yyy, /ABSOLUTE) ) )														; Compute the power, in decibels
freq = FINDGEN(nn/2)/(nn/2-1)																										; Compute normalized freqencies

KWPLOT,	freq, yyy[0:nn/2], $																										; Plot window in the frequency domain
	xTitle   = 'Normalized Frequency!C(x '+cgsymbol('pi')+' rad/sample)', $
	yTitle   = 'Magnitude (dB)', $
	POSITION = position[*,1], $
	/NoErase, $
	_EXTRA = extra

END
