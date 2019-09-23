FUNCTION NEAREST_NEIGHBOR_INTERPOL, source_x, source_y, dest_x, dest_y
;+
; Name:
;   NEAREST_NEIGHBOR_INTERPOL
; Purpose:
;   A function to return column and row indices for regridding a 
;   dataset using nearest neighbor interpolation.
; Inputs:
;   source_x   : Longitude values you are interpolating from
;   source_y   : Latitude values you are interpolating from
;   dest_x     : Longitude values you are interpolating to
;   dest_y     : Latitude values you are interpolating to
; Outputs:
;   Returns a structure with column and row indices for interpolating. These
;   indices are used to index the destination variables.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 04 Apr. 2016
;-
COMPILE_OPT IDL2

IF N_PARAMS() NE 4 THEN MESSAGE, 'Incorrect number of inputs!!!'

source_dims = [N_ELEMENTS(source_x), N_ELEMENTS(source_y)]
dest_dims   = [N_ELEMENTS(dest_x),   N_ELEMENTS(dest_y)]

xx1  = REBIN(source_x, source_dims[0], dest_dims[0])                            ; Rebin source longitude to [nSource, nDest]
xx2  = REBIN(REFORM(dest_x, 1, dest_dims[0]), source_dims[0], dest_dims[0])     ; Rebin dest longitude to [nSource, nDest]
tmp  = MIN(xx1-xx2, x_id, DIMENSION=2, /ABSOLUTE, /NaN)                         ; Compute minimum over first dimension and get indices
x_id = TEMPORARY(x_id) / source_dims[0]

yy1  = REBIN(source_y, source_dims[1], dest_dims[1])                            ; Rebin source longitude to [nSource, nDest]
yy2  = REBIN(REFORM(dest_y, 1, dest_dims[1]), source_dims[1], dest_dims[1])     ; Rebin dest longitude to [nSource, nDest]
tmp  = MIN(yy1-yy2, y_id, DIMENSION=2, /ABSOLUTE, /NaN)                         ; Compute minimum over first dimension and get indices
y_id = TEMPORARY(y_id) / source_dims[1]

IF N_ELEMENTS(x_id) EQ N_ELEMENTS(y_id) THEN BEGIN                              ; If the x- and y-indices are the same size
	ids = []                                                                      ; Initialize array
	FOR i = 0, N_ELEMENTS(x_id) - 1 DO BEGIN                                      ; Iterate over all indices
		IF x_id[i] EQ -1 THEN CONTINUE                                              ; If the x-index at subscript i is -1, then skip
		id = WHERE(x_id EQ x_id[i] AND y_id EQ y_id[i], CNT)                        ; Find all pairs that match the x_id[i], y_id[i] pair
		IF CNT GT 0 THEN BEGIN
		  ids = [ids, id[0]]                                                        ; If at least one pair found, save the first index
	    x_id[id] = -1                                                             ; Set all indices for that pair to -1
		ENDIF
	ENDFOR
	x_id = x_id[ids]
	y_id = y_id[ids]
ENDIF

RETURN, {x : x_id, y : y_id}

END