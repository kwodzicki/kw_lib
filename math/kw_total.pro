FUNCTION KW_TOTAL, array, dim, _EXTRA = EXTRA
;+
; Name:
;   KW_TOTAL
; Purpose:
;   An IDL function that is a wrapper for the built in IDL TOTAL() function.
;   The difference is that if the NAN keyword is set, then if all values
;   are NaN, a NaN will be returned whereas the standard IDL TOTAL() returns
;   zero
; Inputs:
;   Same as TOTAL()
; Outputs:
;   Same as TOTAL()
; Keywords:
;   Same as TOTAL()
; Author and History:
;   Kyle R. Wodzicki     Created 22 Mar. 2019
;-
COMPILE_OPT IDL2

IF N_TAGS(extra) EQ 0 THEN $                                                    ; If NO keywords input
  nan = 0B $                                                                    ; Set nan to zero
ELSE BEGIN                                                                      ; Else, keywords input
  id  = WHERE( STRMATCH( TAG_NAMES(extra), 'NAN', /FOLD_CASE ), CNT )           ; See if NAN keyword used
  nan = (CNT EQ 1) ? extra.(id) : 0B                                            ; Get value of NAN keyword
ENDELSE

IF KEYWORD_SET(nan) THEN BEGIN                                                  ; If NaN Keyword set
  info = SIZE( array )                                                          ; Get information about input array
  IF N_ELEMENTS(dim) EQ 0 THEN $                                                ; If dim is NOT input
    IF TOTAL( FINITE(array, /NaN), /INTEGER ) EQ info [-1] THEN $               ; If a sum of nan boolean is the same as number of elements, that means all elements are NaN
      RETURN, !Values.F_NaN $                                                   ; So return NaN
    ELSE $                                                                      ; Else
      RETURN, TOTAL(array, _EXTRA = extra) $                                    ; Return normal TOTAL
  ELSE BEGIN                                                                    ; Else, dim WAS set
    id  = WHERE( TOTAL(FINITE(array, /NaN), dim, /INTEGER) EQ info[dim], CNT)   ; Total nan boolean over requested dimension and locate any points where the sum matches the length of the dimension; i.e., all NaNs
    tmp = TOTAL( array, dim, _EXTRA = extra )                                   ; Compute TOTAL()
    IF CNT GT 0 THEN tmp[id] = !Values.F_NaN                                    ; If there were any all NaN points, replace with NaN
    RETURN, tmp                                                                 ; Return sum
  ENDELSE
ENDIF

IF N_ELEMENTS(dim) EQ 0 THEN $                                                  ; If dimension input
  RETURN, TOTAL(array, _EXTRA = extra ) $                                       ; Return TOTAL
ELSE $                                                                          ; Else
  RETURN, TOTAL(array, dim, _EXTRA = extra )                                    ; Return TOTAL

END