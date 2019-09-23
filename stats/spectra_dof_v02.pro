FUNCTION SPECTRA_DOF_V02, M, nOverLap, K, window
;+
; Name:
;   SPECTRA_DOF
; Purpose:
;   An IDL function to compute the equivalent degrees of freedom for spectra
;   calculated using different windows.
; Inputs:
;   n      : Number of data points in the time series
;   m      : Half-width of the window
;   window : Name of the window used. Value options are:
;              Bartlett, Daniell, Parzen, Hanning, Hamming.
; Outputs:
;   Returns the equivalent degrees of freedom
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki    Created 01 May 2017
;
; References
;   https://www.osti.gov/scitech/servlets/purl/5688766/
;-
COMPILE_OPT IDL2

IF nOverLap EQ 0 THEN RETURN, K * 2			; If there is no overlap
S   = M - nOverLap								; Compute window shift
NPG = TOTAL(window^2)							; Compute the Noise Power Gain
kk  = INDGEN(K-2)+1
tmp = 1.0D0

FOR i = 1, K-2 DO $
	IF i LT M / S THEN BEGIN
		rho = 0.0D0
		PRINT, i
		FOR j = 0, S-1 DO rho += window[j]*window[j+i*S]
		rho = (rho / NPG)^2
		tmp += (K - i) / FLOAT(K) * rho
	ENDIF
RETURN, 2 * K / tmp

END