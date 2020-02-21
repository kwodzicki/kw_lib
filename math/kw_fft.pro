FUNCTION KW_FFT, array, direction, $
	SAMPLE_RATE = sample_rate, $
	FREQUENCY   = frequency, $
  CENTER      = center, $
  DIMENSION   = dimension, $
	DOUBLE      = double, $
	_EXTRA      = _extra
;+
; Name:
;   KW_FFT
; Purpose:
;   A wrapper for the IDL FFT function that adds the sample_rate and
;   frequency keywords for automatic computing of frequency values
;   for plotting.
; Inputs:
;   Same as FFT()
; Keywords:
;   SAMPLE_RATE : Scalar or array of sample rates for each dimension
;                  of the data, if this is NOT set, no frequencies computed
;   FREQUENCY   : A named variable to return list to. The list will
;                  have the same number of entires as the number of 
;                  dimensions in the data
;   Same as FFT
;-
COMPILE_OPT IDL2

IF (N_ELEMENTS(direction)   EQ 0) THEN direction = -1
IF (N_ELEMENTS(sample_rate) GT 0) THEN BEGIN
  info      = SIZE(array)																												; Information about input array
  even      = ( info[0:info[0]] MOD 2 ) EQ 0																		; Determine even numbered dimensions
  frequency = LIST()																														; List to hold frequencies for each dimension
  FOR i = 1, info[0] DO BEGIN																										; Iterate over dimension
		IF KEYWORD_SET(double) THEN $																								; If double precission
			X = DINDGEN( (info[i] - 1)/2 ) + 1 $																			; Create list double pression array
		ELSE $
			X = FINDGEN( (info[i] - 1)/2 ) + 1

		IF even[i] THEN $																														; If dimension even
		  freq = [0.0, X, info[i]/2, -info[i]/2 + X] $															; Base frequency array
		ELSE $																																			; If odd
		  freq = [0.0, X, -(info[i]/2 + 1) + X]																			; Base frequency array

		frequency.ADD,  freq / ( info[i] * sample_rate[i-1] )												; Divide base frequency array by (number of values in dimesion times sample rate) and add to list
  ENDFOR

  IF KEYWORD_SET(center) THEN BEGIN																							; If the center keyword is set
    dims = info[1:info[0]] / 2																									; Get size of dimension and divide by 2
    id   = WHERE( even, cnt )																										; Get indicies of even dimension
    IF (cnt GT 0) THEN dims[id] -= 1																						; Subtract 1 from all even dimensions
    FOR i = 0, info[0]-1 DO $																										; Iterate over all dimension
			frequency[i] = SHIFT(frequency[i], dims[i])																; Shift frequencies based on dims
  ENDIF
  IF KEYWORD_SET(dimension) THEN frequency = frequency[dimension-1]							; If dimension keywords set, then set frequency to just that dimension
  IF N_ELEMENTS(frequency) EQ 1 THEN frequency = frequency[0]
ENDIF

RETURN, FFT(array, direction, $
	DIMENSION = dimension, $
	CENTER    = center, $
	DOUBLE    = double, $
	_EXTRA    = _extra)

END
