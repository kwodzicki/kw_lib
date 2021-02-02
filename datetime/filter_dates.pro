FUNCTION FILTER_DATES, dates, bounds

COMPILE_OPT IDL2

ids = LIST()
dim = bounds.DIM
IF bounds.NDIM EQ 1 THEN dim = [dim, 1]

FOR i = 0, dim[1]-1 DO BEGIN
  id = WHERE(dates GE bounds[0,i] AND dates LT bounds[1,i], cnt)
  IF cnt GT 0 THEN ids.ADD, id
ENDFOR

RETURN, ids.ToArray(DIMENSION=1, /No_Copy)

END
