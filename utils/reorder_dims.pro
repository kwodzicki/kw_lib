FUNCTION REORDER_DIMS, data, dimension, DIMORD = dimOrd

COMPILE_OPT IDL2

IF data.NDIM LE 1 THEN RETURN, data

IF N_ELEMENTS(dimOrd) EQ data.NDIM THEN $
  RETURN, TRANSPOSE(data, SORT(dimOrd))

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1

IF dimension NE 1 THEN BEGIN
  dimOrd = INDGEN( SIZE(data, /N_DIMENSION) )
  id     = WHERE( dimOrd NE (dimension-1), cnt )
  IF cnt EQ 0 THEN MESSAGE, 'Dimension not compatible'
  dimOrd = [dimension-1, id]
  RETURN, TRANSPOSE(data, dimOrd)
ENDIF ELSE $
  dimOrd = -1

RETURN, data

END
