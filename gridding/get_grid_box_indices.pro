FUNCTION GET_GRID_BOX_INDICES, lonIn, lat, refLon, refLat

COMPILE_OPT IDL2

IF N_PARAMS() NE 4 THEN MESSAGE, 'Incorrect number of inputs'

IF TOTAL( lonIn.DIM NE lat.DIM, /INT) NE 0 THEN $
  MESSAGE, 'Longitude and latitude values must be same size!'

eps = MACHAR( DOUBLE = lat.TYPECODE EQ 5 )

lon = lonIn
IF TOTAL(refLon LT 0.0, /INT) GT 0 THEN BEGIN
  id = WHERE(lonIn GT 180.0, cnt)
  IF cnt GT 0 THEN lon[id] -= 360.0
ENDIF ELSE BEGIN
  id = WHERE(lonIn LT 0.0, cnt)
  IF cnt GT 0 THEN lon[id] += 360.0
ENDELSE

ids          = LINDGEN(refLon.LENGTH, refLat.LENGTH)
outIDs       = MAKE_ARRAY(lonIn.DIM, VALUE=-1L)

lonX         = DINDGEN(refLon.LENGTH+1)
latX         = DINDGEN(refLat.LENGTH+1)
lonBins      = INTERPOL(refLon, lonX[0:-2], lonX-0.5)
latBins      = INTERPOL(refLat, latX[0:-2], latX-0.5)
lon          = lon MOD MAX(lonBins)

tmp = latBins[-1]                                                             ; Get last latitude bin
nn  = 0ULL                                                                    ; Counter
WHILE tmp EQ latBins[-1] DO BEGIN                                             ; While last latitude bin is equal to temporary variable
  nn  += 1ULL                                                                 ; Increment nn
  tmp += eps.EPS * nn                                                         ; Try to increase tmp by smallest amount possible
ENDWHILE                                                                      ; End while
latBins[-1] = tmp                                                             ; Replace last latitude bin with ever so slightly larger value; keep values right on last bin edge within bin

latHist = KW_HISTOGRAM(lat, BINS=latBins, REVERSE_INDICES=latRI)
FOR j = 1, latHist.LENGTH-2 DO BEGIN
  IF latHist[j] EQ 0 THEN CONTINUE
  latID   = latRI[ latRI[j]:latRI[j+1]-1 ]
  lonHist = KW_HISTOGRAM(lon[latID], BINS=lonBins, REVERSE_INDICES=lonRI)
  FOR i = 1, lonHist.LENGTH-2 DO BEGIN
    IF lonHist[i] EQ 0 THEN CONTINUE
    lonID         = lonRI[ lonRI[i]:lonRI[i+1]-1 ]
    lonID         = latID[ lonID ]
    outIDs[lonID] = ids[i-1,j-1]
  ENDFOR
ENDFOR

RETURN, outIDs
 
END

