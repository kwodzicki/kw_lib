PRO KW_MAP_DATA, z, x, y,    $
  COUNTOURS   = contours,    $
  MAPLIMIT    = maplimit,    $
  COLOR_TABLE = color_table, $
  COLORBAR    = colorbar,    $
  BOX_AXES    = box_axes,    $
  POSITION    = position,    $
  FORMAT      = format
;+
; Name:
;   KW_MAP_DATA
; Purpose:
;   A procedure to create an RGB image to plot data as pixels over a map.
; Inputs:
;   z  : Data to contour.
;   x  : x data for contouring
;   y  : y data for contouring
; Outputs:
;   None.
; Keywords:
;   CONTOURS    : Set to the levels to contour. 
;   MAPLIMIT    : Limits for map. Default is min and max of x and y.
;                   Default is 10 even levels between min and max of data.
;   COLOR_TABLE : Set to the color table number to use for the plot
;   COLORBAR    : Set to plot a color bar
; Author and History:
;   Created by Kyle R. Wodzicki     24 Nov. 2015
;-

COMPILE_OPT IDL2

IF (N_PARAMS() NE 3) THEN MESSAGE, 'Incorrect number of inputs!!!'              ; Check the number of inputs

IF (!D.WINDOW EQ -1) AND (!D.NAME EQ 'X') THEN WINDOW, 0                        ; IF in X windows and there is NO window, create one

DEVICE, GET_DECOMPOSED = old_decomposed                                         ; Get the decomposed state of the window
DEVICE, DECOMPOSED=1                                                            ; Set the decomposed state to 24-bit

IF (N_ELEMENTS(position) EQ 0) THEN $                                           ;Set the default postion of the map
  position = cgLayout([1,1], OYMARGIN=[7,3], OXMARGIN=[7,7])
  
IF (N_ELEMENTS(maplimit) NE 4) THEN $                                           ;Set the default map size based on x and y
  maplimit = [MIN(y, /NaN), MIN(x, /NaN), MAX(y, /NaN), MAX(x, /NaN)]

IF (N_ELEMENTS(color_table) EQ 0)   THEN color_table = 33                       ; Set the default color table
IF (N_ELEMENTS(format)      EQ 0)   THEN format = "(F5.1)"                      ; Set the default string format for the color bar
IF (N_ELEMENTS(contours)    EQ 0)   THEN BEGIN                                  ; Set the default contour levels
  nLevels     = 10.0
  data_min    = FLOOR(MIN(z, /NaN))
  data_max    = CEIL(MAX(z,  /NaN))
  dc          = (data_max - data_min)/nLevels
  contours    = INDGEN(nLevels+1)*dc + data_min
ENDIF ELSE nLevels = N_ELEMENTS(contours)-1

LOADCT, color_table, nColors = nLevels, /SILENT                                 ; Load the color table
TVLCT, r, g, b, /GET                                                            ; Get the red, green, blue colors

dims = SIZE(z, /DIMENSIONS)                                                     ; Get dimensions of the input data
rr   = BYTARR(dims) & gg = BYTARR(dims) & bb = BYTARR(dims)                     ; Create new red, green, blue image arrays

FOR i = 0, N_ELEMENTS(contours)-2 DO BEGIN                                      ; Create the image array by filtering the data
  id = WHERE(z GE contours[i] AND z LT contours[i+1], CNT)
  IF (CNT GT 0) THEN BEGIN
    rr[id] = r[i] & gg[id] = g[i] & bb[id] = b[i]
  ENDIF
ENDFOR

;=== Set up the map using GLOBAL_MAP
GLOBAL_MAP, LONGITUDE  = longitude,  $
  MAPLIMIT   = mapLimit,   $
  TITLE      = title,      $
  POSITION   = position,   $
  ADVANCE    = advance,    $
  BOX_AXES   = box_axes,   $
  CHARSIZE   = charsize,   $
  PROJECTION = projection, $
  /MAPSET

;=== Map the image
result = MAP_IMAGE(rr, x0, y0, xSize, ySize)

;=== Create the [x,y,3] image array. Expand the image using CONGRID for X window
IF (!D.NAME EQ 'X') THEN $
  image = [ [[CONGRID(rr, xSize, ySize)]], $
            [[CONGRID(gg, xSize, ySize)]], $
            [[CONGRID(bb, xSize, ySize)]] ] $
ELSE $
  image = [ [[rr]], [[gg]], [[bb]] ]

IF (y[0] GT y[-1]) THEN image = REVERSE(image, 2)                               ; If image is top down, reverse to bottom up

;=== Plot the image
IF (!D.NAME EQ 'X') THEN $
  TV, image, x0, y0, TRUE = 3 $
ELSE $
  TV, image, x0, y0, TRUE = 3, XSIZE = xSize, YSIZE = ySize

;=== Overlay the continents and grid lines
GLOBAL_MAP, MAPLIMIT  = maplimit,  $
	LONDEL     = lonDel,     $
	LATDEL     = latDel,     $
	LATLABEL   = latLabel,   $
	LONLABEL   = lonLabel,   $
	CHARSIZE   = charsize,   $
	BOX_AXES   = box_axes,   $
	LABEL_AXES = label_axes, $
	USA        = usa,        $
	COUNTRIES  = countries,  $
	/OVERPLOT

; COLOR BAR Using cgCOLORBAR
IF (N_ELEMENTS(cbPos) EQ 0) THEN BEGIN                                     ;If a color bar is desired
  IF KEYWORD_SET(cbVertical) THEN BEGIN                               ;If vertical color bar
    off1 = KEYWORD_SET(box_axes) ? 0.02 : 0.01                        ;Set x offsets for vertical color bar
    off2 = KEYWORD_SET(box_axes) ? 0.04 : 0.03
    off1 = off1 + (0.02 * (charsize-1))
    off2 = off2 + (0.02 * (charsize-1))
    cbPos= [position[1], position[2]+off1, $                          ;Set default position vertical color bar
            position[3], position[2]+off2]	
  ENDIF ELSE BEGIN
    off1 = KEYWORD_SET(box_axes) ? 0.045  : 0.01                        ;Set y offsets for horizontal colorbar
    off2 = KEYWORD_SET(box_axes) ? 0.06 : 0.03
    off1 = off1 + (0.02 * (charsize-1))
    off2 = off2 + (0.02 * (charsize-1))
    cbPos= [position[0], position[1]-off2, $                          ;Set default position horizontal color bar
            position[2], position[1]-off1]		
  ENDELSE
ENDIF
IF KEYWORD_SET(colorbar) THEN BEGIN
	cgColorbar, TICKNAMES = STRING(contours, FORMAT=format), $
							DISCRETE  = N_ELEMENTS(contours) LT 30,       $
							NColors   = nLevels,       $
							Bottom    = bottom,         $
							DIVISIONS = interval,       $
							Position  = cbPos,          $
							TITLE     = cbTitle,        $
							VERTICAL  = cbVertical,     $
							RIGHT     = cbRight,        $
							CHARSIZE  = charsize,       $
							PALETTE   = rgb_colors
ENDIF

DEVICE, DECOMPOSED=old_decomposed                                               ; Set decomposed to previous state

END