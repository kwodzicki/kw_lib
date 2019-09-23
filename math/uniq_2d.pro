FUNCTION UNIQ_2D, im1, im2
;+
; NAME:
;   UNIQ_2D
;
; PURPOSE:
;   A function to compute indices for unique pairs of data
;
; CALLING SEQUENCE:
;   Result = UNIQUE_2D(V1, V2)
; INPUTS:
;   V1 and V2 = arrays containing the variables.  May be any non-complex
;       numeric type.
;
; OUTPUTS:
;   Indices for unique pairs of data
;
; RESTRICTIONS:
;   Not usable with complex or string data.
;
; Author and History:
;   Kyle R. Wodzicki     Created 05 July 2016
;
; Adapted from HIST_2D, and by adapted I mean this function uses all the same
; code, except it runs UNIQ instead of HISTOGRAM at the end. Extra varaibles
; were removed
;-
    COMPILE_OPT idl2
    ON_ERROR, 2

    ;Find extents of arrays.
    im1max = MAX(im1, MIN=im1min)
    im2max = MAX(im2, MIN=im2min)

    ;Supply default values for keywords.
    min1 = (0 < im1min)
    max1 = im1max
    min2 = (0 < im2min)
    max2 = im2max

    ;Get # of bins for each
    im1bins = FLOOR(max1-min1) + 1L
    im2bins = FLOOR(max2-min2) + 1L

    noMinTruncation = (min1 EQ im1min) AND (min2 EQ im2min)
    noMaxTruncation = (im1max LE max1) AND (im2max LE max2)

    ; Combine im1 and im2 into a single array.
    ; Use im2 values as the "row" indices, use im1 values as the "columns".
		im1tmp = im1
		im2tmp = im2

		; Only do the data conversions that are necessary.
		IF (min1 NE 0) THEN im1tmp = TEMPORARY(im1tmp) - min1
		IF (min2 NE 0) THEN im2tmp = TEMPORARY(im2tmp) - min2
		h = im1bins*LONG(TEMPORARY(im2tmp)) + LONG(TEMPORARY(im1tmp))

		; Construct an array of out-of-range (0) and in-range (1) values.
		in_range = 1
		IF (noMinTruncation EQ 0) THEN $ ; set lt min to zero
				in_range = (im1 ge min1) AND (im2 GE min2)
		IF (noMaxTruncation EQ 0) THEN $ ; set gt max to zero
				in_range = TEMPORARY(in_range) AND (im1 LE max1) AND (im2 LE max2)
		; Set values that are out of range to -1
		h = (TEMPORARY(h) + 1L)*TEMPORARY(in_range) - 1L

    RETURN, UNIQ(h)
END
