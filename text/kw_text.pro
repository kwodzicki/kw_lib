PRO KW_TEXT, x, y, text, $
  DATA       = data, $
  NORMAL     = normal, $
  BACKGROUND = background, $
  ALIGNMENT  = alignment, $
  _EXTRA     = extra
;+
; Name:
;   KW_TEXT
; Purpose:
;   An IDL procedure for adding text annotations to a plot
; Inputs:
;   x    : X-location of the text, can be in normal or data coordinates based
;            on keywords.
;   y    : Y-location of the text, can be in normal or data coordinates based
;            on keywords.
;   text : String of text to write
; Outputs:
;   None.  Adds text to a plot
; Keywords:
;   DATA       : Set to say that x and y inputs are in data coordinates
;   NORMAL     : Set to say that x and y inputs are in normal coordinates
;   BACKGROUND : Set to background color to use. Default is the value in
;                  !P.BACKGROUND
;   ALIGNMENT  : Set text alignment
;   Accepts all keywords accepted by XYOUTS
; Author and History:
;   Kyle R. Wodzicki     Created 15 Nov. 2018
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(background) EQ 0 THEN background = !P.BACKGROUND

IF KEYWORD_SET(data) THEN $
  xy = CONVERT_COORD(x, y, /DATA, /TO_NORMAL) $
ELSE $
  xy = [x, y]

x_ch  = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)
y_ch  = !D.y_CH_SIZE / FLOAT(!D.Y_VSIZE)
xy[1] = xy[1] - y_ch / 10.0
nx    = STRLEN(text) * x_ch

xx = [xy[0], xy[0] + nx, xy[0] + nx,   xy[0]]
yy = [xy[1], xy[1],      xy[1] + y_ch,  xy[1] + y_ch]

POLYFILL, xx, yy, COLOR = background, /NORMAL
XYOUTS, xy[0], xy[1], text, ALIGNMENT  = alignment, /NORMAL, _EXTRA = extra

END