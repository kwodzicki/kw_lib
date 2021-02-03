FUNCTION LONGITUDE_LABELS, range, extra

COMPILE_OPT IDL2

eps = MACHAR()
IF (extra.LONDEL MOD 1.0) LT eps.EPS THEN BEGIN
  nn     = (Range[1] - Range[0]) / extra.LONDEL + 1
  xx     = INDGEN(nn) * LONG(extra.LONDEL) + Range[0]
  id     = WHERE(xx GT 180, cnt)
  IF cnt GT 0 THEN xx[id] -= 360
  west   = WHERE(xx LT 0, nwest, COMPLEMENT=east, NCOMPLEMENT=neast)
  label = STRTRIM( ABS(xx), 2 )
  IF nwest GT 0 THEN label[west] += 'W'
  IF neast GT 0 THEN label[east] += 'E'
  RETURN, label
ENDIF

RETURN, !NULL

END
