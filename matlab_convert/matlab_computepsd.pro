FUNCTION MATLAB_COMPUTEPSD, Sxx, w, range, nfft, esttype, FS = fs
;+
;COMPUTEPSD  Compute the one-sided or two-sided PSD or Mean-Square.
;   [Pxx,W,UNITS] = COMPUTEPSD(Sxx,W,RANGE,NFFT,Fs,ESTTYPE) where the
;   inputs and outputs are:
;
;   Inputs:
;    Sxx   - Whole power spectrum [Power]; it can be a vector or a matrix.
;            For matrices the operation is applied to each column.
;    W     - Frequency vector in rad/sample or in Hz.
;    RANGE - Determines if a 'onesided' or a 'twosided' Pxx and Sxx are
;            returned.
;    NFFT  - Number of frequency points.
;    ESTTYPE - A string indicating the estimate type: 'psd', or 'ms' value.
;
;   Outputs:
;    Pxx   - One-sided or two-sided PSD or MEAN-SQUARE (not scaled by Fs)
;            depending on the input arguments RANGE and TYPE.
;    W     - Frequency vector 0 to 2*Nyquist or 0 to Nyquist depending on
;            range, units will be either rad/sample (if Fs is empty) or Hz
;            (otherwise).
;    UNITS - Either 'rad/sample' or 'Hz' 
;
; Keywords:
;   FS :  Sampling Frequency.
;   Author(s): R. Losada
;   Copyright 1988-2012 The MathWorks, Inc.
;
; Adapted to IDL by Kyle R. Wodzicki 26 Apr. 2017
;-
COMPILE_OPT IDL2
IF (N_PARAMS() LT 5) THEN esttype = 'psd'

 ; Generate the one-sided spectrum [Power] if so wanted
IF STRLOWCASE(range) EQ 'onesided' THEN BEGIN
   IF (nfft MOD 2) NE 0 THEN BEGIN
      select     = LINDGEN( (nfft+1) / 2 )																				; ODD
      Sxx        = Sxx[select, *]																								; Filter
      Sxx[1:*,*] = 2 * Sxx[1:*, *]																								; Only DC is a unique point and doesn't get doubled
   ENDIF ELSE BEGIN
      select      = LINDGEN( nfft/2 + 1 )
      Sxx         = Sxx[select, *]																									; Filter
      Sxx[1:-2,*] = 2 * Sxx[1:-2, *]																								; Don't double unique Nyquist point
   ENDELSE
   w = w[select];
END

IF N_ELEMENTS(Fs) NE 0 THEN $ 																									; If the Fs keyword is set
	IF FINITE(Fs,/NaN) THEN BEGIN																									; If the values is NaN character
		Fs = 2 * !DPI																																; Set Fs to 2 pi
		units = 'rad/sample'																												; Set units
	ENDIF ELSE $
		units = 'Hz'																																; Set units to Hertz

IF TOTAL(STRMATCH(['ms', 'power'], esttype, /FOLD_CASE), /INT) EQ 1 THEN $
	RETURN, {Sxx : Sxx, W : w, UNITS : units} $																		; Mean-square
ELSE $  
	RETURN, {Pxx : Sxx/Fs, W : w, UNITS : units}																	; PSD 
END