FUNCTION LATITUDE_LABELS, range, extra

COMPILE_OPT IDL2

eps = MACHAR()
IF (extra.LATDEL MOD 1.0) LT eps.EPS THEN BEGIN
  nn     = (Range[1] - Range[0]) / extra.LATDEL + 1
  xx     = INDGEN(nn) * LONG(extra.LATDEL) + Range[0]
  STOP
  south  = WHERE(xx LT 0, nsouth, COMPLEMENT=north, NCOMPLEMENT=nnorth)
  label = STRTRIM( ABS(xx), 2 )
  IF nsouth GT 0 THEN label[south] += 'S'
  IF nnorth GT 0 THEN label[north] += 'N'
  RETURN, label
ENDIF

RETURN, !NULL

END
