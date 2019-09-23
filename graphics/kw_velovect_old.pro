PRO KW_VELOVECT, U_comp, V_comp, x_in, y_in,     $
    SKIP         = skip,         $
    LENGTH       = length,       $
    THICK        = thick,        $
    COLOR_TABLE  = color_table,  $
    BOTTOM       = bottom,       $
    LEVELS       = levels,     $
    CHARSIZE     = charsize,     $
    MAP_ON       = map_on,       $
    LATDEL       = latdel,       $
    LONDEL       = londel,       $
    LABEL_AXES   = label_axes,   $
    TITLE        = title,        $
    COLORBAR     = colorbar,     $
    CBPOS        = cbPos,        $
    CBTITLE      = cbTitle,      $
    CBVERTICAL   = cbVertical,   $
    CBRIGHT      = cbRight,      $
    CBFORMAT     = cbFormat,     $
    POSITION     = position,     $
    NDECIMAL     = nDecimal,     $
    OVERPLOT     = overplot,     $
    MAPLIMIT     = maplimit,     $
    ADVANCE      = advance,      $
    NOERASE      = noErase,      $
    MISSINGVALUE = missingvalue, $
    _EXTRA       = extra
    
;+
; Name:
;   KW_VELOVECT
; Purpose:
;   A procedure to improve functionality of the VELOVECT procedure 
;   by coloring arrows based on their magnitude.
; Inputs:
;   U     : U components of winds.
;   V     : V components of winds.
;   x     : X-values for the winds.
;   y     : Y-values for the winds.
; Outputs:
;   Plot with vectors.
; Keywords:
;   COLOR_TABLE  : Color table for color coding.
;   BOTTOM       : Bottom of the color table.
;   CONTOURS     : Array of values to color code to
;   CHARSIZE     : Character size for plot.
;   VALUES       : Values to color code to, i.e., wind magnitudes.
;   MAP_ON       : Set to plot over a map.
;   LATDEL       : Set interval of latitude labels.
;   LONDEL       : Set interval of longitude labels.
;   BOX_AXES     : Set to box axes in map.
;   COLORBAR     : Set to turn on color bar.
;   cbTITLE      : Set to title to use for color bar.
;   POSITION     : Set to 4 element array of map position.
;   NDECIMAL     : Number of decimals to use in color bar labels.
;                   Default is 2 decimals for floats.
; Dependencies:
;   COLOR_24
;   GLOBAL_MAP
;   cgCOLORBAR
;   cgLAYOUT
; Author and History:
;   Kyle R. Wodzicki     Created 27 Oct. 2014
;
;   Modified 11 Nov. 2016 by Kyle R. Wodzicki
;     Added the _EXTRA keywords input
;-

COMPILE_OPT IDL2

cur_Background = !P.BACKGROUND & cur_color = !P.COLOR                 ;Get current colors
!P.BACKGROUND  = !D.N_COLORS-1 & !P.COLOR  = 0                        ;Set background to white and color to black

IF (N_ELEMENTS(skip) EQ 0) THEN skip = 1

y_ch = !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)
x_ch = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)

U = U_comp[0:*:skip, 0:*:skip, *, *]
V = V_comp[0:*:skip, 0:*:skip, *, *]
x = x_in[0:*:skip]
y = y_in[0:*:skip]

magnitude = SQRT(U^2 + V^2)                                           ;Calculate magnitude of wind

IF KEYWORD_SET(cbRight) THEN cbVertical=1                             ;Set veritcal if right set
IF~KEYWORD_SET(bottom) THEN bottom = 0

IF (N_ELEMENTS(levels) EQ 0) THEN BEGIN                             ;Check levels key set
  levels = INDGEN(RANGE(magnitude,/ROUND)+1)+FIX(MIN(magnitude,/NAN))
ENDIF
interval = N_ELEMENTS(levels)-1

IF ~KEYWORD_SET(position) THEN position = [0.1, 0.1, 0.9, 0.9]        ;Default plot position
	
IF ~KEYWORD_SET(interval) THEN interval = 10                          ;Set default interval
IF ~KEYWORD_SET(title)    THEN title    = 'A Plot'                    ;Default plot name

IF KEYWORD_SET(map_on) THEN BEGIN
  IF ~KEYWORD_SET(mapLimit) THEN $
    mapLimit = [MIN(y), MIN(x), MAX(y), MAX(x)]                       ;Default domain based on lat/lon inputs
  GLOBAL_MAP, MAPLIMIT   = mapLimit,   $
              TITLE      = title,      $
              POSITION   = position,   $
              ADVANCE    = advance,    $
              LABEL_AXES = label_axes, $
              CHARSIZE   = charsize,   $
              _EXTRA     = extra,      $
              /MAPSET
ENDIF

IF (color_table EQ !NULL) THEN color_table = 33

LoadCT, color_table, NColors=interval, BOTTOM=bottom, $               ;Get color values
  RGB_TABLE=colors, /SILENT
LoadCT, color_table, NColors=interval, BOTTOM=bottom, /SILENT         ;Load the table for the colorbar

colors =        ((0 > LONG(colors[*,0])) < 255) + $
         256 * (((0 > LONG(colors[*,1])) < 255) + $
         256 *  ((0 > LONG(colors[*,2])) < 255))

FOR i = 0, interval-1 DO BEGIN
  tmp_u = U & tmp_v = V
  id = WHERE(magnitude LT levels[i] OR magnitude GT levels[i+1],CNT)
  IF CNT NE 0 THEN BEGIN
    tmp_u[id] = !VALUES.F_NaN
    tmp_v[id] = !VALUES.F_NaN
  ENDIF

  IF KEYWORD_SET(map_on) THEN overplot = 1
  
  VELOVECT, tmp_u, tmp_v, x, y, $
    COLOR    = colors[i], $
    LENGTH   = length,    $
    THICK    = thick,     $
    OVERPLOT = overplot,  $
    MISSING  = missingvalue
ENDFOR

				
IF KEYWORD_SET(map_on) THEN BEGIN                                     ;If map is on, overplot lat/lon and continents
  GLOBAL_MAP, MAPLIMIT   = maplimit,   $
              LONDEL     = lonDel,     $
              LATDEL     = latDel,     $
              LATLABEL   = latLabel,   $
              LONLABEL   = lonLabel,   $
              CHARSIZE   = charsize,   $
              LABEL_AXES = label_axes, $
              _EXTRA     = extra,      $
              /OVERPLOT
ENDIF

if SIZE(extra,/TYPE) EQ 8 THEN $
  box_axes = TOTAL(STRMATCH(TAG_NAMES(extra), 'BOX_AXES'), /INT) EQ 1 $
ELSE $
  box_axes = 0
  
IF ~KEYWORD_SET(cbPos) THEN BEGIN                                     ;If a color bar is desired
  IF KEYWORD_SET(cbVertical) THEN BEGIN                               ;If vertical color bar
    off1 = KEYWORD_SET(box_axes) ? 2*x_ch : 0.03                        ;Set x offsets for vertical color bar
    off2 = KEYWORD_SET(box_axes) ? 2.5*x_ch : 0.05
    cbPos = [position[2]+off1, position[1], $
             position[2]+off2, position[3]]
  ENDIF ELSE BEGIN
    off1 = KEYWORD_SET(box_axes) ? 2*y_ch : 0.01                        ;Set y offsets for horizontal colorbar
    off2 = KEYWORD_SET(box_axes) ? 2.5*y_ch : 0.03
    cbPos= [position[0], position[1]-off2, $                          ;Set default position horizontal color bar
            position[2], position[1]-off1]		
  ENDELSE
ENDIF

IF KEYWORD_SET(colorbar) THEN BEGIN
  IF N_ELEMENTS(cbformat) EQ 0 THEN $
    cbLevels = STRTRIM(levels,2) $                 ;Set format for color bar labels floats  
  ELSE $
   cbLevels = STRING(levels,FORMAT=cbformat)                ;Convert to string and trim up
  
;  cgCOLORBAR, interval, bottom, $
;              Position  = cbPos,      $
;              TITLE     = cbTitle,    $
;              VERTICAL  = cbVertical, $
;              RIGHT     = cbRight,    $
;              CHARSIZE  = charsize

  cgColorbar,   TICKNAMES = cblevels,                 $
                DISCRETE  = discrete,                 $
                NColors   = interval,                 $
                Bottom    = bottom,                   $
                DIVISIONS = N_ELEMENTS(levels)-1,  $
                Position  = cbPos,                    $
                TITLE     = cbTitle,                  $
                VERTICAL  = cbVertical,               $
                RIGHT     = cbRight,                  $
                CHARSIZE  = charsize
;  kw_COLORBAR, interval, bottom, $
;      POSITION = cbPos, $
;      TITLE    = cbTitle, $
;      TICKNAMES= levels, $
;      VERTICAL = cbVertical, $
;      RIGHT    = cbRight,    $
;      CHARSIZE = charsize, $
;      THICK    = thick

ENDIF

!P.BACKGROUND = cur_Background & !P.COLOR = cur_color                 ;Reset colors

END