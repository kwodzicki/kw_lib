FUNCTION SPECTRA_DOF, n, m, window
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
;   Thomson, R. E., and W. J. Emery, 2014, table 5.5 p. 479
;-
COMPILE_OPT IDL2

IF N_PARAMS() NE 3 THEN MESSAGE, 'Incorrect number of inputs!'

ratio = FLOAT(N) / FLOAT(M)
CASE STRUPCASE(window) OF
	'BARTLETT'	: RETURN, 3.0       * ratio
	'DANIELL'		: RETURN, 2.0       * ratio
	'PARZEN'		: RETURN, 3.708614  * ratio
	'HANNING'		: RETURN, (8.0/3.0) * ratio
	'HAMMING'		: RETURN, 2.5164    * ratio
	ELSE				: MESSAGE, 'Unrecognized window option: ' + window
ENDCASE

END