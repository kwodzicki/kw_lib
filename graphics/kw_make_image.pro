FUNCTION KW_MAKE_IMAGE, z, levels

;+
; Name:
;   KW_MAKE_IMAGE
; Purpose:
;   A function to create a byte scaled image based on input data to plot
;   and levels. If not levels are specified, 256 equally spaced values 
;   will be used that encompass all the data.
; Inputs:
;   z      : 2D array of values to create image for
;   levels : Array of levels to use when creating the image
; Outputs:
;   Returns a 2D byte scaled array image.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 30 Aug 2016
; Dependencies
;   KW_HISTOGRAM
;-
COMPILE_OPT IDL2

IF N_PARAMS() EQ 0 THEN MESSAGE, 'Incorrect number of inputs!'

nLevels = N_ELEMENTS(levels)
zMin    = MIN(z, MAX=zMax, /NaN)
IF nLevels EQ 0 THEN BEGIN
  nLevels = 256
  levels  = FINDGEN(nLevels) * ( (zMax+1.0E-3 - zMin) / (nLevels-1)) + zMin
ENDIF ELSE BEGIN
  IF MIN(levels) GT zMin THEN levels = [zMin, levels]
  IF MAX(levels) LT zMax THEN levels = [levels, zMax+1.0E-3]
  nLevels = N_ELEMENTS(levels)
ENDELSE

c_colors = BYTSCL( INDGEN(nLevels-1) )
hist  = KW_HISTOGRAM(z, BIN=levels, REVERSE_INDICES=ri)                         ; Use KW_HISTOGRAM to bin the data into contour levels and get the reverse indices
zSize = SIZE(z, /DIMENSIONS)                                                    ; Get the size of the data to contour
image = LONARR(zSize)                                                           ; Initialize array to store 24-bit color values for each data point in
FOR i = 1, N_ELEMENTS(hist)-2 DO $                                              ; Iterate over all histogram bins
	IF (hist[i] GT 0) THEN $                                                      ; IF there are data points in the ith bin, then 'color' those points with the ith color
		image[ ri[ri[i]:ri[i+1]-1] ] = c_colors[i-1]

RETURN, image
END