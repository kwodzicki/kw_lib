FUNCTION KW_PSD, time, xx, yy, WINDOW=window, _EXTRA = _extra
;+
; Name:
;   KW_PSD
; Purpose:
;   A function to compute power spectral density or cross power
;   spectral density
; Inputs:
;   time   : Array of time values associated with data
;   xx     : Data for first time series
;   yy     : Data fro second time series; optional, if present then
;             cross power spectral density computed
; Keywords:
;   All keywords accepted by FFT() function
; Returns:
;   Power spectral density or cross power spectral density
;-
COMPILE_OPT IDL2

IF N_PARAMS() LT 2 THEN MESSAGE, 'Incorrect number of inputs!'								; Check number of inputs

extra = DICTIONARY(_extra)																										; Convert extra keywords structure to dictionary
IF extra.HasKey('DIMENSION') THEN dimension = extra.DIMENSION $								; If dimension in dictionary, use that dimension value
                             ELSE dimension = 1																; Else, use one (1)

info  = SIZE(xx)																															; Get information about xx
IF N_ELEMENTS(window) GT 0 THEN BEGIN																				; If hanning keyword is set
  dims = info[1:info[0]]																											; Get dimensions from info array
  IF dimension EQ 1 THEN $																										; If dimension is 1
    flt = REBIN(window, dims) $																								; Just rebin
  ELSE BEGIN																																	; Else
    sid              = INDGEN(info[0])																				; Create index array
    sid[0]           = dimension-1																						; Set first dimension to dimension index
    sid[dimension-1] = 0																											; Set dimension index to zero
    flt = REBIN(window, dims[sid])																						; Rebin filter 
    flt = TRANSPOSE(flt, SORT(sid))																						; Transpose filter back to correct shape
  ENDELSE
ENDIF ELSE $
  flt = MAKE_ARRAY(info[1:info[0]], VALUE = 1.0D0)

dt    = time[1]-time[0]																												; Get sampling resolution
fac   = 2.0 * dt * dt / MAX(time)																							; Multiplcation factor: 2.0 * dt^2 / T
fXX   = FFT(xx*flt, _EXTRA=_extra) * info[dimension]													; Compute transform on xx and denormalize; i.e., multiply by number of samples

IF N_ELEMENTS(yy) GT 0 THEN $																									; If yy is set
  RETURN, fac * fXX * CONJ( FFT(yy*flt, _EXTRA=_extra) * info[dimension] )		; Compute cross power spectal density and return

RETURN, fac* fXX * CONJ(fXX)																									; Computer power spectral density

END
