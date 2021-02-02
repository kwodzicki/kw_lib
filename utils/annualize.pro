PRO ANNUALIZE, yearsIn, data0, data1, data2, data3, data4, data5, data6, data7, $
  OUTDATES  = outdates, $
  GREGORIAN = gregorian, $
  _EXTRA = _extra
;+
; Name:
;   ANNUALIZE
; Purpose:
;   Function to compute annual means of data based on corresponding
;   years of data
; Inputs:
;   years  : Array of years containing the year coresponding to data point
;   data   : Data to annualize, allows for eight (8) inputs to speed-up 
;               processing.
; Keywords:
;   OUTDATES  : Set to named variable to return yearly dates into
;   GREGORIAN : Set if the yearsIn data are GREGORIAN (or julian) IDL dates
;   _EXTRA : Any keywords accepted by MEAN() function
; Author and History:
;   Kyle R. Wodzicki
;-
COMPILE_OPT IDL2

nArgs = N_PARAMS()
IF nArgs LT 2 THEN MESSAGE, 'Incorrect number of inputs'

CASE nArgs OF
  2 : data = LIST(data0)
  3 : data = LIST(data0, data1)
  4 : data = LIST(data0, data1, data2)
  5 : data = LIST(data0, data1, data2, data3)
  6 : data = LIST(data0, data1, data2, data3, data4)
  7 : data = LIST(data0, data1, data2, data3, data4, data5)
  8 : data = LIST(data0, data1, data2, data3, data4, data5, data6)
  9 : data = LIST(data0, data1, data2, data3, data4, data5, data6, data7)
ENDCASE

IF KEYWORD_SET(gregorian) THEN $
  JUL2GREG, yearsIn, mm, dd, years $
ELSE $
  years = yearsIn 

uniqYears = years[UNIQ(years, SORT(years))]
outdates  = GREG2JUL(1, 1, uniqYears, 0)

out = LIST()
FOR i = 0, N_ELEMENTS(data)-1 DO out.ADD, LIST()

extra = DICTIONARY(_extra, /EXTRACT)

FOR i = 0, N_ELEMENTS(uniqYears)-1 DO BEGIN
  id = WHERE(years EQ uniqYears[i], cnt)
  IF cnt GT 10 THEN $
    FOR j = 0, N_ELEMENTS(data)-1 DO $
      IF extra.HasKey('DIMENSION') THEN $
        CASE extra['DIMENSION'] OF
          1 : out[j].ADD, MEAN( (data[j])[id, *, *, *, *, *, *, *], _EXTRA=_extra)
          2 : out[j].ADD, MEAN( (data[j])[ *,id, *, *, *, *, *, *], _EXTRA=_extra)
          3 : out[j].ADD, MEAN( (data[j])[ *, *,id, *, *, *, *, *], _EXTRA=_extra)
          4 : out[j].ADD, MEAN( (data[j])[ *, *, *,id, *, *, *, *], _EXTRA=_extra)
          5 : out[j].ADD, MEAN( (data[j])[ *, *, *, *,id, *, *, *], _EXTRA=_extra)
          6 : out[j].ADD, MEAN( (data[j])[ *, *, *, *, *,id, *, *], _EXTRA=_extra)
          7 : out[j].ADD, MEAN( (data[j])[ *, *, *, *, *, *,id, *], _EXTRA=_extra)
          8 : out[j].ADD, MEAN( (data[j])[ *, *, *, *, *, *, *,id], _EXTRA=_extra)
        ENDCASE $
      ELSE $
        out[j].ADD, MEAN(data[j,id], _EXTRA=_extra)
ENDFOR

FOR i = 0, N_ELEMENTS(data)-1 DO $
  ( SCOPE_VARFETCH( STRING(i, FORMAT="('data',I1)") ) ) = $
    out[i].ToArray(/TRANSPOSE, /No_Copy)

END
