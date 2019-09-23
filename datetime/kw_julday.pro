FUNCTION KW_JULDAY, yy, mm, dd, hr, min, sec
;+
; Name:
;   KW_JULDAY
; Purpose:
;   A function to change the order of inputs into the JULDAY function
; Inputs:
;   yy  : Year of date.
;   mm  : Month of date.
;   dd  : Day of date.
;   hr  : Hour of date.
;   min : Minute of date.
;   sec : Second of date.
; Outputs:
;  Returns julian date same as JULDAY function
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 20 Sep. 2016
;-
  COMPILE_OPT IDL2
  CASE N_PARAMS() OF
  	0 : RETURN, SYSTIME(/JULIAN)
  	3 : RETURN, JULDAY(mm, dd, yy)
  	4 : RETURN, JULDAY(mm, dd, yy, hr)
  	5 : RETURN, JULDAY(mm, dd, yy, hr, min)
  	6 : RETURN, JULDAY(mm, dd, yy, hr, min, sec)
  	ELSE : MESSAGE, 'Incorrect number of inputs!'
  ENDCASE
END