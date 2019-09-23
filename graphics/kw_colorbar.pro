PRO KW_COLORBAR, nColors, bottom, $
      POSITION = pos, $
      TITLE    = title, $
      RANGE    = range, $
      TICKNAMES= ticknames, $
      VERTICAL = vertical, $
      RIGHT    = right,    $
      CHARSIZE = charsize, $
      THICK    = thick
;+
; Name:
;   KW_COLORBAR
; Purpose:
;   To create colorbars to overplot on images
; Inputs:
;   Colors  : The [n, 3] array returned to the RGB_TABLE keyword
;              from a call to LOADCT.
; Outputs:
;   A color bar.
; Keywords:
;   POSITION : 4-element array for location of color bar.
;   TITLE    : Title for the colorbar.
;   RANGE    : Range of values to use for color bar; [min, max].
;   VERTICAL : Make color bar vertical and plotted on right.
;   RIGHT    : Set to place label on right of vertical colorbar
;   THICK    : Set the thickness of the lines on the plot
; Author and History:
;   Kyle R. Wodzicki     Created 27 Oct. 2014
;-
COMPILE_OPT IDL2

IF KEYWORD_SET(right)     THEN vertical = 1                           ;If right is set, then set verical
IF ~KEYWORD_SET(charsize) THEN charsize = 1                           ;Set default character size
IF ~KEYWORD_SET(thick)    THEN thick    = 1                           ;Set default thickness

IF (N_ELEMENTS(pos) EQ 0) THEN BEGIN
  pos = ~KEYWORD_SET(vertical) ? [0.1, 0.1, 0.9,   0.125] $
                               : [0.9, 0.1, 0.925, 0.9]
ENDIF

IF ~KEYWORD_SET(bottom)     THEN bottom = 0                           ;Default value for bottom
IF (N_ELEMENTS(range) EQ 0) THEN range  = [0, nColors]                ;Default range

TVLCT, r, g, b, /GET                                                  ;Get current color table

IF (!D.NAME NE 'PS') THEN BEGIN                                       ;If not a PostScript device
  WINDOW, /FREE, /PIXMAP                                              ;Set up size for the window
  WDELETE, !D.WINDOW                                                  ;Close the window that was just opened
ENDIF

xstart = pos[0]                                                       ;Set x-starting point
ystart = pos[1]                                                       ;Set y-starting point
xsize  = pos[2] - pos[0]                                              ;Set size of bar in x
ysize  = pos[3] - pos[1]                                              ;Set size of bar in y

IF ~KEYWORD_SET(vertical) THEN BEGIN                                  ;For horizontal colorbar
  colors = BINDGEN(nColors) # REPLICATE(1B, 5)                        ;Create byte array of size [ncolors, 5]; 5 is arbitrary.
ENDIF ELSE BEGIN                                                      ;For vertical colorbar
  colors = REPLICATE(1B, 5) # BINDGEN(nColors)
ENDELSE

colors = BYTSCL(colors, TOP=(ncolors-1) < (255-bottom)) + bottom      ;Scale to color range from TVLCT
colors = CONGRID(colors, CEIL(xsize*!D.X_VSIZE), $                    ;Scale colors to correct size for plotting
                         CEIL(ysize*!D.Y_VSIZE))

DEVICE, GET_DECOMPOSED = current                                      ;Get current decomposed state
DEVICE, DECOMPOSED = 0                                                ;Set to 8 bit

IF (!D.NAME NE 'PS') THEN BEGIN                                       ;For non-scalable plots
  TV, colors, xstart, ystart, /NORMAL                                 ;Display the colorbar
ENDIF ELSE BEGIN
  TV, colors, xstart, ystart, XSIZE=xsize, YSIZE=ysize, /NORMAL       ;Display the colorbar
ENDELSE

DEVICE, DECOMPOSED = current                                          ;Set to previous state

IF ~KEYWORD_SET(vertical) THEN BEGIN
  PLOT, range, [0,1], /NoDATA,/ NoERASE, /NORMAL, $                   ;Plot values around box
    Position    = pos,         $
    XTickFormat = '(A1)', XTicks = nColors, XMinor = 0, XStyle = 1, $
    XRange      = range,  XThick = thick,                           $
    YTickFormat = '(A1)', YTicks = 1,       YMinor = 0, YStyle = 1, $
    YThick = thick
    
  AXIS, XAXIS=0, XRANGE=range, XTICKS=nColors, XSTYLE=1, $
        XTITLE=title, XTICKNAME=ticknames, XTICKLEN=1.0,$
        XCHARSIZE=charsize, XThick=thick, /NORMAL
ENDIF ELSE BEGIN
  PLOT, [0,1], range, /NoDATA,/ NoERASE, /NORMAL, $                   ;Plot values around box
    Position    = pos, $
    XTickFormat = '(A1)', XTicks = 1,       XMinor = 0, XStyle = 1, $
    XThick      = thick,                                            $
    YTickFormat = '(A1)', YTicks = nColors, YMinor = 0, YSTYLE = 1, $
    YRange      = range, YThick = thick
    
  AXIS, YAXIS=KEYWORD_SET(right), YRANGE=range, YTICKS=nColors, $
        YSTYLE=1, YTITLE=title, YTICKNAME=ticknames, YTICKLEN=1.0, $
        XCHARSIZE=charsize, YThick=thick, /NORMAL
ENDELSE

END