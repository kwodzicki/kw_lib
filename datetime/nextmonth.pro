FUNCTION NEXTMONTH, date
;+
; Name:
;   NEXT_MONTH
; Purpose:
;   Function to get julday of first day of next month
; Inputs:
;   date   : Julday IDL date
; Keywords:
;   None.
; Returns:
;   Julday of first of next month
; Example:
;     IDL> d0 = GREG2JUL(15, 1, 2000, 5)
;     IDL> d1 = NEXT_MONTH(d0)
;
;   In this case, d1 will be equal to GREG2JUL(1, 2, 2000, 0, 0, 0)
;-

COMPILE_OPT IDL2

JUL2GREG, date, mm, dd, yy
  
mm += 1
IF mm EQ 13 THEN BEGIN
  yy += 1
  mm  = 1
ENDIF

RETURN, GREG2JUL(mm, 1, yy, 0, 0, 0)

END
