FUNCTION KW_SORT_PAIR, x, y, REVERSE_INDICES = reverse_indices
;+
; Name:
;   KW_SORT_PAIR
; Purpose:
;   An IDL function to sort paired data.
; Inputs:
;    x    : X values to sort. SORTED ON THESE FIRST!!!
;    y    : Y values to sort.
; Outputs:
;    2D array of sorted values [ [x], [y] ]
; Keywords:
;    None
; Author and History:
;   Kyle R. Wodzicki     Created 22 Mar. 2017
;-
COMPILE_OPT IDL2
s  = SORT(x)																																		; Get sort indices based on x values
xx = x[s]																																				; Sort x values
yy = y[s]																																				; Sort y values
h  = HISTOGRAM(VALUE_LOCATE(xx[UNIQ(xx)],xx),MIN=0,BINSIZE=1,REVERSE_INDICES=ri); Bin based on unique x values
FOR i = 0, N_ELEMENTS(h)-1 DO BEGIN																							; Iterate over all bins
	id = ri[ ri[i]:ri[i+1]-1 ]																										; Get indices for data in given bin
	yy[id] = (yy[id])[SORT(yy[id])]																								; Sort the y values in that bin
ENDFOR
RETURN, [ [xx], [yy] ]																													; Return the sorted data
END