PRO KW_MAP_GRID, LATDEL=latdel, LONDEL=londel, LABEL=label, _EXTRA = _extra

COMPILE_OPT IDL2

IF N_ELEMENTS(londel) EQ 0 THEN londel = 45
IF N_ELEMENTS(latdel) EQ 0 THEN latdel = 30
extra = DICTIONARY(_extra)

IF extra.HasKey('GLINESTYLE') EQ 0 THEN extra['GLINESTYLE'] = 1
IF extra.HasKey('CHARSIZE'  ) EQ 0 THEN extra['CHARSIZE'  ] = 1.0

FOR i = 0, 1 DO BEGIN
  AXIS, xAxis=i, xTickFormat="(A1)", xTicks = 1, xMinor = 1
  AXIS, yAxis=i, yTickFormat="(A1)", yTicks = 1, yMinor = 1
ENDFOR

lon = 0
WHILE lon LT 360 DO BEGIN 
  IF lon GE !MAP.LL_BOX[1] AND lon LE !MAP.LL_BOX[3] THEN BEGIN
    PLOTS, lon*[1,1], [-90, 90], /DATA, $
      LINESTYLE = extra['GLINESTYLE']
    IF KEYWORD_SET(label) THEN BEGIN 
      xy  = CONVERT_COORD(lon, !MAP.LL_BOX[0], /DATA, /TO_NORMAL)
      txt = (lon GT 180) ? -1 : 1
      txt = STRTRIM( LONG(lon*txt), 2 )
      XYOUTS, xy[0], xy[1]-!Y_CH_SIZE*extra['CHARSIZE'], txt, $ 
        CHARSIZE  = extra['CHARSIZE'], $
        ALIGNMENT = 0.5, /NORMAL
    ENDIF
  ENDIF
  lon = lon + londel
ENDWHILE


lat = 0
WHILE lat LT 90 DO BEGIN
  FOR i = -1, 1, 2 DO BEGIN
    llat = lat * i
    IF llat GE !MAP.LL_BOX[0] AND llat LE !MAP.LL_BOX[2] THEN BEGIN
      FOREACH lon, LIST( [0, 180], [180, 360] ) DO $
        PLOTS, lon, llat*[1,1], /DATA, $
          LINESTYLE = extra['GLINESTYLE']
      IF KEYWORD_SET(label) THEN BEGIN 
        xy = CONVERT_COORD(!MAP.LL_BOX[1], llat, /DATA, /TO_NORMAL)
        XYOUTS, xy[0]-!X_CH_SIZE, xy[1]-!Y_CH_SIZE*extra['CHARSIZE']*0.5, $
          STRTRIM(LONG(llat),2), $
          CHARSIZE  = extra['CHARSIZE'], $
          ALIGNMENT = 1.0, /NORMAL
      ENDIF
    ENDIF
    IF lat EQ 0 THEN BREAK
  ENDFOR
  lat = lat + latdel
ENDWHILE

END
