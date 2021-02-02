PRO SUBPLOT_LABEL, position, label, $
  RIGHT   = right, $
  BOTTOM  = bottom,$
  ABOVE   = above, $
   _EXTRA = _extra
;+
; Name:
;   SUBPLOT_LABEL
; Purpose:
;   To plot labels on sub-plots
; Inputs:
;   position  : 4-element array of 
;   label     : Label to plot
; Keywords:
;
;-
COMPILE_OPT IDL2

IF N_PARAMS() NE 2 THEN MESSAGE, 'Incorrect number of inputs!'
IF N_ELEMENTS(position) NE 4 THEN MESSAGE, 'Position must be 4-element array'

extra = DICTIONARY(_extra, /EXTRACT)
IF extra.HasKey('charsize') EQ 0 THEN extra['charsize'] = 1.0

IF KEYWORD_SET(right) THEN BEGIN
  x = position[2]-!X_CH_SIZE * extra['charsize']
  extra['alignment'] = 1.0
ENDIF ELSE BEGIN
  x = position[0]+!X_CH_SIZE * extra['charsize']
  extra['alignment'] = 0.0
ENDELSE

IF KEYWORD_SET(bottom) THEN BEGIN
  y = position[1]+!Y_CH_SIZE * extra['charsize']
ENDIF ELSE BEGIN
  o = !Y_CH_SIZE * extra['charsize']
  y = position[3] + (KEYWORD_SET(above) ? o*0.5 : -o*1.5)
ENDELSE
    
XYOUTS, x, y, label, _EXTRA = extra.ToStruct()

END
