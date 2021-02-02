PRO SEASONAL_MEANS, dates, data0, data1, data2, data3, data4, data5, data6, data7, $ 
  DIMENSION = dimension, $
  CLIMO     = climo

;+
; Name:
;   SEASONAL_MEANS
; Inputs:
;   dates   : IDL Julian date array
;   x0      : variable to compute seasonal means for
;   Multiple other variables to compute season means for
; Keywords:
;   DIMENSION  : dimension to compute mean over
;   CLIMO      : Set to compute mean over all months in season (all years),
;                 not means per year
;-

COMPILE_OPT IDL2

nArgs = N_PARAMS()                                                            ; Get number of inputs
IF nArgs LT 2 THEN MESSAGE, 'Incorrect number of inputs'

CASE nArgs OF                                                                 ; Create data list based on number of inputs
  2 : data = LIST(data0)
  3 : data = LIST(data0, data1)
  4 : data = LIST(data0, data1, data2)
  5 : data = LIST(data0, data1, data2, data3)
  6 : data = LIST(data0, data1, data2, data3, data4)
  7 : data = LIST(data0, data1, data2, data3, data4, data5)
  8 : data = LIST(data0, data1, data2, data3, data4, data5, data6)
  9 : data = LIST(data0, data1, data2, data3, data4, data5, data6, data7)
ENDCASE

dimOrds = LIST()
FOR i = 0, N_ELEMENTS(data)-1 DO BEGIN                                        ; Iterate over data list and
  data[i] = REORDER_DIMS(data[i], dimension, DIMORD=dimord)                   ; Reorder dimensions for computing means
  dimOrds.ADD, TEMPORARY(dimord)
ENDFOR

JUL2GREG, dates, mm, dd, yy                                                   ; Get month, day, and year from the dates input
uyy = yy[UNIQ(yy, SORT(yy))]                                                  ; List of unique years inorder

out = LIST()                                                                  ; Initialize list for output data
FOR i = 0, N_ELEMENTS(data)-1 DO $                                            ; Iterate for number of input data arrays
  out.ADD, {DJF : {VALUES : LIST(), YEAR : LIST()}, $                         ; Create and add structure that will contain each season of data to the output data list
            MAM : {VALUES : LIST(), YEAR : LIST()}, $
            JJA : {VALUES : LIST(), YEAR : LIST()}, $
            SON : {VALUES : LIST(), YEAR : LIST()} }

FOR k = 0, N_ELEMENTS(uyy)-1 DO BEGIN                                         ; Iterate over unique years
  FOR j = 0, 3 DO BEGIN                                                       ; Iterate over seasons
    CASE j OF                                                                 ; For each season in each year, get the indices for data points
      0 : index = WHERE( (yy EQ uyy[k]   AND mm LE  2) OR $      ; Case for DJF; use december from previous year
                         (yy EQ uyy[k]-1 AND mm EQ 12), cnt )
      1 : index = WHERE( yy EQ uyy[k] AND mm GE 3 AND mm LE  5, cnt )         ; Case for MAM
      2 : index = WHERE( yy EQ uyy[k] AND mm GE 6 AND mm LE  8, cnt )         ; Case for JJA
      3 : index = WHERE( yy EQ uyy[k] AND mm GE 9 AND mm LE 11, cnt )         ; Case for SON
    ENDCASE

    IF cnt EQ 0 THEN CONTINUE                                                 ; If no data in given case, skip it

    FOR i = 0, N_ELEMENTS(data)-1 DO BEGIN                                    ; Iterate over input data sets
      IF KEYWORD_SET(climo) THEN BEGIN
        out[i].(j).VALUES.ADD, (data[i])[index,*,*,*,*,*,*,*]                 ; Compute mean for the season; data has been reordered so that dimnsion to average over is the first dimension
      ENDIF ELSE BEGIN
        out[i].(j).VALUES.ADD, MEAN( (data[i])[index,*,*,*,*,*,*,*], DIMENSION=1, /NaN ); Compute mean for the season; data has been reordered so that dimnsion to average over is the first dimension
        out[i].(j).YEAR.ADD, uyy[k]                                             ; Add unique year to the list of years for the season
      ENDELSE
    ENDFOR
  ENDFOR
ENDFOR

FOR i = 0, N_ELEMENTS(out)-1 DO BEGIN                                         ; Iterate over output data sets
  tmp  = {}                                                                   ; Empty structure
  tags = TAG_NAMES(out[i])                                                    ; Get tag names
  FOR j = 0, N_TAGS(out[i])-1 DO BEGIN                                        ; Iterater over all tags
    IF KEYWORD_SET(climo) THEN BEGIN
      tmp1 = out[i].(j).VALUES.ToArray(DIMENSION=1, /No_Copy)
      tmp1 = {VALUES : MEAN(tmp1, DIMENSION=1, /NaN)}                         ; Convert lists to arrays and place in new temporary structure
    ENDIF ELSE BEGIN
      tmp1 = out[i].(j).VALUES.ToArray(/No_Copy)
      tmp1 = {VALUES : REORDER_DIMS(tmp1, DIMORD=dimOrds[i]), $                                                ; Convert lists to arrays and place in new temporary structure
              YEAR   : out[i].(j).YEAR.ToArray(  /No_Copy)}
    ENDELSE
    tmp  = CREATE_STRUCT(tmp, tags[j], TEMPORARY(tmp1))                       ; Append temp structure for season to temp structure for data
  ENDFOR
  ( SCOPE_VARFETCH( STRING(i, FORMAT="('data',I1)") ) ) = TEMPORARY(tmp)      ; Overwrite input data with temp structure containing seasonal means
ENDFOR

END
