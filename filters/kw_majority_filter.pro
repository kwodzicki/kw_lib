FUNCTION KW_MAJORITY_FILTER, in_data, WIDTH = width
;+
; Name:
;   KW_MAJORITY_FILTER
; Purpose:
;   A function to apply a majority filter to a 2D data array.
; Restrictions:
;   Only works on binary arrays.
;-
COMPILE_OPT IDL2

dims = SIZE(in_data, /DIMENSIONS)
IF (N_ELEMENTS(dims)  NE 2) THEN MESSAGE, 'Input MUST be 2D array!'
IF (N_ELEMENTS(width) EQ 0) THEN width = 3
newdata = in_data

offset = (width-1)/2

FOR i = offset, dims[0]-offset-1 DO BEGIN
  FOR j = offset, dims[1]-offset-1 DO BEGIN
    test = (TOTAL(in_data[i-offset:i+offset, j-offset:j+offset])-in_data[i,j]) / (width^2-1)
    newdata[i,j] = (test GE 0.5) ? 1 : 0
  ENDFOR
ENDFOR

;FOR i = offset, dims[0]-offset-1 DO BEGIN
;  FOR j = offset, dims[1]-offset-1 DO BEGIN
;    test = (TOTAL(newdata[i-offset:i+offset, j-offset:j+offset])-newdata[i,j]) / (width^2-1)
;    newdata[i,j] = (test GE 0.5) ? 1 : 0
;  ENDFOR
;ENDFOR

;=== Down columns and across rows L-R
;FOR i = 1, dims[0]-2 DO BEGIN
;  FOR j = 1, dims[1]-2 DO BEGIN
;    test = TOTAL(newdata[i-1:i+1, j-1:j+1, 0] - newdata[i,j, 0])/8
;    IF (test GE 0.5) THEN newdata[i,j, 0] = 1
;  ENDFOR
;ENDFOR
;=== Up columns and across rows L-R
;FOR i = 1, dims[0]-2 DO BEGIN
;  FOR j = dims[1]-2, 1, -1 DO BEGIN
;    test = TOTAL(newdata[i-1:i+1, j-1:j+1, 1] - newdata[i,j, 1])/8
;    IF (test GE 0.5) THEN newdata[i,j, 1] = 1
;  ENDFOR
;ENDFOR
;
;;=== Down columns and across rows R-L
;FOR i = dims[0]-2, 1, -1 DO BEGIN
;  FOR j = 1, dims[1]-2 DO BEGIN
;    test = TOTAL(newdata[i-1:i+1, j-1:j+1, 2] - newdata[i,j, 2])/8
;    IF (test GE 0.5) THEN newdata[i,j, 2] = 1
;  ENDFOR
;ENDFOR
;;=== Up columns and across rows
;FOR i = dims[0]-2, 1, -1 DO BEGIN
;  FOR j = dims[1]-2, 1, -1 DO BEGIN
;    test = TOTAL(newdata[i-1:i+1, j-1:j+1, 3] - newdata[i,j, 3])/8
;    IF (test GE 0.5) THEN newdata[i,j, 3] = 1
;  ENDFOR
;ENDFOR
;
;id = WHERE(MEAN(newdata, DIMENSION=3) GE 0.5, CNT)
;newdata = INTARR(dims)
;IF (CNT NE 0) THEN newdata[id] = 1

RETURN, newdata
END