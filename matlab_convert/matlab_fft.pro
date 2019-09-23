FUNCTION MATLAB_FFT, in_array, $
	nFFT      = nFFT,      $
	DIMENSION = dimension, $
	INVERSE   = inverse,   $
	DOUBLE    = double,    $
	_EXTRA    = extra 
;+
; Name:
;   MATLAB_FFT
; Purpose:
;   An IDL function to emulate the MATLAB fft function.
; Inputs:
;   in_array  : Data to transform
; Outputs:
;   Unnormalized FFT
; Keywords:
;   nFFT      : Length of the returned FFT
;   DIMENSION : Dimension over which to perform FFTs
;   INVERSE   : Set to perform inverse FFT
;   NORMALIZE : Set to normalize FFT by the number of points in transform
;   DOUBLE    : Set to force double precision FFT and return variable.
;   All other keywords accepted by the FFT Function.
; Author and History:
;   Kyle R. Wodzicki     Created 13 Apr. 2017
;
;     Modified 04 May 2017 by Kyle R. Wodzicki
;       Large overhaul to be able to handle arrays of up to eight (8) dimensions
;   		On arrays with many dimension, processing will be slow due to many for
;       loops.
; Notes:
;   Tabs set to 2
;-
COMPILE_OPT IDL2																																; Set compile options

info = SIZE(in_array)																														; Get information about the input array
dims = info[1:info[0]]																													; Get dimensions of the input array
id   = WHERE(dims GT 1, CNT)																										; Locate all dimensions greater than one
IF CNT EQ 0 THEN MESSAGE, 'No dimensions greater than one (1) element!'					; Print error message

IF N_ELEMENTS(dimension) EQ 0 THEN $																						; If dimension keyword is NOT set
	dimension = id[0]	$																														; Set dimension to first dimension with a size greater than one
ELSE IF dimension GT info[0] THEN BEGIN																					; Else, dimension keyword IS set and must check dimension not greater than number of dimensions in input array
	MESSAGE, 'Requested dimension larger than input array!'+STRING(10B)+$					; Print warning message
		'Using values across first dimension with size > 1!', /CONTINUE
	dimension = id[0]																															; Set dimension to first dimension with a size greater than one
ENDIF ELSE $
	dimension -= 1																																; Subtract one from dimension to get into zero-based index

;=== Check that the dimension of interest has more than one (1) element
IF dims[dimension] EQ 1 THEN BEGIN																							; If the number of elements in 'dimension' is one (1)
	MESSAGE, 'Dimension: ' + STRTRIM(dimension+1,2)+' is only one (1) element!'+$	; Print warning message
		STRING(10B)+'Using values across first dimension with size > 1!', /CONTINUE
	dimension = id[0]																															; Set dimension to first dimension with a size greater than one
ENDIF

;=== Transpose array so that first dimension is dimension of interest
IF dimension NE 0 THEN BEGIN																										; If dimension not zero, i.e., the first dimension
	reorder = INDGEN(info[0], /BYTE)																							; Generate dimension indices
	reorder[dimension] = 0																												; Set the dimension of interest to be the data in the first dimension
	reorder[0]         = dimension																								; Set the data in the first dimension to be dimension
	in_array = TRANSPOSE(in_array, reorder)																				; Reorder the data
	dims     = dims[reorder]																											; Reorder the dimension array
ENDIF

;=== Define 'array' to work on based on nFFT keyword
IF N_ELEMENTS(nFFT) EQ 0 THEN $																									; IF the nFFT keyword is NOT set
	array = in_array $																														; Write the input data into 'array'
ELSE BEGIN																																			; Else, do some stuff
	IF dims[0] GE nFFT THEN $																											; If the number of elements in the first dimension is greater than or equal to the nFFT size
		array = in_array[0:nFFT-1,*,*,*,*,*,*,*] $																	; Truncate the input array
	ELSE BEGIN																																		; Else, the input array must be padded
		new_dims    = dims																													; Create new dims array
		new_dims[0] = nFFT																													; Change the size of the dimension that the FFT is taken over to match that of nFFT
		array = MAKE_ARRAY(new_dims, TYPE = info[-2])																; Initialize array to write padded OR truncated input data to
		array[0:dims[0]-1,*,*,*,*,*,*,*] = in_array																	; If input data larger than nFFT, truncate, else append
		dims = TEMPORARY(new_dims)																									; Set dims to the new dims array
	ENDELSE
ENDELSE
IF KEYWORD_SET(inverse) THEN array = TEMPORARY(array) / FLOAT(dims[0])					; If the inverse transform is to be calculated, then normalize 'array'

;=== Set up variables for actual FFT computation
dims = SIZE(array, /DIMENSIONS)																									; Get new dimension of the data; input data may have been truncated or expanded
IF KEYWORD_SET(double) THEN info[-2] = 5																				; IF the double keyword is set, change the data type in the 'info' array to double
it_dims    = MAKE_ARRAY(8, VALUE = 1, TYPE = SIZE(dims, /TYPE))									; Make an 8-element array for iterating for the FFTs; populated with ones (1s) so that each FOR-loop below is entered at least once
it_dims[0] = dims																																; Write the dimension data into the it_dims array
out_array  = MAKE_ARRAY(dims, TYPE = info[-2] EQ 5 ? 9 : 6)											; Initialize output array as single- or double-precision complex based on type of input array

out_array  = FFT(array, DIMENSION = 1, INVERSE = inverse, _EXTRA = extra)
;
;;=== Iterate over all possible dimension
;FOR o = 0, it_dims[-1]-1 DO $																										; Eight   (8th) dimension
;	FOR n = 0, it_dims[-2]-1 DO $																									; Seventh (7th) dimension
;		FOR m = 0, it_dims[-3]-1 DO $																								; Sixth   (6th) dimension
;			FOR l = 0, it_dims[-4]-1 DO $																							; Fifth   (5th) dimension
;				FOR k = 0, it_dims[-5]-1 DO $																						; Fourth  (4th) dimension
;					FOR j = 0, it_dims[-6]-1 DO $																					; Third   (3rd) dimension
;						FOR i = 0, it_dims[-7]-1 DO $																				; Second  (2nd) dimension
;							out_array[0,i,j,k,l,m,n,o] = $																		; Compute FFT and write to the output array
;								FFT(array[*,i,j,k,l,m,n,o], $
;									DOUBLE=double, INVERSE=inverse,_EXTRA=extra)

IF N_ELEMENTS(reorder) NE 0 THEN BEGIN																					; If the reorder array exists
	in_array  = TRANSPOSE(in_array, reorder)																			; Place input data in original order
	out_array = TRANSPOSE(out_array, reorder)																			; Place output data in order of input data
ENDIF

dimension += 1																																	; Add one to dimension to place in one-based index

RETURN, out_array * dims[0]																											; Return unnormalized FFT

END