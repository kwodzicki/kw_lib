FUNCTION KW_FFT_FREQ, nn, dt, TIME=time, DOUBLE=double, CENTER = center
;+
; Name:
;   KW_FFT_FREQ
; Purpose:
;   An IDL function to compute frequencies for FFT specturm
; Inputs:
;   nn  : Number of samples in data; overridden by TIME keyword
;   dt  : Sample rate of data; overridden by TIME keyword
; Keywords:
;   TIME   : An array containing time values associated with data
;   DOUBLE : Set to return double-precision frequencies
;   CENTER : Set to center values; default is to have 0-max, (-max)-0
;             frequency values to match default output of FFT()
; Returns:
;   Array with nn elements (or same number of elements as TIME) containing
;   frequencies.
; Author and History:
;   Kyle R. Wodzicki    Created 13 Mar. 2020
;-
COMPILE_OPT IDL2
IF N_ELEMENTS(time) GT 0 THEN BEGIN
  nn = N_ELEMENTS(time)
  dt = time[1] - time[0]
ENDIF ELSE IF (N_PARAMS() NE 2) THEN $
  MESSAGE, 'Incorrect number of inputs'

IF KEYWORD_SET(double) THEN x = DINDGEN( (nn-1)/2 ) + 1 $
                       ELSE x = FINDGEN( (nn-1)/2 ) + 1

IF (nn MOD 2) EQ 0 THEN freq = [0.0, x, nn/2, -nn/2 + x] $
                   ELSE freq = [0.0, x,       -(nn/2 + 1) + x]

IF KEYWORD_SET(center) THEN BEGIN
  dx   = nn / 2 - ((nn MOD 2) EQ 0)
  freq = SHIFT(freq, dx)
ENDIF

RETURN, freq / (nn * dt)

END
