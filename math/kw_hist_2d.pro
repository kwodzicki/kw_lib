FUNCTION KW_HIST_2D, in1, in2, $
  MIN1 = min1, MAX1 = MAX1, BIN1 = bin1, $
  MIN2 = min2, MAX2 = MAX2, BIN2 = bin2
;+
; Name:
;   KW_HIST_2D
; Purpose:
;   An IDL function to create a 2D histogram that always for custom/variable
;   bin sizes.
; Inputs:
;   in1   : First input data
;   in2   : Second input data
; Outputs:
;   A 2D histogram
; Keywords:
;   MIN1    
;   MAX1
;   BIN1
;   MIN2
;   MAX2
;   BIN2
; Author and History:
;   Kyle R. Wodzicki     Created 01 Aug. 2017
;-
COMPILE_OPT IDL2

IF (N_PARAMS() NE 2) THEN MESSAGE, 'Incorrect number of inputs!'
IF N_ELEMENTS(bin1) GT 1 THEN $                                                 ; If the BIN1 keyword has more then one (1) element, assume it is an array of bins to use
	bins1 = bin1 $                                                                ; Set bins1 equal to bin1
ELSE BEGIN                                                                      ; Else, it either has one (1) or no elements
	IF N_ELEMENTS(bin1) EQ 0 THEN bin1 = 1                                        ; If it has NO elements, set the bin size to one (1)
	IF N_ELEMENTS(min1) EQ 0 THEN min1 = MIN(in1, /NaN)                           ; If the min1 keyword is NOT set, set it to the minium of the data
  IF N_ELEMENTS(max1) EQ 0 THEN max1 = MAX(in1, /NaN)                           ; If the max1 keyword is NOT set, set it to the maximum of the data
  bins1 = FINDGEN( (max1 - min1) / bin1 + 1) * bin1 + min1                      ; Compute the bins to use in the histogram
ENDELSE

IF N_ELEMENTS(bin2) GT 2 THEN $                                                 ; Same as above block but for input 2
	bins2 = bin2 $
ELSE BEGIN
	IF N_ELEMENTS(bin2) EQ 0 THEN bin2 = 2
	IF N_ELEMENTS(MIN2) EQ 0 THEN min2 = MIN(in2, /NaN)
  IF N_ELEMENTS(MAX2) EQ 0 THEN max2 = MAX(in2, /NaN)
  bins2 = FINDGEN( (max2 - min2) / bin2 + 1) * bin2 + min2
ENDELSE

out = LONARR(N_ELEMENTS(bins1), N_ELEMENTS(bins2), /NoZero)                     ; Initialize the output array

hist2 = HISTOGRAM( VALUE_LOCATE(bins2, in2), $                                  ; Use histogram to bin up the second input
    MIN             = 0, $
    MAX             = N_ELEMENTS(bins2)-1, $
    BINSIZE         = 1, $
    REVERSE_INDICES = ri)
FOR j = 0, N_ELEMENTS(hist2)-1 DO BEGIN                                         ; Iterate over all bins of the second input
	IF hist2[j] EQ 0 THEN $                                                       ; If there are no data in the bin
		out[*,j] = 0 $                                                              ; Set all values in the bin to zero
	ELSE BEGIN                                                                    ; Else, there are data in the bin
		id = ri[ ri[j]:ri[j+1]-1 ]                                                  ; Get the indices of the data points in the bin
		hist1 = HISTOGRAM( VALUE_LOCATE(bins1, in1[id]), $                          ; Bin up data in the first input who's pairs in the second input fall in a give bin
			MIN             = 0, $
			MAX             = N_ELEMENTS(bins1)-1, $
			BINSIZE         = 1)
		FOR i = 0, N_ELEMENTS(hist1)-1 DO out[i,j] = hist1[i]                       ; Store the number of points in both the i and j bins
	ENDELSE
ENDFOR
RETURN, out                                                                     ; Return the histogram
END