PRO KW_IMAGE, image, x, y, COLOR_24 = color_24, MAP=map, _EXTRA = extra
;+
; Name:
;   KW_IMAGE
; Purpose:
;   A procedure to plot an image in lieu of using the CONTOUR
;   procedure. This procedure will draw axes, or 'overplot' onto a
;   map projection. This procedure assumes that x and y locations are
;   for grid box centers
; Inputs:
;   image  : An nx, ny, 3 byte scale array of RGB values for the
;              image. If the channel dimension is not the last
;              dimension then set the TRUE keyword.
;   x      : Values for the x-axis.
;   y      : Values for the y-axis.
; Outputs:
;   Creates a plot.
; Keywords:
;   MAP      : Set if drawing on a map projection.
;   COLOR_24 : Set if image input contains 24-bit color indices
;   Accepts all keywords for TV, POLYFILL, and PLOT procedures.
; Author and History:
;   Kyle R. Wodzicki     Created 02 Mar. 2016
;
;   Modified 02 Apr. 2018 by Kyle R. Wodzicki
;     Updated plotting method for POLYFILL on maps; now use interpolation to
;     mid-points of longitude and latitude values and extrapolation to points
;     just beyond longitude and latitude bounds. These values are then used
;     as the coordinates for POLYFILL
;-

COMPILE_OPT IDL2

IF (N_TAGS(extra)    GT 0) THEN tags = TAG_NAMES(extra) ELSE tags = ''          ; If there are keywords in the extra tag structure, get the names of the tags
position = TOTAL(tags EQ 'POSITION') GT 0 ? extra.POSITION : [0.1,0.1,0.9,0.9]  ; Set default plot position
true     = TOTAL(tags EQ 'TRUE')     GT 0 ? extra.TRUE     : 3                  ; Set default true color position

clip = [MIN(x), MIN(y), MAX(x), MAX(y)]
IF TOTAL(tags EQ 'XRANGE') GT 0 THEN clip[0:*:2] = extra.XRANGE
IF TOTAL(tags EQ 'YRANGE') GT 0 THEN clip[1:*:2] = extra.YRANGE

IF (!D.NAME EQ 'X') AND KEYWORD_SET(map) EQ 0 THEN BEGIN                        ; Set default background and plotting colors if in X-windows and NOT on map
  !P.BACKGROUND = COLOR_24('white')
  !P.COLOR      = COLOR_24('black')
ENDIF

CASE true OF
  1 : tmp = TRANSPOSE(image, [1,2,0])
  2 : tmp = TRANSPOSE(image, [0,2,1])
  3 : tmp = image
ENDCASE
dims = SIZE(tmp)

;IF KEYWORD_SET(color_24) THEN tmp = COLOR_24(tmp, /INVERT, /ARRAY)
IF NOT KEYWORD_SET(color_24) THEN $
  tmp =      ((0 > LONG(tmp[*,*,0])) < 255) + $                                 ;Convert RGB to 24-bit color
        256*(((0 > LONG(tmp[*,*,1])) < 255) + $
        256* ((0 > LONG(tmp[*,*,2])) < 255))
x_info = SIZE(x)
y_info = SIZE(y)

IF dims[1] GT x_info[1]         THEN dims[1] = x_info[1]
IF dims[2] GT y_info[y_info[0]] THEN dims[2] = y_info[y_info[0]]
IF KEYWORD_SET(map) THEN BEGIN
  IF x_info[0] EQ 1 THEN BEGIN
    x = REBIN(x, x_info[1], y_info[1])
    y = REBIN(REFORM(y, 1, y_info[1]), x_info[1], y_info[1])
  ENDIF

  xInt  = FINDGEN(dims[1]+1)-0.5                                              ; X indices to interpolate to for box edges
  yInt  = FINDGEN(dims[2]+1)-0.5                                              ; Y indices to interpolate to for box edges
  xx360 = x                                                                   ; X values in 0 - 360 range
  xx180 = x                                                                   ; X values in -180 - 180 range
  IF MAX(x, /NaN) GT 180.0 THEN BEGIN                                         ; If max of x is greater than 180
    id = WHERE(x GT 180.0, cnt)                                               ; Then data was in 0 - 360 range so find where over 180
    IF cnt GT 0 THEN xx180[id] -= 360.0                                       ; Fix -180 - 180 range data
  ENDIF ELSE BEGIN                                                            ; Else, in -180 to 180 range data
    id = WHERE(x LT 0.0, cnt)                                                 ; So find where < 0.0
    IF cnt GT 0 THEN xx360[id] += 360.0                                       ; Fix 0 - 360 range data
  ENDELSE
 
  xx180 = INTERPOLATE(xx180, xInt, yInt, /GRID)                               ; Interpolate the -180 - 180 x-values for box edges
  xx360 = INTERPOLATE(xx360, xInt, yInt, /GRID)                               ; Interpolate the 0 - 360 x-values for box edges
  yy    = INTERPOLATE(y,     xInt, yInt, /GRID)                               ; Interpolate y-values for box edges

  FOR j = 0, dims[2]-1 DO $
    FOR i = 0, dims[1]-1 DO BEGIN
      IF (x[i,j] GE -20) AND (x[i,j] LE 20) THEN $                            ; If x-value is somewhat near the prime meridian
        xVals = [ xx180[i,j], xx180[i,j+1], xx180[i+1,j+1], xx180[i+1,j], xx180[i,j] ] $ ; Use -180 - 180 range
      ELSE $                                                                  ; Else
        xVals = [ xx360[i,j], xx360[i,j+1], xx360[i+1,j+1], xx360[i+1,j], xx360[i,j] ] ; use 0 - 360 range 
      yVals  = [ yy[i,j], yy[i,j+1], yy[i+1,j+1], yy[i+1,j], yy[i,j] ]

      IF TOTAL(FINITE(xVals), /INT) EQ 5 AND TOTAL(FINITE(yVals), /INT) EQ 5 THEN $
     	POLYFILL, xVals, yVals, COLOR = tmp[i, j], /DATA, CLIP = clip, NOCLIP = 0

    ENDFOR

ENDIF ELSE BEGIN
  xRange = [MIN(x), MAX(x)]
  yRange = [MIN(y), MAX(y)]
  PLOT, x, y, /NoData, POSITION=position, COLOR=!P.BACKGROUND, _EXTRA=extra, $
   xRange = xRange, $
   xStyle = 1, $
   yRange = yRange, $
   yStyle = 1
  IF dims[1] EQ (x_info[1]-1) THEN dims[1] += 1
  IF dims[2] EQ (y_info[1]-1) THEN dims[2] += 1
  FOR j = 0, dims[2]-2 DO $
    FOR i = 0, dims[1]-2 DO BEGIN
	  	POLYFILL, [x[i], x[i], x[i+1], x[i+1], x[i]], $
	   		[y[j], y[j+1], y[j+1], y[j], y[j]], $
      	  COLOR=tmp[i,j], /DATA, CLIP = clip, NOCLIP = 0
    ENDFOR
  PLOT, x, y, /NoData, /NoErase, POSITION=position, $
    COLOR=!P.COLOR, _EXTRA=extra, $
    xRange = xRange, $
    xStyle = 1, $
    yRange = yRange, $
    yStyle = 1
ENDELSE

END
