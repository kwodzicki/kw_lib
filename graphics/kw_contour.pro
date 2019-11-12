PRO KW_CONTOUR, in1, in2, in3, in4, $
      INTERVAL     = nLevels,      $
      LEVELS       = levels,       $
      N_LEVELS     = n_levels,     $
      LOG          = log,          $
      COLOR_TABLE  = color_table,  $
      RGB_COLORS   = rgb_colors,   $
      COLORBAR     = colorbar,     $
      CT_File      = ct_file,      $
      CTREVERSE    = ctReverse,    $
      CBVERTICAL   = cbVertical,   $
      CBRIGHT      = cbRight,      $
      CBPOS        = cbPos,        $
      CBCHARSIZE   = cbCharsize,   $
      CBTITLE      = cbTitle,      $
      CBRANGE      = cbrange,      $
      CBLEVELS     = cbLevels,     $
      CBLABELS     = cbLabels,     $
      CBFORMAT     = cbFormat,     $
      CBXLOG       = cbXLog,       $
      CBYLOG       = cbYLog,       $
      LABEL_UNDER  = label_under,  $
      BOTTOM       = bottom,       $
      MAP_ON       = map_on,       $
      MAPLIMIT     = maplimit,     $
      LONGITUDE    = longitude,    $
      XWINDOW      = XWINDOW,      $
      MISSINGVALUE = missingvalue, $
      MAP_OBJ      = map_obj,      $
      PROJECTION   = projection,   $
      POSITION     = position,     $
      DISCRETE     = discrete,     $
      RANGE        = range,        $
      MAP_COLOR    = map_color,    $
      GRID_COLOR   = grid_color,   $
      OOB_LOW      = oob_low_col,  $
      OOB_HIGH     = oob_high_col, $
      C_FILL       = c_fill,       $
      _EXTRA       = extra
; Name:
;   KW_CONTOUR
; Purpose:
;   To call the CGContour and CGColor bar plotting routines without
;   having to define everything all the time.
; Calling sequence:
;   PF_CGCONTOUR, z, x, y
; Input:
;   z  : Data to be contoured
;   x  : Values of `x' axis
;   y  : Values of `y' axis
; Outputs:
;   A direct graphics contour plot
; Keywords:
;   Accepts all keywords for the IDL CONTOUR procedure.
;   OVERPLOT     : Use to overplot data
;   INTERVAL     : Contouring nLevels to use; default is ten (10)
;   CONTOURS     : Array containing the values of levels
;   CBRANGE      : Set range for colorbar
;   CBLEVELS     : Colorbar levels; MUST BE STRING
;   COLOR_TABLE  : Set to color table desired; Default is 33
;   RGB_COLORS   : An nx3 array specifying RGB values for contours.
;   BOTTOM       : Bottom index of the color table to use
;   CTREVERSE    : Reverse the color table
;   FILL         : Set to fill in levels
;   CELL_FILL    : Use when overplotting on map
;   COLORBAR     : Set if a color bar is to be added to plot
;   CBPOS        : Color bar position
;   CBTITLE      : Title of the colorbar
;   CBCHARSIZE   : Change the size of text in the colorbar
;   CBVERTICAL   : To make colorbar vertical
;   CBRIGHT      : Place labels on right side of vertical colorbar
;   LABEL_UNDER  : Set to create color bar where labels are centered under colors
;   MAP_ON       : Set to plot data over map; default is yes
;   MAPLIMIT     : Domain of map; default is
;                    [-90.0, -180.0, 90.0, 180.0]
;   XWINDOW      : Set up the window size. If 3-elements:
;                    0) Window index, 1) XSIZE, 2) YSIZE.
;                    If 2-elements, 0) XSIZE, 1) YSIZE
;   XTITLE       : Title of the x-axis
;   YTITLE       : Title of the y-axis
;   XRANGE       : Range of x Axis values
;   YRANGE       : Range of y Axis vaules
;   XTICKUNITS   : Units for x axis
;   YTICKUNITS   : Units for y axis
;   XTHICK       : Thickness of x annotations
;   YTHICK       : Thickness of y annotations
;   XMARGIN      : X-margin for the plots
;   YMARGIN      : Y-margin for the plots
;   POSITION     : Position of the plot
;   MISSINGVALUE : Missing value in data
;   ALL other keywords accepted by dependencies and CONTOUR procedure
; Dependencies:
;   GLOBAL_MAP
;   KW_HISTOGRAM
;   KW_IMAGE
;   COLOR_24_KPB
;   cgLAYOUT
;   cgCOLORBAR
; Author and history:
;   Kyle Wodzicki		Created 11 June 2014
;
;     MODIFIED 24 June 2014:
;       Added OVERPLOT keyword and added NaN keyword to MIN and MAX
;       in color bar section.
;     MODIFIED 25 June 2014:
;       Cleaned up contour and nLevels keyword checks. If levels is
;       set, then the nLevels is set based off the levels.
;       If levels is set, and no nLevels was set, will default.
;       Lastly, if levels not set and nLevels set, will maintain
;       set nLevels.
;       ALSO added CHARSIZE to GLOBAL_MAP call.
;       ALSO added lat/lonLabel to keywords for use in GLOBAL_MAP.
;     MODIFIED 01 July 2014:
;       If MAPLIMIT is not set, the map domain is determine based on
;       the MIN and MAX values of the input Latitude and Longitude.
;       Add cgLayout to determine plot position if not entered via
;       keyword. Added handling of color bar position based on the
;       plot position. Modified default color bar position to handle
;       horizontal and vertical color bars.
;     MODIFIED 08 July 2014:
;       Added XRANGE & YRANGE keywords.
;     MODIFIED 16 July 2014:
;       Changed WIND keyword to include window index.
;     MODIFIED 26 July 2014:
;       Added x and y title keywords
;     MODIFIED 28 July 2014:
;       Changed procedure name from PF_CGCONTOUR to KW_CONTOUR.
;     MODIFIED 30 July 2014:
;       Added, x/y tick units keywords and BOTTOM
;     MODIFIED 16 Sep. 2014:
;       Changed how color bar levels are generated.
;     MODIFIED 24 Oct. 2014:
;       Added ZVALUE keyword.
;     MODIFIED 28 Oct. 2014:
;       Implimented use of KW_COLORBAR in lue of cgCOLORBAR.
;       Call to cgCOLORBAR has simply been commented out.
;       Actually, changed by to CG because of difficulty.
;     MODIFIED 13 Nov. 2014 by K.R.W.
;       Added OOB_HIGH and OOB_LOW keywords to contour points
;       over or under the maximum and minimum levels as the
;       maximum or minimum color.
;     MODIFIED 19 Nov. 2014:
;       Added USA keyword.
;     MODIFIED 03 Mar. 2015
;       Added MAP_OBJ Keyword
;     MODIFIED 04 Mar. 2015 K.R.W
;       Added COUNTRIES keyword
;     Modified 17 Nov. 2016 by Kyle R. Wodzicki:
;			  Updated some of the keyword inputs to be handled by _EXTRA
;     Modified 02 Nov. 2017 by Kyle R. Wodzicki:
;       Added the CBCHARSIZE keyword
;     Modified 01 Feb. 2018 by Kyle R. Wodzicki
;       Added C_FILL keyword to add in support for the CELL_FILL
;       keyword in the CONTOUR procedure
;     Modified 26 Feb. 2019 by Kyle R. Wodzicki
;       Added CBRANGE keyword
;     Modified 01 Mar. 2019 by Kyle R. Wodzicki
;       Added LABEL_UNDER keyword
;-

COMPILE_OPT IDL2

IF N_PARAMS() LT 3 THEN MESSAGE, 'Incorrect number of inputs!!!' $              ; If less than 3 variables input, print error
ELSE IF N_PARAMS() EQ 3 THEN BEGIN                                              ; If three variables input
  z = in1 & x = in2 & y = in3                                                   ; Then set z, x, and y vars
ENDIF ELSE BEGIN                                                                ; If four variables input
  u = in1 & v = in2 & x = in3 & y = in4                                         ; Then set u, v, x, and y vars
  z = SQRT(u^2 + v^2)                                                           ; Calculate magnitude of vectors as z
ENDELSE
IF N_TAGS(extra) GT 0 THEN extra_in = extra
;HELP, extra

zMin       = MIN(z, MAX = zMax, /NaN)                                           ; Get minimum and maximum of the data to plot
z_type     = SIZE(z, /TYPE)                                                     ; Get the type of data to plot
extra_tags = (N_TAGS(extra) NE 0) ? TAG_NAMES(extra) : ''                       ; Get tag names from extra variable input

IF (N_ELEMENTS(missingvalue) EQ 1) THEN BEGIN                                   ; IF there is a missing value set
  miss_id = WHERE(z EQ missingvalue, miss_CNT)                                  ; Locate missing values in the data to plot
  IF (miss_CNT GT 0) THEN BEGIN                                                 ; IF the missing value is find in the data
    IF (z_type LT 4) THEN z = FLOAT(z)                                          ; Convert data to plot to float if it is an integer
    z[miss_id] = !VALUES.F_NaN                                                  ; Replace missing values with NaN
  ENDIF
ENDIF
not_Finite_id = WHERE(FINITE(z) EQ 0, not_Finite_CNT)                           ; Get indices of all data points that are NOT finite in the data to plot

IF (N_ELEMENTS(cbFormat) EQ 0) THEN cbFormat = "(F8.2)"                         ; Set the default string format for the colorbar labels
IF (N_ELEMENTS(bottom)   EQ 0) THEN bottom   = 0                                ; Set default bottom value of colors to load to zero
IF (N_ELEMENTS(cbTitle)  NE 0) THEN cbTitle  ='!3'+cbTitle ELSE cbTitle = '!3'  ; Set default colorbar title
IF (N_ELEMENTS(title)    EQ 0) THEN title    = ' '                              ; Default plot name

;=== Set up X-window number/size baseed on keyword
CASE N_ELEMENTS(xwindow) OF
	0    : ;Do nothing
	1    : WINDOW, xwindow[0]
	2    : WINDOW, XSIZE=xwindow[0], YSIZE=xwindow[1]
	3    : WINDOW, xwindow[0], XSIZE=xwindow[1], YSIZE=xwindow[2]
	ELSE : MESSAGE, 'XWINDOW keyword can have 1-3 elements ONLY!!!', /CONTINUE
ENDCASE

IF (N_ELEMENTS(position) EQ 0) THEN $                                           ; If position not set; DEFAULT
  position = cgLayout([1,1], OYMARGIN=[7,3], OXMARGIN=[7,7])

IF (N_ELEMENTS(levels) EQ 0) THEN BEGIN                                         ; If NO contour levels were input
	IF N_ELEMENTS(n_levels) EQ 0 THEN n_levels = 128
  levels = FINDGEN(n_levels) * ( (zMax+1.0E-3 - zMin) / (n_levels-1.0)) + zMin  ; Generate 256 equally spaced contouring levels
  discrete = 0                                                                  ; Set discrete to zero as 256 level is too many for a discrete colorbar
ENDIF ELSE IF (N_ELEMENTS(levels) LT 40) AND (N_ELEMENTS(discrete) EQ 0) THEN $
	discrete = 1                      																						; ELSE IF contouring levels were input and there are less than 40 in the array, Set discrete to one
IF N_ELEMENTS(cbLevels) EQ 0 THEN cbLevels = levels                             ; Save original contouring levels for the color bar
IF N_ELEMENTS(cbRange) NE 2 THEN cbRange = [MIN(cbLevels), MAX(cbLevels)]

levels_flt = (SIZE(levels, /TYPE) LT 4) ? FLOAT(levels) : levels                ; If the levels input are not of type FLOAT, then convert them; ELSE no conversion necessary

range   = [levels_flt[0], levels_flt[-1]]                                       ; If NO range for contours was input, set range to MIN/MAX of data to plot
lvl_min = MIN(levels_flt, MAX = lvl_max, /NaN)                                  ; Get the minimum and maximum values of the contouring levels

OOB_LOW  = 0
OOB_HIGH = 0
IF (zMin LT lvl_min) THEN BEGIN                                                 ; IF the minimum value of the data is LESS THAN the lowest contouring level
  levels_flt = [FLOAT(zMin)-1.0, levels_flt]                                        ; Prepend the minimum data value rounded down to the contouring levels to ensure that these values are contoured. An out-of-bound triangle will be added to the colorbar
  OOB_LOW  = 1                                                                  ; Set OOB_LOW to zero (0)
  OOB_HIGH = 2
ENDIF
IF (zMax GT lvl_max) THEN BEGIN                                                 ; IF the maximum value of the data is GREATER THAN the highest contouring level
  levels_flt = [levels_flt, FLOAT(zMax)+1.0]                                         ; Append the maximum data value rounded up to the contouring levels to ensure that these values are contoured. An out-of-bound triangle will be added to the colorbar
  OOB_HIGH = 1                                                                  ; Set OOB_HIGH to one (1)
  IF (oob_low EQ 0) THEN oob_low = 2
ENDIF ELSE IF KEYWORD_SET(discrete) THEN levels_flt[-1] = levels_flt[-1]+1.0E-3 ; IF color bar is to be discrete, make upper bound slightly higher than user specified. This is required because of how data is contour and how data is binned in the histogram function

nLevels = N_ELEMENTS(levels_flt)-1 + (oob_low EQ 2) + (oob_high EQ 2)           ; Set the number of levels for contouring. This is the same as the number of colors to load

IF (N_ELEMENTS(rgb_colors) EQ 0) THEN BEGIN                                     ; IF no RGB color table was explicitly entered
	IF (N_ELEMENTS(color_table) EQ 0) THEN color_table = 33                       ; IF not color table is defined by the user, set the default table to 33
	LOADCT, color_table, NCOLORS = nLevels, BOTTOM=bottom, FILE = ct_File, $      ; Load the color table silently
		RGB_TABLE = rgb_colors, /SILENT
	IF (N_ELEMENTS(oob_low_col) NE 0) AND OOB_LOW EQ 1 THEN $                     ; IF the user specified an OOB_LOW color
		IF (N_ELEMENTS(oob_low_col) EQ 3) THEN $                                    ; IF it is an RGB array
			rgb_colors[0,*] = oob_low_col $                                           ; Set first element of RGB arrays to the RGB values of the OOB_LOW color
		ELSE $                                                                      ; ELSE if it is a 24-bit color
			rgb_colors[0,*] = COLOR_24_KPB(oob_low_col, /INVERT)                      ; Parse the color back to RGB
	IF (N_ELEMENTS(oob_high_col) NE 0) AND OOB_HIGH EQ 1 THEN $                   ; IF the user specified an OOB_HIGH color
		IF (N_ELEMENTS(oob_high_col) EQ 3) THEN $                                   ; IF it is an RGB array
			rgb_colors[-1,*] = oob_high_col $                                         ; Set first element of RGB arrays to the RGB values of the OOB_LOW color
		ELSE $                                                                      ; ELSE if it is a 24-bit color
			rgb_colors[-1,*] = COLOR_24_KPB(oob_high_col, /INVERT)                    ; Parse the color back to RGB
ENDIF ELSE BEGIN
  old_rgb = rgb_colors
  IF (SIZE(rgb_colors, /N_DIMENSION) EQ 1) THEN $                               ; Assume the colors are 24-bit, must decompose
    rgb_colors = COLOR_24_KPB(old_rgb, /INVERT)                                 ; Parse 24-bit colors into rgb values

  rgb_dims = SIZE(rgb_colors, /DIMENSION)
	IF (rgb_dims[1] NE 3) THEN BEGIN                                              ; If there are NOT 3 rows
		MESSAGE, 'RGB_Colors array is NOT n x 3 format, TRANSPOSING!!!', /CONTINUE  ; Print a warning message
		rgb_colors = TRANSPOSE(rgb_colors)                                          ; Transpose the RGB_Colors array
		rgb_dims   = REVERSE(rgb_dims)                                              ; Reverse the dimensions
	ENDIF

  IF nLevels NE rgb_dims[0] THEN $
	  rgb_colors = CONGRID(rgb_colors, nLevels, rgb_dims[1])
	IF (OOB_LOW EQ 1) THEN $                                                      ; IF data to plot had values below initial contour levels, a color must be prepended
	  IF (N_ELEMENTS(oob_low_col) NE 0) THEN $                                    ; IF the user specified an OOB_LOW color
		  IF (N_ELEMENTS(oob_low_col) EQ 3) THEN $                                  ; IF it is an RGB array
			  rgb_colors[0,*] = oob_low_col $                                         ; Prepend OOB_LOW color to RGB Arrays
		  ELSE $                                                                    ; ELSE if it is a 24-bit color
			  rgb_colors[0,*] = COLOR_24_KPB(oob_low_col, /INVERT) $                  ; Parse the color back to RGB
		ELSE IF nLevels NE rgb_dims[0] THEN $                                       ; IF the user did NOT specified an OOB_LOW color
		 rgb_colors[0,*] = 0                                                        ; Set to OOB_Low color to BLACK
	IF (OOB_HIGH EQ 1) THEN $                                                     ; IF data to plot had values above initial contour levels, a color must be appended
	 IF (N_ELEMENTS(oob_high_col) NE 0) THEN $                                    ; IF the user specified an OOB_HIGH color
		IF (N_ELEMENTS(oob_high_col) EQ 3) THEN $                                   ; IF it is an RGB array
			rgb_colors[-1,*] = oob_high_col $                                         ; Append OOB_HIGH color to RGB Arrays
		ELSE $                                                                      ; ELSE if it is a 24-bit color
			rgb_colors[-1,*] = COLOR_24_KPB(oob_high_col, /INVERT) $                  ; Parse the color back to RGB
	 ELSE IF nLevels NE rgb_dims[0] THEN $                                        ; IF the user did NOT specified an OOB_LOW color
		 rgb_colors[-1,*] = [127, 0, 127]                                           ; Set to OOB_HIGH color to PURPLE
ENDELSE

IF KEYWORD_SET(ctReverse) THEN rgb_colors = REVERSE(rgb_colors, 1)
c_colors = COLOR_24_KPB(rgb_colors[*,0],rgb_colors[*,1],rgb_colors[*,2])

IF (oob_low  EQ 2) THEN c_colors = c_colors[1:*]
IF (oob_high EQ 2) THEN c_colors = c_colors[0:-2]

overplot = TOTAL(STRMATCH(extra_tags,'OVERPLOT', /FOLD_CASE),/INT) EQ 1
IF KEYWORD_SET(map_on) THEN BEGIN                                               ; IF the MAP_ON keyword is SET
  overplot = 1                                                                  ; Overplot Must be set if plotting on map
  IF (N_ELEMENTS(mapLimit) EQ 0) THEN BEGIN                                     ; IF mapLIMIT NOT set, set to data range
    latMin   = MIN(y, MAX=latMax, /NaN)                                         ; Get minimum and maximum of latitude
    lonMin   = MIN(x, MAX=lonMax, /NaN)                                         ; Get minimum and maximum of longitude
    IF (FINITE(latMin) EQ 0) OR (FINITE(lonMin) EQ 0) THEN $
			mapLimit = [-90, -180, 90, 180] $
		ELSE $
    	mapLimit = [latMin, lonMin, latMax, lonMax]                                 ; Set maplimit to [minLat, minLon, maxLAT, maxLON]
  ENDIF ELSE BEGIN                                                              ; IF mapLIMIT SET
    latMin = mapLimit[0] & latMax = mapLimit[2]                                 ; Get minimum and maximum of latitude
    lonMin = mapLimit[1] & lonMax = mapLimit[3]                                 ; Get minimum and maximum of longitude
  ENDELSE
  GLOBAL_MAP, /MAPSET,   $                                                   ; Set up the map using the GLOBAL_MAP procedure
    LONGITUDE  = longitude, $
    MAPLIMIT   = mapLimit,  $
    POSITION   = position,  $
    PROJECTION = projection, $
    _EXTRA     = extra
ENDIF ELSE BEGIN
  !P.BACKGROUND = !D.N_COLORS-1
  !P.COLOR      = 0
ENDELSE

IF N_PARAMS() EQ 4 THEN BEGIN
	FOR i = 0, nLevels-1 DO BEGIN
		tmp_u = U & tmp_v = V
		id = WHERE(z LT levels_flt[i] OR z GT levels_flt[i+1],CNT)
		IF CNT NE 0 THEN BEGIN
			tmp_u[id] = !VALUES.F_NaN
			tmp_v[id] = !VALUES.F_NaN
		ENDIF
		VELOVECT, tmp_u, tmp_v, x, y, $
			COLOR    = c_colors[i], $
			THICK    = thick,     $
			OVERPLOT = KEYWORD_SET(map_on),  $
			MISSING  = missingvalue;, $
;			_EXTRA   = extra
	ENDFOR
ENDIF ELSE IF TOTAL(extra_tags EQ 'CELL_FILL', /INTEGER) GT 0 THEN BEGIN                   ; IF the CELL_FILL keyword is SET, then build the image pixel by pixel
  hist  = KW_HISTOGRAM(z, BIN=levels_flt, REVERSE_INDICES=ri)                   ; Use KW_HISTOGRAM to bin the data into contour levels and get the reverse indices
  zSize = SIZE(z, /DIMENSIONS)                                                  ; Get the size of the data to contour
  image = LONARR(zSize)                                                         ; Initialize array to store 24-bit color values for each data point in
  FOR i = 1, N_ELEMENTS(hist)-2 DO BEGIN                                        ; Iterate over all histogram bins
    IF (hist[i] GT 0) THEN BEGIN                                                ; IF there are data points in the ith bin, then 'color' those points with the ith color
      id = ri[ri[i]:ri[i+1]-1]                                                  ; Get indices for data points in ith bin
      IF ((i-1) GE c_colors.LENGTH) THEN $
      	image[id] = oob_high $
      ELSE $
				image[id] = c_colors[i-1]
    ENDIF
  ENDFOR
  IF (not_Finite_CNT GT 0) THEN image[not_finite_id] = COLOR_24_KPB('WHITE')    ; IF there are NOT finite data values in the data to contour, make those locations white

  KW_IMAGE, image, x, y, /Axes, /COLOR_24, $
    XRange   = [MIN(x), MAX(x)],    $
    YRange   = [MIN(y), MAX(y)],    $
    NOERASE  = noErase,             $
    POSITION = position,            $
    MAP      = KEYWORD_SET(map_on), $
    _EXTRA   = extra
ENDIF ELSE BEGIN
	CONTOUR, z, x, y, $
		C_COLORS  = c_colors,            $
		LEVELS    = levels_flt,          $
		NLEVELS   = nLevels,             $
		OVERPLOT  = overplot,            $
  	    POSITION  = position,            $
		CELL_FILL = KEYWORD_SET(map_on) OR KEYWORD_SET(c_fill), $
		_EXTRA    = extra
ENDELSE

IF KEYWORD_SET(map_on) THEN $                                                   ; If MAP_ON is SET, overplot lat/lon and continents
  GLOBAL_MAP, /OVERPLOT, $
    MAPLIMIT   = maplimit,   $
    MAP_COLOR  = map_color,  $
    GRID_COLOR = grid_color, $
    _EXTRA     = extra

IF (oob_low GT 0) THEN BEGIN
  IF (oob_low EQ 1) THEN oob_low = REFORM(rgb_colors[0,*]) ELSE oob_low  = !NULL
  rgb_colors = rgb_colors[1:*,*]
ENDIF ELSE oob_low = !NULL
IF (oob_high GT 0) THEN BEGIN
  IF (oob_high EQ 1) THEN oob_high = REFORM(rgb_colors[-1,*]) ELSE oob_high = !NULL
  rgb_colors = rgb_colors[0:-2, *]
ENDIF ELSE oob_high = !NULL

;=== Determine if BOX_AXES or LABEL_AXES is set
axes = TOTAL(STRMATCH(extra_tags,'BOX_AXES')+STRMATCH(extra_tags,'LABEL_AXES'),/INT)
IF (N_ELEMENTS(cbPos) EQ 0) THEN BEGIN                                          ; IF a location for the color bar is NOT specified
  xChar = FLOAT(!D.X_CH_SIZE) / !D.X_VSIZE
  yChar = FLOAT(!D.Y_CH_SIZE) / !D.Y_VSIZE
  IF KEYWORD_SET(cbVertical) THEN BEGIN                                         ;If vertical color bar
    IF KEYWORD_SET(box_axes) THEN $
      off1 = (axes GT 0) ? 2.5*xChar : 0.5*xChar $                              ;Set x offsets for vertical color bar
    ELSE $
      off1 = xChar
    off2 = off1 + xChar*0.75
    cbPos= [position[1], position[2]+off1, $                                    ;Set default position vertical color bar
            position[3], position[2]+off2]
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(box_axes) THEN $
      off1 = (axes GT 0) ? 1.5*yChar : 0.5*yChar $                              ;Set x offsets for vertical color bar
    ELSE $
      off1 = 2*yChar
    off2 = off1 + yChar*0.5
    cbPos= [position[0], position[1]-off2, $                                    ;Set default position horizontal color bar
            position[2], position[1]-off1]
  ENDELSE
ENDIF

;=== Set the labels to write for the colorbar
IF (N_ELEMENTS(cbLabels) EQ 0) THEN $
	IF KEYWORD_SET(discrete) THEN $
		IF (SIZE(cbLevels, /TYPE) GE 4) THEN $
			cbLabels = STRING(cbLevels,FORMAT=cbFormat) $
		ELSE $
			cbLabels = STRTRIM(cbLevels, 2)
ncbLevels = N_ELEMENTS(cbLevels)

tags_remove = ['FILL', 'CELL_FILL', 'BOX_AXES', 'ADVANCE', 'NLEVELS', $
               'TITLE', 'USA', 'LONDEL', 'LATDEL', 'LIMIT', 'X*', 'Y*', $
               'CHARSIZE', 'IRREGULAR', 'COUNTRIES', 'CONTINENTS', 'OVERPLOT']
remove_ids = []
FOR i = 0, N_ELEMENTS(tags_remove)-1 DO BEGIN
	id = WHERE(STRMATCH(extra_tags, tags_remove[i], /FOLD_CASE), CNT)
	IF CNT GT 0 THEN remove_ids = [remove_ids, id]
ENDFOR
tmp = {}
FOR i = 0, N_TAGS(extra)-1 DO $
  IF TOTAL(i EQ remove_ids, /INT) EQ 0 THEN $
    tmp = CREATE_STRUCT(extra_tags[i], extra.(i))
extra = TEMPORARY(tmp)

IF KEYWORD_SET(colorbar) THEN $
  IF KEYWORD_SET(label_under) THEN $
    cgDCBar, c_colors, $
      SPACING   = 0.5, $
      Position  = cbPos,      $
      TITLE     = cbTitle,    $
      VERTICAL  = cbVertical, $
      RIGHT     = cbRight,    $
      CHARSIZE  = cbCharsize, $
      LABELS    = cbLabels $
  ELSE $
    cgColorbar, $
      DISCRETE  = discrete,   $
      RANGE     = cbRange,     $
;      DIVISIONS = KEYWORD_SET(discrete) ? nLevels : 0, $
      DIVISIONS = ( (ncbLevels LT 40) OR KEYWORD_SET(discrete) ) ? ncbLevels-1 : 0, $
      Position  = cbPos,      $
      TITLE     = cbTitle,    $
      VERTICAL  = cbVertical, $
      RIGHT     = cbRight,    $
      PALETTE   = TRANSPOSE(rgb_colors), $
      OOB_LOW   = oob_low,    $
      OOB_HIGH  = oob_high,   $
      CHARSIZE  = cbCharsize, $
      xTickV    = KEYWORD_SET(cbVertical) EQ 0 ? (ncbLevels LT 40 ? cbLevels : !NULL) : !NULL,   $
      yTickV    = KEYWORD_SET(cbVertical) EQ 1 ? (ncbLevels LT 40 ? cbLevels : !NULL) : !NULL,   $
      xTickName = KEYWORD_SET(cbVertical) EQ 0 ? cbLabels : !NULL,   $
      yTickName = KEYWORD_SET(cbVertical) EQ 1 ? cbLabels : !NULL,   $
      xMinor    = 1, $
      yMinor    = 1, $
      xLog      = cbXLog, $
      yLog      = cbYLog, $
      _EXTRA    = extra

;
;;=== Ensure that data arrays input are the same after procedure is run
;IF (N_ELEMENTS(missingvalue) EQ 1) THEN BEGIN                                   ; IF missingvalue is set
;  z = FIX(z, TYPE=z_type)                                                       ; Convert data to plot back to original type
;  IF (miss_CNT GT 0) THEN z[miss_id] = missingvalue                             ; IF the missing values were find in the data, write misssingvalue back to locations
;ENDIF

;=== Set plotting colors back to default
IF NOT KEYWORD_SET(map_on) THEN BEGIN
  !P.BACKGROUND = !D.N_COLORS-1
  !P.COLOR      = 0
ENDIF
IF (N_ELEMENTS(old_extra) NE 0) THEN extra      = old_extra
IF (N_ELEMENTS(old_rgb)   NE 0) THEN rgb_colors = old_rgb                         ; Set RGB_COLORS back to original value(s)
END
