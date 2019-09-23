FUNCTION MATLAB_ACCUMARRAY, subs, val, $
	SZ       = sz, $
	FUN      = fun, $
	FILLVAL  = fillval, $
	ISSPARSE = issparse
;+
; Name:
;   MATLAB_ACCUMARRAY
; Purpose:
;   An IDL function to emulate the ACCUMARRAY MATLAB function
; Inputs:
;   subs
;   val
; Outputs:
;   Array out by accumulating elements of vector val using the subscripts subs.
; Keywords:
;   sz
;   fun
;   fillval
;   issparse
; Author and History:
;   Kyle R. Wodzicki     Created 26 Apr. 2017
;-

COMPILE_OPT IDL2

subs_info = SIZE(subs)

IF subs_info[0] EQ 1 THEN BEGIN
	out = MAKE_ARRAY(MAX(subs)+1, TYPE = SIZE(val, /TYPE))
	FOR i = 0, N_ELEMENTS(subs)-1 DO out[subs[i]] += val[subs[i]]
ENDIF ELSE IF subs_info[0] EQ 2 THEN BEGIN
	IF N_ELEMENTS(sz) EQ 0 THEN sz = [MAX(subs)+1, subs_info[2:subs_info[0]]]
	out = MAKE_ARRAY(sz, TYPE = SIZE(val, /TYPE))
	FOR i = 0, subs_info[1]-1 DO out[subs[i,0],subs[i,1]] += val[i]
ENDIF

RETURN, out
END	