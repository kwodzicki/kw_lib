FUNCTION DAYOFWEEK, yy, mm, dd
;+
; Name:
;   DAYOFWEEK
; Purpose:
;   Function to determine the day of week where zero (0) is Sunday
;   and six (6) is Saturday
; Inputs:
;   yy : Year of date
;   mm : Month of date
;   dd : Day of date
; Keywords:
;   None.
; Returns:
;   Interger for day of week (0-Sunday, 1-Monday, etc.)
; Notes:
;   Borrowed from https://cs.uwaterloo.ca/~alopez-o/math-faq/node73.html
;-
COMPILE_OPT IDL2, HIDDEN

m = [11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
m = m[mm-1]
c = FLOOR(yy/100.0)
y = yy - c * 100

id = WHERE(mm LT 3, cnt)
IF cnt GT 0 THEN y[id] -= 1

RETURN, (dd + FLOOR(2.6 * m - 0.2) - 2*c + y + FLOOR(y/4) + FLOOR(c/4)) MOD 7

END
