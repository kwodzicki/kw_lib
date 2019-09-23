PRO PLOT_2D_HIST, z, x, y, LEVELS = levels, COLOR_TABLE = color_table
;+
; Name:
;   PLOT_2D_HIST
; Purpose:
;   A procedure to plot a 2D histogram, or any other contoured data
;   using pixel 'blocks' instead of the built-in contouring procedure.
; Inputs:
;   z : Values to contour.
;   x : X-axis values.
;   y : Y-axis values.
; Outputs:
;   None.
; Keywords:
;   None.
; Author and History:
;   Adapted from Anthony Viramontez   08 Feb. 2016
;-
COMPILE_OPT IDL2

xlower_bound = MIN(x, MAX=xupper_bound)
ylower_bound = MIN(y, MAX=yupper_bound)
binwidth     = x[1] - x[0]
binheight    = y[1] - y[0]
xrange       = [xlower_bound, xupper_bound]
yrange       = [ylower_bound, yupper_bound]

zMin = MIN(z, MAX=zMax, /NaN)
IF (N_ELEMENTS(color_table) EQ 0) THEN color_table = 33
IF (N_ELEMENTS(levels) EQ 0) THEN BEGIN
  zInt = (CEIL(zMax) - FLOOR(zMin))/10.0
  levels  = FINDGEN(11)*zInt + zMin
  nColors = 10 
ENDIF ELSE nColors = N_ELEMENTS(levels)-1

dims     = SIZE(z, /DIMENSIONS)
offset_g = PRODUCT(dims)
offset_b = offset_g * 2

hist  = KW_HISTOGRAM(z, BIN=levels, REVERSE_INDICES=ri)
OOB_LOW  = (hist[0]  GT 0) ? 0 : 1
OOB_HIGH = (hist[-1] GT 0) ? 1 : 0
nColors  = nColors + (~oob_low) + oob_high

LOADCT, color_table, NCOLORS=nColors, $
  BOTTOM=0, /SILENT
TVLCT, r, g, b, /GET
r = r[0:nColors-1] & g = g[0:nColors-1] & b = b[0:nColors-1]

;=== Generate the image file
image = BYTARR([dims,3])
FOR i = 0, N_ELEMENTS(hist)-2+oob_high DO BEGIN
  IF (hist[i] GT 0) THEN BEGIN
    id = ri[ri[i]:ri[i+1]-1]
    image[id]          = r[i-oob_low]
    image[id+offset_g] = g[i-oob_low]
    image[id+offset_b] = b[i-oob_low]
  ENDIF
ENDFOR

palette = [ [r], [g], [b] ]
cgImage, image, XRange=xrange, YRange=yrange, /Axes, Palette=palette, $
  XTitle= xvariable, YTitle= yvariable, TITLE=plot_title , $
  Position=[0.125, 0.125, 0.9, 0.8]
  
IF ~KEYWORD_SET(oob_low)  THEN palette = palette[1:*,*]
IF  KEYWORD_SET(oob_high) THEN palette = palette[0:-2,*]

; Display a color bar.
cgColorbar, Position=[0.125, 0.875, 0.9, 0.925], $
  Range     = [MIN(levels), MAX(levels)], $
  PALETTE   = palette, $
  TLocation ='Top', $
  OOB_LOW   = ~KEYWORD_SET(oob_low)  ? [ r[0],  g[0],  b[0] ]  : !NULL, $
  OOB_HIGH  =  KEYWORD_SET(oob_high) ? [ r[-1], g[-1], b[-1] ] : !NULL, $
  xTickV    = levels, $
  xTicks    = nColors - (~oob_low) - oob_high

;Stop postscript output
;ps_off
END