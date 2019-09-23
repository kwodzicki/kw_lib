PRO KW_SET_COLOR, DEFAULT=default
;+
; Name:
;   KW_SET_COLOR
; Purpose:
;   A procedure to flip the background and plotting colors for
;   direct graphics.
; Calling Sequence:
;   KW_SET_COLOR
; Inputs:
;   None.
; Outputs:
;   None.
; Keywords:
;   DEFAULT : Set to change to default settings
; Author and History:
;   Kyle R. Wodzicki     Created 28 Oct. 2014
;-

COMPILE_OPT HIDDEN                    ;Set compile options

IF ~KEYWORD_SET(default) THEN BEGIN
  !P.BACKGROUND = !D.N_COLORS-1       ;Set background to white
  !P.COLOR      = 0                   ;Set color to black
ENDIF ELSE BEGIN
  !P.BACKGROUND = 0                   ;Set background to white
  !P.COLOR      = !D.N_COLORS-1       ;Set color to black
ENDELSE

END