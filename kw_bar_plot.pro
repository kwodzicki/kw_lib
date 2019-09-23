PRO KW_BAR_PLOT, values, $
  NBARS     = nbars, $
  INDEX     = index, $
  NAMES     = names, $
  COLOR     = color, $
  yMAX      = ymax,  $
  OVERPLOT  = overplot, $
  _EXTRA    = extra
;+
; Name:
;   KW_BAR_PLOT
; Purpose:
;   A wrapper for the IDL BAR_PLOT procedure.
; Inputs:
;   Values : An array of values to plot bars for
; Outputs:
;   A Bar plot
; Keywords:
;   NBARS   : Total number of side-by-side bars to plot
;   INDEX   : Index of the side-by-side bars to plot
;   NAMES   : Names of the bars.
; Author and History:
;   Kyle R. Wodzicki     Created 23 Oct. 2017
;-
COMPILE_OPT IDL2

n = N_ELEMENTS(values)
x = INDGEN(n+2)

yMax     = N_ELEMENTS(ymax) EQ 1 ? ymax : MAX(values);
nbars    = N_ELEMENTS(nbars) EQ 1 ? nbars : 1
index    = N_ELEMENTS(index) EQ 1 ? index : 0
names    = N_ELEMENTS(names) EQ n ? [' ', names, ' '] : !NULL

barWidth = 0.4 / nbars
loc = -(nbars-1) + INDGEN(nbars)*2
newIndex = loc[index]


IF NOT KEYWORD_SET(overplot) THEN $
	PLOT, [0,1], /NoData, $
		yRange    = [0, yMax], $
		yStyle    = 1, $
		xRange    = [MIN(x), MAX(x)], $
		xStyle    = 1, $
		xTickV    = x, $
		xTicks    = n+1, $
		xTickName = names

FOR i = 0, n-1 DO BEGIN
  barx  = x[i+1] + [-barWidth, -barWidth, barWidth, barWidth]
  barx += newIndex * barWidth
  POLYFILL, barx, [0, values[i], values[i], 0], COLOR = color, $
    _EXTRA = extra
ENDFOR
  



END