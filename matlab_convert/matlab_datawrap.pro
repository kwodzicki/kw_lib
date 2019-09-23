FUNCTION MATLAB_DATAWRAP, xin, nfft
;+
; Name:
;   MATLAB_DATAWRAP
; Purpose:
;   An IDL function to emulate the MATLAB datawrap function.
; Inputs:
;   x :
;   nfft
; Outputs:
;   x
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 26 Apr. 2017
;-
COMPILE_OPT IDL2

x_info = SIZE(xin)
IF TOTAL(x_info[1:x_info[0]] GT 1, /INT) GT 1 THEN MESSAGE, 'Invalid Input!'
x = MAKE_ARRAY(nfft, CEIL(x_info[-1]/FLOAT(nfft)), TYPE = x_info[-2])
x[0] = xin

RETURN, REFORM(TOTAL(x, 2, /PRESERVE_TYPE))

END