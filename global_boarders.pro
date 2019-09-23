PRO GLOBAL_BOARDERS
; TO plot U.S. drought monitor shape files using Coyote Grafics

file = '~/idl/TM_WORLD_BORDERS_SIMPL-0/TM_WORLD_BORDERS_SIMPL-0.3.shp'
file = '~/idl/TM_WORLD_BORDERS-0/TM_WORLD_BORDERS-0.3.shp'

cgShapeInfo, file
GLOBAL_MAP, /MAPSET, maplimit=[-90, -180, 90, 180]
  cgDrawShapes, file, $
    AttrName   ='NAME', $
    AttrValues = 'BOLIVIA', $
    FColors    = 'red', $
    FILL       = 1, $
    Thick      = 1, $
    Colors     = 'charcoal'
  GLOBAL_MAP, /BOX_AXES
	
	;=== Plot location of 'NORMAN 3 SSE OK US' station
;	XYOUTS, -97.4377, 35.1809, 'x', /DATA, $
;	  ALIGNMENT = 0.5, $
;	  CHARSIZE  = charsize*2, $
;	  CHARTHICK = 6, $
;	  COLOR     = cgCOLOR('green')
;	
;	AL_LEGEND, drought_labels, $
;	  LINESTYLE        = 0, $
;	  THICK            = 7, $
;	  LINSIZE          = 0.2, $
;	  CHARSIZE         = charsize, $
;	  COLORS           = colors, $
;	  BACKGROUND_COLOR = 'white', $
;	  POSITION  =[-80, 32]

IF KEYWORD_SET(saveplot) THEN BEGIN
  PS_OFF
  PSTOPNG, ps_file, PNGFILE=png_file, DPI=dpi, /LANDSCAPE
ENDIF
END