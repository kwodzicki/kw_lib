FUNCTION GET_LEVELS, dc, data, MIN = min, MAX = max, EVEN = even
;+
; Name:
;   GET_LEVELS
; Purpose:
;   An IDL function to create contour levels based on min/max of data
;   and contour spacing.
; Calling Sequence:
;   levels = GET_LEVELS( dc [, data] MIN = scalar, MAX = scalar, EVEN = scalar)
; Inputs:
;   dc     : Interval for contours (Required)
;   data   : Data array. Min and max are compute from array.
;              Optional; MIN and MAX keys MUST be set if no data input
; Outputs:
;   Returns an array containing contour levels
; Keywords:
;   MIN  : Minium value to be used for contour levels. If used in conjunction
;           with MAX, no data needs to be input.
;   MAX  : Maximum value to be used for contour levels. If used in conjunction
;           with MIN, no data needs to be input.
;   EVEN : Set to force contours to be even centered on zero (0).
;            Default is to be even; set EVEN = 0 to turn off this behavior
; Author and History:
;   Kyle R. Wodzicki     Created 2018 11 02
;-
COMPILE_OPT IDL2

IF N_PARAMS() EQ 0 THEN $
  MESSAGE, 'Incorrect number of inputs!' $
ELSE IF N_PARAMS() EQ 1 THEN $
  IF N_ELEMENTS(min) EQ 0 OR N_ELEMENTS(max) EQ 0 THEN $
    MESSAGE, 'Must input data array if min AND max keys NOT set!'

IF N_ELEMENTS( even ) EQ 0 THEN even = 1b
IF N_ELEMENTS( min )  EQ 0 THEN min  = MIN(data, /NaN)
IF N_ELEMENTS( max )  EQ 0 THEN max  = MAX(data, /NaN)

IF KEYWORD_SET(even) THEN $
  IF ABS(min) GE ABS(max) THEN BEGIN
    max = ABS(min)
    min = -max
  ENDIF ELSE BEGIN
    max = ABS(max)
    min = -max
  ENDELSE

dcc  = FLOAT(dc)
cMin = FLOOR( min / dcc ) * dcc
cMax = CEIL(  max / dcc ) * dcc
nc   = (cMax - cMin) / dcc
IF KEYWORD_SET(even) THEN nc += 1
STOP
RETURN, FINDGEN(nc) * dcc + cMin

END
