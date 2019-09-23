FUNCTION MATLAB_HISTC, x, binranges, DIMENSION = dimension, BIN = bin, L64 = l64
;+
; Name:
;   MATLAB_HISTC
; Purpose:
;   An IDL function that acts the same as the MATLAB histc function. Differences
;   between this function and the MATLAB equivalent arise for index numbering.
;   MATLAB is one (1) based whereas IDL is zero (0) based. Thus, bin=1 in MATLAB
;   is bin=0 in IDL. Where bin=0 in MATLAB, bin=-1 in this code.
;   https://www.mathworks.com/help/matlab/ref/histc.html?searchHighlight=histc&s_tid=doc_srchtitle#outputarg_ind
; Inputs:
;   x      : Data to bin
;   binranges : Left and right endpoints of bins
; Outputs:
;   Returns the number of points in a given bin in a given dimension.
; Keywords:
;   DIMENSION : Dimension along which to operate, specified as a scalar.
;   BIN       : Bin index numbers, returned as a vector or a matrix that is the same size as x.
;		L64				: Force result to be 64-bit unsigned integer instead of 32-bit
; Author and History:
;   Kyle R. Wodzicki     Created 23 Feb. 2017
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1																; Set dimension to one as default

info = SIZE(x)
dims = info[1:info[0]]

IF N_ELEMENTS(dims) EQ 1 AND dimension NE 1 THEN $															; If input array is only 1D AND the dimension keyword is NOT zero
  MESSAGE, 'Cannot set DIMENSION > 1 for 1D array!!!'														; Error message, stop program

bin     = VALUE_LOCATE(binranges, x)																						; Locate x values in binranges
bin_max = N_ELEMENTS(binranges)																									; Determine the maximum bin number
id      = WHERE(x GT binranges[-1], CNT)																				; Locate x values that are greater than the last entry in binranges
IF CNT GT 0 THEN BEGIN																													; IF values greater than the last entry in binranges are located
	MESSAGE, 'Values above top bin!', /CONTINUE																		; Print an error message if there are values above top bin
	bin[id]=-1																																		; Set the loc values for those x values to be negative one (-1), i.e., only values equal to the last entry of binranges will be considered
ENDIF																																						; ENDIF

trans_id = LINDGEN(info[0])																											; Generate indices for transposing of bins so that the first dimension is the dimension of interest
trans_id[dimension-1] = 0																												; Set transpose index for the dimension of interest to the zeroth dimension
trans_id[0] = dimension-1																												; Set transpose index for the zeroth dimension to the dimension of interest

dims = MAKE_ARRAY(8, VALUE=1UL)																									; Initialize dims array with 8 elements all equal to one (1)
dims[0] = (info[1:info[0]])[trans_id]																						; Set the dimensions to the new, transposed dimensions
dims[0] = bin_max																																; Set zeroth dimension to be size of bins

IF dimension NE 1 THEN bin = TRANSPOSE(bin, trans_id)														; If the dimension of interset is NOT the first (zeroth) dimension then transpose the bin array so that the dimension of interest is in the zeroth dimension
nn = MAKE_ARRAY(dims, TYPE=KEYWORD_SET(l64) ? 15 : 13)													; Create array to store the number of x-values in each bin over a given dimension of x

FOR o = 0, dims[-1]-1 DO $																											; Iterate over the eight dimension
	FOR n = 0, dims[-2]-1 DO $																										; Iterate over the seventh dimension
		FOR m = 0, dims[-3]-1 DO $																									; Iterate over the sixth dimension
			FOR l = 0, dims[-4]-1 DO $																								; Iterate over the fifth dimension
				FOR k = 0, dims[-5]-1 DO $																							; Iterate over the fourth dimension
					FOR j = 0, dims[-6]-1 DO $																						; Iterate over the third dimension
						FOR i = 0, dims[-7]-1 DO $																					; Iterate over the second dimension
							nn[0,i,j,k,l,m,n,o] = HISTOGRAM(bin[*,i,j,k,l,m,n,o], $
								MIN = 0, MAX = bin_max-1, BINSIZE = 1)

IF dimension NE 1 THEN BEGIN
	bin = TRANSPOSE(bin, trans_id)																								; Transpose bins back
	nn = TRANSPOSE( REFORM(nn), trans_id )																				; Transpose n back
ENDIF

RETURN, nn

END