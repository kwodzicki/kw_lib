;PRO KW_VELOVECT, U_comp, V_comp, x_in, y_in,     $
;    SKIP         = skip,         $
;    LENGTH       = length,       $
;    THICK        = thick,        $
;    COLOR_TABLE  = color_table,  $
;    BOTTOM       = bottom,       $
;    LEVELS       = levels,     $
;    CHARSIZE     = charsize,     $
;    MAP_ON       = map_on,       $
;    LATDEL       = latdel,       $
;    LONDEL       = londel,       $
;    LABEL_AXES   = label_axes,   $
;    TITLE        = title,        $
;    COLORBAR     = colorbar,     $
;    CBPOS        = cbPos,        $
;    CBTITLE      = cbTitle,      $
;    CBVERTICAL   = cbVertical,   $
;    CBRIGHT      = cbRight,      $
;    CBFORMAT     = cbFormat,     $
;    POSITION     = position,     $
;    NDECIMAL     = nDecimal,     $
;    OVERPLOT     = overplot,     $
;    MAPLIMIT     = maplimit,     $
;    ADVANCE      = advance,      $
;    NOERASE      = noErase,      $
;    MISSINGVALUE = missingvalue, $
;    _EXTRA       = extra
;
;;+
;; Name:
;;   KW_VELOVECT
;; Purpose:
;;   A procedure to improve functionality of the VELOVECT procedure
;;   by coloring arrows based on their magnitude.
;; Inputs:
;;   U     : U components of winds.
;;   V     : V components of winds.
;;   x     : X-values for the winds.
;;   y     : Y-values for the winds.
;; Outputs:
;;   Plot with vectors.
;; Keywords:
;;   COLOR_TABLE  : Color table for color coding.
;;   BOTTOM       : Bottom of the color table.
;;   CONTOURS     : Array of values to color code to
;;   CHARSIZE     : Character size for plot.
;;   VALUES       : Values to color code to, i.e., wind magnitudes.
;;   MAP_ON       : Set to plot over a map.
;;   LATDEL       : Set interval of latitude labels.
;;   LONDEL       : Set interval of longitude labels.
;;   BOX_AXES     : Set to box axes in map.
;;   COLORBAR     : Set to turn on color bar.
;;   cbTITLE      : Set to title to use for color bar.
;;   POSITION     : Set to 4 element array of map position.
;;   NDECIMAL     : Number of decimals to use in color bar labels.
;;                   Default is 2 decimals for floats.
;; Dependencies:
;;   COLOR_24
;;   GLOBAL_MAP
;;   cgCOLORBAR
;;   cgLAYOUT
;; Author and History:
;;   Kyle R. Wodzicki     Created 27 Oct. 2014
;;
;;   Modified 11 Nov. 2016 by Kyle R. Wodzicki
;;     Added the _EXTRA keywords input
;;-
;
;COMPILE_OPT IDL2
;
;cur_Background = !P.BACKGROUND & cur_color = !P.COLOR                 ;Get current colors
;!P.BACKGROUND  = !D.N_COLORS-1 & !P.COLOR  = 0                        ;Set background to white and color to black
;
;IF (N_ELEMENTS(skip) EQ 0) THEN skip = 1
;
;y_ch = !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)
;x_ch = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)
;
;U = U_comp[0:*:skip, 0:*:skip, *, *]
;V = V_comp[0:*:skip, 0:*:skip, *, *]
;x = x_in[0:*:skip]
;y = y_in[0:*:skip]
;
;magnitude = SQRT(U^2 + V^2)                                           ;Calculate magnitude of wind
;
;IF KEYWORD_SET(cbRight) THEN cbVertical=1                             ;Set veritcal if right set
;IF~KEYWORD_SET(bottom) THEN bottom = 0
;
;IF (N_ELEMENTS(levels) EQ 0) THEN BEGIN                             ;Check levels key set
;  levels = INDGEN(RANGE(magnitude,/ROUND)+1)+FIX(MIN(magnitude,/NAN))
;ENDIF
;interval = N_ELEMENTS(levels)-1
;
;IF ~KEYWORD_SET(position) THEN position = [0.1, 0.1, 0.9, 0.9]        ;Default plot position
;
;IF ~KEYWORD_SET(interval) THEN interval = 10                          ;Set default interval
;IF ~KEYWORD_SET(title)    THEN title    = 'A Plot'                    ;Default plot name
;
;IF KEYWORD_SET(map_on) THEN BEGIN
;  IF ~KEYWORD_SET(mapLimit) THEN $
;    mapLimit = [MIN(y), MIN(x), MAX(y), MAX(x)]                       ;Default domain based on lat/lon inputs
;  GLOBAL_MAP, MAPLIMIT   = mapLimit,   $
;              TITLE      = title,      $
;              POSITION   = position,   $
;              ADVANCE    = advance,    $
;              LABEL_AXES = label_axes, $
;              CHARSIZE   = charsize,   $
;              _EXTRA     = extra,      $
;              /MAPSET
;ENDIF
;
;IF (color_table EQ !NULL) THEN color_table = 33
;
;LoadCT, color_table, NColors=interval, BOTTOM=bottom, $               ;Get color values
;  RGB_TABLE=colors, /SILENT
;LoadCT, color_table, NColors=interval, BOTTOM=bottom, /SILENT         ;Load the table for the colorbar
;
;colors =        ((0 > LONG(colors[*,0])) < 255) + $
;         256 * (((0 > LONG(colors[*,1])) < 255) + $
;         256 *  ((0 > LONG(colors[*,2])) < 255))
;
;FOR i = 0, interval-1 DO BEGIN
;  tmp_u = U & tmp_v = V
;  id = WHERE(magnitude LT levels[i] OR magnitude GT levels[i+1],CNT)
;  IF CNT NE 0 THEN BEGIN
;    tmp_u[id] = !VALUES.F_NaN
;    tmp_v[id] = !VALUES.F_NaN
;  ENDIF
;
;  IF KEYWORD_SET(map_on) THEN overplot = 1
;
;  VELOVECT, tmp_u, tmp_v, x, y, $
;    COLOR    = colors[i], $
;    LENGTH   = length,    $
;    THICK    = thick,     $
;    OVERPLOT = overplot,  $
;    MISSING  = missingvalue
;ENDFOR
;
;
;IF KEYWORD_SET(map_on) THEN BEGIN                                     ;If map is on, overplot lat/lon and continents
;  GLOBAL_MAP, MAPLIMIT   = maplimit,   $
;              LONDEL     = lonDel,     $
;              LATDEL     = latDel,     $
;              LATLABEL   = latLabel,   $
;              LONLABEL   = lonLabel,   $
;              CHARSIZE   = charsize,   $
;              LABEL_AXES = label_axes, $
;              _EXTRA     = extra,      $
;              /OVERPLOT
;ENDIF
;
;if SIZE(extra,/TYPE) EQ 8 THEN $
;  box_axes = TOTAL(STRMATCH(TAG_NAMES(extra), 'BOX_AXES'), /INT) EQ 1 $
;ELSE $
;  box_axes = 0
;
;IF ~KEYWORD_SET(cbPos) THEN BEGIN                                     ;If a color bar is desired
;  IF KEYWORD_SET(cbVertical) THEN BEGIN                               ;If vertical color bar
;    off1 = KEYWORD_SET(box_axes) ? 2*x_ch : 0.03                        ;Set x offsets for vertical color bar
;    off2 = KEYWORD_SET(box_axes) ? 2.5*x_ch : 0.05
;    cbPos = [position[2]+off1, position[1], $
;             position[2]+off2, position[3]]
;  ENDIF ELSE BEGIN
;    off1 = KEYWORD_SET(box_axes) ? 2*y_ch : 0.01                        ;Set y offsets for horizontal colorbar
;    off2 = KEYWORD_SET(box_axes) ? 2.5*y_ch : 0.03
;    cbPos= [position[0], position[1]-off2, $                          ;Set default position horizontal color bar
;            position[2], position[1]-off1]
;  ENDELSE
;ENDIF
;
;IF KEYWORD_SET(colorbar) THEN BEGIN
;  IF N_ELEMENTS(cbformat) EQ 0 THEN $
;    cbLevels = STRTRIM(levels,2) $                 ;Set format for color bar labels floats
;  ELSE $
;   cbLevels = STRING(levels,FORMAT=cbformat)                ;Convert to string and trim up
;
;;  cgCOLORBAR, interval, bottom, $
;;              Position  = cbPos,      $
;;              TITLE     = cbTitle,    $
;;              VERTICAL  = cbVertical, $
;;              RIGHT     = cbRight,    $
;;              CHARSIZE  = charsize
;
;  cgColorbar,   TICKNAMES = cblevels,                 $
;                DISCRETE  = discrete,                 $
;                NColors   = interval,                 $
;                Bottom    = bottom,                   $
;                DIVISIONS = N_ELEMENTS(levels)-1,  $
;                Position  = cbPos,                    $
;                TITLE     = cbTitle,                  $
;                VERTICAL  = cbVertical,               $
;                RIGHT     = cbRight,                  $
;                CHARSIZE  = charsize
;;  kw_COLORBAR, interval, bottom, $
;;      POSITION = cbPos, $
;;      TITLE    = cbTitle, $
;;      TICKNAMES= levels, $
;;      VERTICAL = cbVertical, $
;;      RIGHT    = cbRight,    $
;;      CHARSIZE = charsize, $
;;      THICK    = thick
;
;ENDIF
;
;!P.BACKGROUND = cur_Background & !P.COLOR = cur_color                 ;Reset colors




PRO KW_VELOVECT,U,V,X,Y,     $
  MISSING    = Missing,   $
  LENGTH     = length,    $
  DOTS       = dots,      $
  SKIP       = skip,      $
  MAXMAG     = maxmag,    $
  LEVELS     = levels,    $
  RGB_TABLE  = rgb_table, $
  CLIP       = clip,      $
  NOCLIP     = noclip,    $
  OVERPLOT   = overplot,  $
  _REF_EXTRA = extra

; $Id: //depot/Release/ENVI53_IDL85/idl/idldir/lib/velovect.pro#1 $
;
; Copyright (c) 1983-2015, Exelis Visual Information Solutions, Inc. All
;       rights reserved. Unauthorized reproduction is prohibited.

;
;+
; NAME:
;   VELOVECT
;
; PURPOSE:
;   Produce a two-dimensional velocity field plot.
;
;   A directed arrow is drawn at each point showing the direction and
;   magnitude of the field.
;
; CATEGORY:
;   Plotting, two-dimensional.
;
; CALLING SEQUENCE:
;   VELOVECT, U, V [, X, Y]
;
; INPUTS:
;   U:  The X component of the two-dimensional field.
;       U must be a two-dimensional array.
;
;   V:  The Y component of the two dimensional field.  Y must have
;       the same dimensions as X.  The vector at point [i,j] has a
;       magnitude of:
;
;           (U[i,j]^2 + V[i,j]^2)^0.5
;
;       and a direction of:
;
;           ATAN2(V[i,j],U[i,j]).
;
; OPTIONAL INPUT PARAMETERS:
;   X:  Optional abcissae values.  X must be a vector with a length
;       equal to the first dimension of U and V.
;
;   Y:  Optional ordinate values.  Y must be a vector with a length
;       equal to the first dimension of U and V.
;
; KEYWORD INPUT PARAMETERS:
;   COLOR:  The color index used for the plot.
;
;   DOTS:   Set this keyword to 1 to place a dot at each missing point.
;       Set this keyword to 0 or omit it to draw nothing for missing
;       points.  Has effect only if MISSING is specified.
;
;   LENGTH: Length factor.  The default of 1.0 makes the longest (U,V)
;       vector the length of a cell.
;
;       MISSING: Missing data value.  Vectors with a LENGTH greater
;       than MISSING are ignored.
;
;       OVERPLOT: Set this keyword to make VELOVECT "overplot".  That is, the
;               current graphics screen is not erased, no axes are drawn, and
;               the previously established scaling remains in effect.
;
;   SKIP    : Interval to skip to reduce density. Default is 1; no skipping
;   LEVELS  : Array of magnitude levels to plot. Vectors within these bins
;              will be colored based on values in RGB_TABLE keyword.
;   RGB_TABLE : [n x 3] element array containing the RGB values for the vectors
;                 to plot. N should match the number of levels-1
;                 Default is to load a random color table and return the
;                 RGB values of the table to the RGB_TABLE keyword.
;   Note:   All other keywords are passed directly to the PLOT procedure
;       and may be used to set option such as TITLE, POSITION,
;       NOERASE, etc.
; OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   Plotting on the selected device is performed.  System
;   variables concerning plotting are changed.
;
; RESTRICTIONS:
;   None.
;
; PROCEDURE:
;   Straightforward.  Unrecognized keywords are passed to the PLOT
;   procedure.
;
; MODIFICATION HISTORY:
;   DMS, RSI, Oct., 1983.
;   For Sun, DMS, RSI, April, 1989.
;   Added TITLE, Oct, 1990.
;   Added POSITION, NOERASE, COLOR, Feb 91, RES.
;   August, 1993.  Vince Patrick, Adv. Visualization Lab, U. of Maryland,
;       fixed errors in math.
;   August, 1993. DMS, Added _EXTRA keyword inheritance.
;   January, 1994, KDB. Fixed integer math which produced 0 and caused
;                   divide by zero errors.
;   December, 1994, MWR. Added _EXTRA inheritance for PLOTS and OPLOT.
;   June, 1995, MWR. Removed _EXTRA inheritance for PLOTS and changed
;            OPLOT to PLOTS.
;       September, 1996, GGS. Changed denominator of x_step and y_step vars.
;       February, 1998, DLD.  Add support for CLIP and NO_CLIP keywords.
;       June, 1998, DLD.  Add support for OVERPLOT keyword.
;   June, 2002, CT, RSI: Added the _EXTRA back into PLOTS, since it will
;       now (as of Nov 1995!) quietly ignore unknown keywords.
;   Oct 18 2018 Kyle R. Wodzicki
;       Added coloring of vectors based on speed; all vectors drawn same length.
;       Added scaling of vectors to user defined length; default is to scale
;         relative to maximum speed.
;       Added plotting as meteorological wind barbs.
;       Removes title from Oct, 1990
;-
;

COMPILE_OPT strictarr, IDL2

ON_ERROR, 2                      ;Return to caller if an error occurs

IF N_ELEMENTS(skip)    NE 0 THEN BEGIN
  uu = u[0:*:skip, 0:*:skip]
  vv = v[0:*:skip, 0:*:skip]
  xx = x[0:*:skip]
  yy = y[0:*:skip]
ENDIF ELSE BEGIN
  uu = u
  vv = v
  xx = x
  yy = y
ENDELSE

s = SIZE(uu)
t = SIZE(vv)
IF s[0] NE 2 OR TOTAL( ABS(s[0:2]-t[0:2]) ) NE 0 THEN $
  MESSAGE, 'U and V parameters must be 2D and same size.'

IF N_PARAMS() LT 3 THEN $
  xx = FINDGEN( s[1] ) $
ELSE IF N_ELEMENTS(xx) NE s[1] THEN $
  MESSAGE, 'X and Y arrays have incorrect size.'

IF N_PARAMS() LT 4 THEN $
  yy = FINDGEN(s[2]) $
ELSE IF N_ELEMENTS(yy) NE s[2] THEN $
  MESSAGE, 'X and Y arrays have incorrect size.'

IF N_ELEMENTS(missing) EQ 0 THEN missing = 1.0e30
IF N_ELEMENTS(length)  EQ 0 THEN length  = 1.0

mag = SQRT( uu^2 + vv^2 )             ;magnitude.

                ;Subscripts of good elements
good = WHERE(mag LT missing, ngood, COMPLEMENT=bad, NCOMPLEMENT=nbad)           ; Locate good and bad points
IF ngood EQ 0 THEN MESSAGE, 'No good data found!'

ugood  = uu[good]
vgood  = vv[good]
x0     = MIN(xx, MAX=x1)                     ;get scaling
y0     = MIN(yy, MAX=y1)
x_step = (x1-x0)/(s[1]-1)   ; Convert to float. Integer math
y_step = (y1-y0)/(s[2]-1)   ; could result in divide by 0


IF N_ELEMENTS(levels) NE 0 THEN BEGIN
  ugood  /= mag[good]                                                                  ; If coloring by magnitude scale all vectors to be the same length
  vgood  /= mag[good]                                                                  ; If coloring by magnitude scale all vectors to be the same length
  length *= 3.0
  maxmag  = 1.0
  ids  = VALUE_LOCATE(levels, mag[good])
  hist = HISTOGRAM(ids, MIN = 0, BINSIZE = 1, REVERSE_INDICE = ri)
  IF N_ELEMENTS(rgb_table) EQ 0 THEN $                                          ; If no RGB table defined
    LOADCT, 34, NCOLORS = N_ELEMENTS(levels)-1, RGB=rgb_table, /SILENT          ; Load one

  colors =        ((0 > LONG(rgb_table[*,0])) < 255) + $
           256 * (((0 > LONG(rgb_table[*,1])) < 255) + $
           256 *  ((0 > LONG(rgb_table[*,2])) < 255))                           ; Compute 24-bit color values
ENDIF ELSE BEGIN
  IF N_ELEMENTS(maxmag) EQ 0 THEN $
    maxmag = MAX( [ MAX( ABS(ugood/x_step) ), MAX( ABS(vgood/y_step) ) ] )
  hist   = [ngood]
  ri     = [2, ngood+2, good]
  colors = [!P.COLOR]
ENDELSE

sina = length * (ugood/maxmag)
cosa = length * (vgood/maxmag)

;
        ;--------------  plot to get axes  ---------------
IF N_ELEMENTS(noclip) EQ 0 THEN noclip = 1
x_b0 = x0 - x_step
x_b1 = x1 + x_step
y_b0 = y0 - y_step
y_b1 = y1 + y_step

DEVICE, GET_DECOMPOSED = old_Decomp                                             ; Get the decomposed state of the graphics
DEVICE, DECOMPOSED     = 1                                                      ; Set to 24-bit graphics

IF (NOT KEYWORD_SET(overplot)) THEN $
  PLOT,[x_b0, x_b1], [y_b1,y_b0], /NODATA, /XST, /YST, _EXTRA = extra

;IF (NOT KEYWORD_SET(overplot)) TEHN BEGIN
;  PLOT,[x_b0, x_b1], [y_b1,y_b0], /nodata, /xst, /yst, $
;      _EXTRA = extra
;  endif else begin
;    plot,[x_b0,x_b1],[y_b1,y_b0],/nodata,/xst,/yst, $
;      _EXTRA = extra
;  endelse
;endif

IF N_ELEMENTS(clip) EQ 0 THEN $
  clip = [!X.crange[0], !Y.crange[0], !X.crange[1], !Y.crange[1]]
;
r     =  0.3                          ;len of arrow head
angle = 22.5 * !DTOR                 ;Angle of arrowhead
st    = r * SIN(angle)             ;sin 22.5 degs * length of head
ct    = r * COS(angle)
;

FOR j = 0, N_ELEMENTS(hist)-1 DO BEGIN
  id = ri[ ri[j]:ri[j+1]-1 ]
  FOR i = 0, hist[j]-1 DO BEGIN          ;Each point
    x0  = xx[ good[ id[i] ] MOD s[1] ]     ;get coords of start & end
    dx  = sina[ id[i] ]
    x1  = x0 + dx
    y0  = yy[ good[ id[i] ] / s[1] ]
    dy  = cosa[ id[i] ]
    y1  = y0 + dy
    xxx = [x0, x1, x1-(ct * dx / x_step - st * dy / y_step) * x_step, $
               x1, x1-(ct * dx / x_step + st * dy / y_step) * x_step ]
    yyy = [y0, y1, y1-(ct * dy / y_step + st * dx / x_step) * y_step, $
               y1, y1-(ct * dy / y_step - st * dx / x_step) * y_step]

    PLOTS, xxx, yyy, $
      CLIP   = clip, $
      NOCLIP = noclip, $
      COLOR  = colors[j], $
      _EXTRA = extra
  ENDFOR
ENDFOR

IF KEYWORD_SET(dots) AND nbad GT 0 THEN $
  PLOTS, xx[bad mod s[1]], yy[bad / s[1]], $
    PSYM   = 3, $
    CLIP   = clip, $
    NOCLIP = noclip, $
    _EXTRA = extra

DEVICE, DECOMPOSED = old_Decomp                                                 ; Reset to original value

END