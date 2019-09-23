FUNCTION KW_WINDOW, n, window, BETA = beta, DOULBE = DOUBLE
;+
; Name:
;   KW_WINDOW
; Purpose:
;   An IDL function to produce various windows.
; Inputs:
;   n			 : Width of the window
;   window : String specifying the window type. Default is Hanning. Options are:
;							Hamming
;             Hanning
;							Blackman
;							Kaiser
;							Boxcar
;							Bartlett
; Outputs:
;   Values for the window.
; Keywords:
;		beta    : Beta value for Kaiser window. Default is 0.5
;   DOUBLE	: Return values in double precision. Default is to return floats.
; Author and History:
;   Kyle R. Wodzicki     Created 31 Mar. 2017
;-

COMPILE_OPT IDL2
window = N_ELEMENTS(window) EQ 0 ? 'HANNING' : STRUPCASE(window)

CASE window OF
	'HAMMING'		:	w = 0.54D0 - 0.46D0*COS(2.0D0 * !DPI * DINDGEN(n)/(n-1) )
	'HANNING'		:	w = 0.5D0 * (1.0D0 - COS(2.0D0 * !DPI * DINDGEN(n)/(n-1) ))
	'BLACKMAN'	:	BEGIN
									M  = n MOD 2 EQ 0 ? n/2 : (n+1)/2
									nn = DINDGEN(M)
									w  = 4.2D-1 - 5.0D-1 * COS(2.0D0 * !DPI * nn / (n-1) ) + $
																8.0D-2 * COS(4.0D0 * !DPI * nn / (n-1) )
									w = [w, REVERSE(w)]
								END
	'KAISER'		: BEGIN
									beta = N_ELEMENTS(beta) EQ 0 ? 5.0D-1 : DOUBLE(beta)
									nn = DINDGEN(n)
									w  = BESELI(beta * SQRT(1.0D0 - ( 2.0D0/(n-1) * nn - 1 )^2), 0) / $
											 BESELI(beta, 0)
								END
	'BOXCAR'		: w = MAKE_ARRAY(n, VALUE=1.0D0)
	'BARTLETT'	:	BEGIN
									nn = DINDGEN(n)
									ID = WHERE(nn LE (n-1)/2.0, COMPLEMENT=cID)
									w  = [2*nn[id]/(n-1), 2 - 2*nn[cid]/(n-1)]
								END
	ELSE				: MESSAGE, 'Unknown window requested: ' + window
ENDCASE

IF KEYWORD_SET(double) THEN	RETURN, w ELSE RETURN, FLOAT(w)											; Return the data

END