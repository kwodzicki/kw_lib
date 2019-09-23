FUNCTION KW_RANDOM_NUM, seed, range, in_1, _EXTRA = extra
;+
; Name:
;   KW_RANDOM_NUM 
; Purpose:
;   A function to create psuedo-random, non-repeating numbers in a given range.
; Inputs:
;   seed   :
;   range  :
;   in_1   :
; Outputs:
;   Returns psuedo-random, non-repeating numbers
; Keywords:
;   Accepts all keywords that are accepted by RANDOMU.
; Author and History:
;  Kyle R. Wodzicki     Created 25 Aug. 2016
;-
COMPILE_OPT IDL2

r = ROUND(RANDOMU(seed, in_1, _EXTRA=extra) * (range[1]-range[0])) + range[0]
r = r[UNIQ(r, SORT(r))]

i = 0
nR = N_ELEMENTS(r)
WHILE nR LT in_1 DO BEGIN
  r = [r, ROUND(RANDOMU(seed, in_1-nR, _EXTRA=extra) * (range[1]-range[0])) + range[0]]
  r = r[UNIQ(r, SORT(r))]
  nR = N_ELEMENTS(r)
ENDWHILE
PRINT, i

RETURN, r
END 