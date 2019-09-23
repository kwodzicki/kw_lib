FUNCTION PWELCH, x, WINDOW = window, NOVERLAP=noverlap, NFFT = nfft, FS = fs
;+
; Name:
;   WELCH
; Purpose:
;   An IDL function to emulate the MATLAB pwelch function
; Author and History:
;   Kyle R. Wodzicki     Created 12 Apr. 2017
;-
COMPILE_OPT IDL2

nx = N_ELEMENTS(x)
IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = 0
IF N_ELEMENTS(nfft)     EQ 0 THEN nfft = 0
fs = N_ELEMENTS(fs) EQ 0 ? 1.0 : 1.0 / fs

IF N_ELEMENTS(window) EQ 0 THEN BEGIN
	IF nfft EQ 0 THEN BEGIN
		nfft  = nx / 5																															; Set initial FFT width for five bins
		nfft += nfft / 9																														; Make FFT width slightly larger; i.e., make largest possible bin so that there are 8 bins with 50% overlap
		nfft  = 2^ROUND(ALOG2(nfft))																								; Set bin size to power of 2 size
		noverlap = nfft / 2																													; Set overlap to 50%
	ENDIF
	window = KW_WINDOW(nfft, 'HAMMING')
ENDIF
nWindow = nx / (nfft - noverlap + 1)																						; Compute the number of windows

pxx = DBLARR(nfft/2+1)
;FOR i = 0, nx - nfft, nfft/2 DO pxx += ABS(FFT( x[i:i+nfft-1] * window, /DOUBLE ) * nfft)^2
FOR i = 0, nx - nfft, nfft/2 DO pxx += FFT_POWERSPECTRUM( x[i:i+nfft-1] * window )
STOP
pxx = TEMPORARY(pxx) / nWindow

RETURN, pxx
END