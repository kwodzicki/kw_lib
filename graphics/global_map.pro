PRO GLOBAL_MAP,$
  LONGITUDE       = longitude,     $
	MAPLIMIT        = maplimit,      $
	LABEL_AXES      = label_axes,    $
	OVERPLOT        = overplot,      $
	MAPSET          = mapset,        $
	POSITION        = position,      $
	PROJECTION      = projection,    $
	FUNC_GRAPHICS   = FUNC_GRAPHICS, $
	MAP_Object      = map,           $
	MAP_COLOR       = map_color,     $
	GRID_COLOR      = grid_color,    $
	FILL_CONTINENTS = fill_continents, $
  _EXTRA          = _extra
;+
; Name:
;   GLOBAL_MAP
; Purpose:
;   To plot a map of the global with latitude lines
; Input:
;   None.
; Output:
;   None.
; Keywords:
;   LONGITUDE   : Set this to the longitude that you would
;                  like the map centered at. Default is 0.0
;   MAPLIMIT    : A four (4) element array limiting the map to plot.
;                 Limits are:
;                    i. Element 0 - South Latitude
;                   ii. Element 1 - West longitude
;                  iii. Element 2 - North Latitude
;                   iv. Element 3 - East longitude
;   MAPSET      : Set keyword to only run map set
;   FUNC        : Set to use Function graphics.
; Creation/History
;   Kyle R. Wodzicki	Created 16 April 2014
;
;     MODIFIED 04 June 2014:
;       Added option of lat and longitude line interval
;     MODIFIED 05 June 2014:
;       Added advance as option for P.MULTI and the postion option and
;       title option.
;     MODIFIED 25 June 2014:
;       Added CHARSIZE keyword and BOX_AXES.
;     MODIFIED 03 July 2014:
;       This was written initially for longitudes between -180 to 180.
;       Thus, added to convert back to that style
;     MODIFIED 14 July 2014:
;       Added the FUNC_GRAPHICS keyword to utilize function graphics.
;     MODIFIED 17 July 2014:
;       This iteration of the procedure has been added to the
;       pf_cgContour program for more portability. SAVEPLOT has been
;       removed as well.
;     MODIFIED 28 July 2014:
;       Changed default latitude interval from 30 degrees to 15
;       degrees and default longitude interval from 45 to 30 degreses.
;     MODIFIED 27 Oct. 2014:
;       Changed all functions and procedures from Coyote Graphics
;       to standard IDL calls.
;     MODIFIED 19 Nov. 2014
;       Added USA keyword
;     MODIFIED 24 Feb. 2014 by Kyle R. Wodzicki:
;       Added projection keyword, default is still cylindrical
;     MODIFIED 04 Mar. 2015 by Kyle R. Wodzicki
;       Added COUNTRIES keyword.
;     MODIFIED 16 Mar. 2015 by Kyle R. Wodzicki
;       Added RIVERS keyword.
;     Modified 17 Nov. 2016 by Kyle R. Wodzicki:
;			  Updated some of the keyword inputs to be handled by _EXTRA
;-

COMPILE_OPT IDL2, HIDDEN                                              ;Set compile options

!P.BACKGROUND = !D.N_COLORS-1
!P.COLOR      = 0


extra = DICTIONARY(_extra)																										; Convert _extra to dictionary
IF extra.HasKey('TITLE')      EQ 1 THEN title = extra.Remove('TITLE')				; If 'TITLE' key exists, remove it and store locally
IF extra.HasKey('CONTINENTS') EQ 0 THEN extra['CONTINENTS'] = 1							; If 'CONTINENTS' not found in dictionary, set to one (1); i.e., enabled
IF extra.HasKey('LATDEL')     EQ 0 THEN extra['LATDEL']     = 15.0
IF extra.HasKey('LONDEL')     EQ 0 THEN extra['LONDEL']     = 30.0

charsize = extra.HasKey('CHARSIZE') ? extra['CHARSIZE'] : 1.0

;=== Filter out keywords that my cause duplicate keyword errors.
FOREACH key, extra.Keys() DO $																							; Iterate over all keys
  IF STRMATCH(key, '*FILL*', /FOLD_CASE) THEN $															; If key contains 'FILL'
    _ = extra.Remove(key)																										; Remove it

IF (N_ELEMENTS(charsize)   EQ 0) THEN charsize = 1														; Default charsize to one (1)

IF KEYWORD_SET(maplimit) THEN BEGIN                                   ;If maplimit set
  IF (N_ELEMENTS(longitude) EQ 0) THEN BEGIN                               ; and longitude not set
    IF (maplimit[1] LT maplimit[3]) THEN $
      longitude = (maplimit[1] + maplimit[3])/2.0 $                   ;Calculate middle of maplimit
    ELSE BEGIN
      longitude = ((180.0-maplimit[1])-(180.0+maplimit[3]))/2.0
      longitude = (longitude LT 0) ? -180.0-longitude $
                                   :  180.0-longitude
    ENDELSE
  ENDIF
ENDIF ELSE maplimit = [-90.0, -180.0, 90.0, 180.0]                    ;Default maplimit

IF (N_ELEMENTS(projection) EQ 0) THEN projection = 'CYLINDRICAL'
IF (N_ELEMENTS(map_color)  EQ 0) THEN map_color  = COLOR_24('black')
;=====================================================================
; SET UP FUNCTION GRAPHICS WINDOW
IF KEYWORD_SET(func_graphics) THEN BEGIN
  map = MAP(projection, LIMIT=maplimit, $
            POSITION=position, TITLE=title)
  grid = map.MAPGRID
  grid.LONGITUDE_MIN = maplimit[1] & grid.LONGITUDE_MAX = maplimit[3] ;Set longitude limits
  grid.LATITUDE_MIN  = maplimit[0] & grid.LATITUDE_MAX  = maplimit[2] ;Set latitude limits
  grid.GRID_LATITUDE = latDel      & grid.GRID_LONGITUDE= lonDel      ;Set lat/lon line spacing
  grid.linestyle     = 'dotted'                                       ;Set line style
  grid.label_position= 0                                              ;Set label position to bottom and left
  grid.FONT_SIZE     = 8                                              ;Set font size
  map['Longitudes'].LABEL_ANGLE=0                                     ;Rotate longitude labels
  continents = MAPCONTINENTS(FILL_COLOR='light gray')                 ;Plot continents
ENDIF ELSE BEGIN
  IF KEYWORD_SET(mapset) THEN BEGIN                                   ;If just setting up map
    P0Lat = (maplimit[0] + maplimit[2])/2.0
    P0Lon = N_ELEMENTS(longitude) EQ 0 ? (maplimit[1] + maplimit[3])/2.0 : longitude
    MAP_SET, P0Lat, P0Lon, $
                NAME     = projection, $; /CYLINDRICAL, $
                LIMIT    = maplimit,   $
                POSITION = position,   $
                _EXTRA   = extra.ToStruct()
    IF N_ELEMENTS(position) EQ 4 THEN !P.POSITION = position
  ENDIF ELSE BEGIN                                                    ;If not only setting map
    IF N_ELEMENTS(title) GT 0 THEN BEGIN
      xPos = (!P.position[0] + !P.position[2])/2.0
      yPos =  !P.position[3] + 0.5 * !Y_CH_SIZE * charsize
      IF extra.HasKey('BOX_AXES') EQ 1 THEN $
        IF KEYWORD_SET(extra['BOX_AXES']) THEN $
          yPos += 1.5 * !Y_CH_SIZE * charsize
      XYOUTS, xPos, yPos, title, ALIGNMENT=0.5, CHARSIZE=1.25, $
        COLOR = !P.COLOR, /NORMAL
    ENDIF
    MAP_CONTINENTS, OVERPLOT=overplot, $
       COLOR   = map_color, $
			 _EXTRA  = extra.ToStruct()
    IF KEYWORD_SET(label_axes) THEN BEGIN
      AXIS, xAxis=0, xRANGE=maplimit[1:*:2], xTickInterval=extra.LONDEL, $
        xSTYLE=1, xTickLen=-1*!Y_CH_SIZE/2, CHARSIZE = charsize, COLOR=0, _EXTRA = extra.ToStruct()
      AXIS, xAxis=1, xRANGE=maplimit[1:*:2], xTickInterval=extra.LONDEL, $
        xSTYLE=1, xTickLen=-1*!Y_CH_SIZE/2, CHARSIZE = charsize, COLOR=0, xTickFormat="(A1)"
      AXIS, yAxis=0, yRANGE=maplimit[0:*:2], yTickInterval=extra.LATDEL, $
        ySTYLE=1, yTickLen=-1*!X_CH_SIZE, CHARSIZE = charsize, COLOR=0, _EXTRA = extra.ToStruct()
      AXIS, yAxis=1, yRANGE=maplimit[0:*:2], yTickInterval=extra.LATDEL, $
        ySTYLE=1, yTickLen=-1*!X_CH_SIZE, CHARSIZE = charsize, COLOR=0, yTickFormat="(A1)"
    ENDIF ELSE $
     MAP_GRID, /LABEL, COLOR = grid_color, _EXTRA = extra.ToStruct()
  ENDELSE
ENDELSE

IF KEYWORD_SET(box_axes) THEN title = FILE_BASENAME(title, '!C')      ;Remove return character from title
!P.COLOR      = !D.N_COLORS-1
!P.BACKGROUND = 0
END
