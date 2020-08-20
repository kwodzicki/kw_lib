FUNCTION CURRENTMONTH, date

;+
; Name:
;   CURRENTMONTH
; Purpose:
;   To return IDL JULDAY for first of month
; Inputs:
;   date  : IDL Julday
; Keywords:
;   None.
; Returns:
;   IDL Julday for first of month.
; Example:
;    IDL> d0 = GREG2JUL(15, 1, 2020, 12)
;    IDL> d1 = CURRENTMONTH( d0 )
;  In this case, d1 will be 2020-01-01 00:00:0.0
;-

COMPILE_OPT IDL2

JUL2GREG, date, mm, dd, yy

RETURN, GREG2JUL(mm, 1, yy, 0, 0, 0)

END
