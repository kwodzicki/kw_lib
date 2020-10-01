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
  frequency = LIST()																														; List to hold frequencies for each dimension
  info      = SIZE(array)																												; Information about input array
  IF N_ELEMENTS(sample_rate) EQ 1 THEN sr = REPLICATE(sample_rate, info[0]) $
                                  ELSE sr = sample_rate
  FOR i = 1, info[0] DO $																												; Iterate over dimension
    frequency.ADD, KW_FFT_FREQ(info[i], sr[i-1], DOUBLE=double, CENTER=center)

  IF KEYWORD_SET(dimension) THEN frequency = frequency[dimension-1]							; If dimension keywords set, then set frequency to just that dimension
  IF N_ELEMENTS(frequency) EQ 1 THEN frequency = frequency[0]
ENDIF

RETURN, FFT(array, direction, $
	DIMENSION = dimension, $
	CENTER    = center, $
	DOUBLE    = double, $
	_EXTRA    = _extra)

END
