PRO KW_TEXT, x, y, text, $
  DATA       = data,       $
  NORMAL     = normal,     $
  BACKGROUND = background, $
  ALIGNMENT  = alignment,  $
  CHARSIZE   = charsize,   $
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

IF N_ELEMENTS(background) EQ 0 THEN background = !P.BACKGROUND                ; Set default background color
IF N_ELEMENTS(alignment)  EQ 0 THEN alignment  = 0.0                          ; Set default alignment
IF N_ELEMENTS(charsize)   EQ 0 THEN charsize   = 1.0
  
xy = KEYWORD_SET(data) ? CONVERT_COORD(x, y, /DATA, /TO_NORMAL) : [x, y]      ; If x/y are in data coordinates, convert to normal, else assume normal

y_ch  = !D.y_CH_SIZE / FLOAT(!D.Y_VSIZE)                                      ; Compute height of text
;xy[1] = xy[1] - y_ch / 10.0                                                   ; Offset bottom of 
XYOUTS, xy[0], xy[1], text, /NORMAL, $                                        ; Run XYOUTS to get the x-width of the text
  CHARSIZE  = charsize, $
  ALIGNMENT = alignment, $
  WIDTH     = lx, $
  _EXTRA    = extra
  
ox    = -alignment * lx                                                       ; Set x offset based on alignment
nx    = lx + ox                                                               ; Set x width based on alignment

;xx = [xy[0], xy[0] + nx, xy[0] + nx,   xy[0]]
xx = [xy[0], xy[0], xy[0], xy[0]] + [ ox,  nx,   nx,   ox]                    ; Build x-values for background box
yy = [xy[1], xy[1], xy[1], xy[1]] + [0.0, 0.0, y_ch, y_ch]                    ; Build y-values for background box

POLYFILL, xx, yy, COLOR = background, /NORMAL                                 ; Draw background box
XYOUTS, xy[0], xy[1], text, /NORMAL, $                                        ; Write text 
  CHARSIZE  = charsize,  $
  ALIGNMENT = alignment, $
  _EXTRA    = extra

END
