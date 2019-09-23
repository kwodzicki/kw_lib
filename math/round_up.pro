FUNCTION ROUND_UP, x
;+
; Name:
;   ROUND_UP
; Purpose:
;   A function to round up to a whole number no matter the input.
; Calling Sequence:
;   result = ROUND_UP(1.4)
; Inputs:
;   x : The number to round up.
; Outputs:
;   Returns a number rounded up to the next whole number.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 27 Oct. 2014
;-
  COMPILE_OPT IDL2                                ;Set compile options
  RETURN, FIX( FIX(x)+1, TYPE = SIZE(x, /TYPE) )  ;Return as same type input
END