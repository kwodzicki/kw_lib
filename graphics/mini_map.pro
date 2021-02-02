PRO MINI_MAP, maplimit, position, $
   PROJECTION  = projection,  $
   BOX_AXES    = box_axes,    $
   LatLon_ZOOM = latLon_Zoom, $
   MAP_Size    = map_size,    $ 
   LONDEL      = londel,      $
   LATDEL      = latdel,      $
   TOP         = top,         $
   RIGHT       = right,       $
   COLOR       = color,       $
   USA         = usa,         $
   COUNTRIES   = countries,   $
   CHARSIZE    = charsize,    $
   _EXTRA      = _extra
;+
; Name:
;   MINI_MAP
; Purpose:
;   A procedure to place a small map in either the top or bottom,
;   left or right corners of an existing map. This map will
;   have a larger domain than the main map and a red box will
;   be drawn outlining the location of the main map.
; Inputs:
;   maplimit    : The lat/lon of the main map limites. Must be in
;                   format [minlat, minlon, maxlat, maxlon]
;   position    : The position of the main map
; Keywords:
;   PROJECTION  : The projection the mini map should have. Default is
;                   Cylindrical.
;   BOX_AXES    : Set to have boxed axes in the mini map.
;   LatLon_Zoom : Set to the degrees to zoom out or in on the 
;                   main map. Default is 25 degrees.
;   LONDEL      : Set to the interval for longitude labels.
;   LATDEL      : Set to the interval for latitude labels.
;   TOP         : Set to plot the mini map in the top left
;   RIGHT       : Set to plot the mini map in the bottom right
;                   If both are set, plots in top right, if neither, 
;                   plots bottom left.
;   USA         : Set to draw states in the USA.
;   COUNTRIES   : Set to draw country boundaries.
; Author and History:
;   Kyle R. Wodzicki     Created 06 Mar. 2015
;-
COMPILE_OPT IDL2

;=== Set up some default keyword values.
IF (N_ELEMENTS(latLon_Zoom) EQ 0) THEN latLon_Zoom = 25
IF (N_ELEMENTS(map_size)    EQ 0) THEN map_size    = 0.15
IF (N_ELEMENTS(color)       EQ 0) THEN color       = 255
IF (N_ELEMENTS(projection)  EQ 0) THEN projection  = 'CYLINDRICAL'

;=== Set x and y zooms so that the mini map is a square
x_zoom = map_size 
y_zoom = (!D.X_VSIZE * map_size) / !D.Y_VSIZE
x_ch   = FLOAT(!D.X_CH_SIZE) / !D.X_VSIZE * 2.0
y_ch   = FLOAT(!D.Y_CH_SIZE) / !D.Y_VSIZE * 2.0
xy_ch  = (y_ch GT x_ch) ? y_ch : x_ch

;=== Set up the limits for the mini map based on the latLon_Zoom
lim    = maplimit + [-1, -1, 1, 1] * latLon_Zoom

;=== Set up the offset for the white background based on box_axis
;==== keyword and the graphics window
IF KEYWORD_SET(box_axes) THEN BEGIN
  offset  = (!D.NAME EQ 'PS') ? 0.015 : 0.011
ENDIF ELSE offset = 0

;=== Set up the thickness of lines based on the graphics window.
b_thick = (!D.NAME EQ 'PS') ? 6 : 4

;=== Set up the center longitude for the plots
IF (lim[1] LT lim[3]) THEN BEGIN
  longitude = (lim[1] + lim[3]) / 2.0
ENDIF ELSE BEGIN
  longitude = ((180.0 - lim[1]) - (180.0 + lim[3])) / 2.0
  longitude = ((longitude LT 0) ? -180.0 : 180.0) -longitude
ENDELSE

;=== Set up the position of the mini map in the graphics window                            
pos = [0.0, 0.0, 0.0, 0.0]
IF KEYWORD_SET(right) THEN BEGIN
  pos[2] = position[2]-xy_ch
  pos[0] = pos[2] - x_zoom
ENDIF ELSE BEGIN
  pos[0] = position[0]+xy_ch
  pos[2] = pos[0] + x_zoom
ENDELSE

IF KEYWORD_SET(top) THEN BEGIN
  pos[3] = position[3]-xy_ch & pos[1] = pos[3] - y_zoom
ENDIF ELSE BEGIN
  pos[1] = position[1]+xy_ch & pos[3] = pos[1] + y_zoom
ENDELSE
;pos = position

;=== Set up the x and y coordinates for the white background for the
;=== mini map.
x      = [pos[0], pos[0], pos[2], pos[2], pos[0]]
x_1    = [-1.4, -1.4, 1.4, 1.4, -1.4] * offset
y      = [pos[1], pos[3], pos[3], pos[1], pos[1]]
y_1    = [-2, 2, 2, -2, -2] * offset

;=== Plot the white background
;POLYFILL, x + x_1, y + y_1, COLOR=!D.N_COLORS-1, /NORMAL
POLYFILL, x + x_1, y + y_1, COLOR=!P.BACKGROUND, /NORMAL

;=== Plot the mini map over the white background
MAP_SET, 0.0, longitude, $
          NAME     = projection,   $
          LIMIT    = lim,          $
          POSITION = pos,          $
          CHARSIZE = charsize, $
          _EXTRA   = _extra
MAP_CONTINENTS, /OVERPLOT, /CONTINENTS, $
          USA       = usa,              $
          COUNTRIES = countries,        $
          COLOR     = !P.COLOR 
MAP_GRID, LATDEL   = latDel,   $
          LONDEL   = lonDel,   $
          CHARSIZE = charsize, $
          BOX_AXES = box_axes, $
          COLOR    = !P.COLOR,        $
          /COUNTRIES,          $
          /LABEL

;=== Draw a black line around the mini map if the axes are not boxed
IF ~KEYWORD_SET(box_axes) THEN $
  PLOTS, x, y, COLOR=0, THICK=b_Thick/2, /NORMAL

;=== Set up the coordinates for the red box in the mini map that 
;=== indicates the domain of the main map
x = [maplimit[1], maplimit[1], maplimit[3], maplimit[3], maplimit[1]]
y = [maplimit[0], maplimit[2], maplimit[2], maplimit[0], maplimit[0]]

;=== Draw the red box
PLOTS, x, y, COLOR = color, THICK=B_THICK/2

END
