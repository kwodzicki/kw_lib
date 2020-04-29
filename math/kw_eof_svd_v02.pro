FUNCTION KW_EOF_SVD_V02, inArray, $
	EIGENVECTORS = eigenvectors, $
	EIGENVALUES  = eigenvalues,  $
	VARIANCE     = variance,     $
	NVARIABLES   = nvariables,   $
	DOUBLE       = double
;+
; Name:
;   KW_EOF_SVD_V02
; Purpose:
;   An IDL function to compute Empirical Orthogonal Functions using the 
;   singular value decomposition.
; Inputs:
;   inArray : An n x m matrix where the rows m are locations and the columns n
;              are observations (in time).
; Outputs:
;   Time series of each mode a_t(t). a_t(t) has same dimensions as input,
;   with the first dimension being time and the second being mode. For example
;   a_t[*,0] is the time series that corresponds to the first mode.
; Keywords:
;   EIGENVECTORS : Set to a named variable to return then Eigenvectors to.
;                   Columns correspond to the mode,
;                   Rows contain amplitudes
;   EIGENVALUES  : Set to a named variable to return then Eigenvalues to.
;   VARIANCE     : Set to a named variable to return the percent of variance in
;                   each mode to.
;   NVARIABLES   : Use this keyword to specify the number of derived variables.
;                  A value of zero, negative values, and values in excess of
;                  the input array's column dimension result in a complete set
;                  (M-columns and N-rows) of derived variables.
;   DOUBLE       : Set this keyword to perform calculations in double precision.
; Author and History:
;   Kyle R. Wodzicki     Created 24 Apr. 2016
;
;     MODIFIED 08 May 2017
;       Added a transpose of the Eigenvectors so that the raw data can be
;       recovered thought the equation a_t # eigenvectors.
;     MODIFIED 03 Aug 2018
;       Trying to figure out how EOF works again, first dimension must always
;       be time with second being space
;-
COMPILE_OPT IDL2

dims = SIZE(inArray, /DIMENSION)																								; Get dimensions of input array
IF N_ELEMENTS(double) EQ 0 THEN double = SIZE(array, /TYPE) EQ 5								; Set the double keyword
array = KEYWORD_SET(double) ? DOUBLE(inArray) : FLOAT(inArray)									; Set type of input array based on double keyword
type  = KEYWORD_SET(double) ? 5 : 4

nvariables = N_ELEMENTS(nVariables) eq 0 ? dims[1] : LONG(nVariables)					  ; Set number of variables to return

;matrix = (1/dims[0]-1) * (Double(array) ## Transpose(array))
matrix = (Transpose(array) ## Double(array)) / (dims[0]-1) 

LA_SVD, matrix, S, U, V, DOUBLE=double																						; Perform singular value decomposition

eigenvalues  = MAKE_ARRAY(dims[1],          TYPE = type, /NoZero)								; Initialize eigenvalaues array
eigenvectors = MAKE_ARRAY(dims[1], dims[1], TYPE = type, /NoZero)								; Initialize eigenvectors array
a_t          = MAKE_ARRAY(dims[0], dims[1], TYPE = type, /NoZero)								; Initialize a_t array
nn = dims[0] GT dims[1] ? dims[1] : dims[0]
U            = TRANSPOSE(U)

STOP
FOR i = 0, nn-1 DO BEGIN																										; Iterate over first dimension
;	temp_var          = MATRIX_MULTIPLY(array, U[*,i], /ATRANSPOSE)       ; Compute input array times u
	temp_var          = REFORM(MATRIX_MULTIPLY(U[*,i], array) )       ; Compute input array times u
  temp_var         /= SQRT(TOTAL(temp_var*temp_var, DOUBLE=double))
	eigenvectors[0,i] = temp_var
	a_t[0,i]          = MATRIX_MULTIPLY(array, temp_var)		              ; Compute a_t
;	eigenvalues[i]    = CORRELATE(a_t[*,i], a_t[*,i], /COVARIANCE, DOUBLE=double)	; Compute eigenvalues
ENDFOR

;eigenvectors = TRANSPOSE(eigenvectors)																					; Transpose the eigenvectors
;variance     = EIGENVALUES / TOTAL(EIGENVALUES, DOUBLE=double)									; Compute variance
variance     = S / TOTAL(S, DOUBLE=double)									; Compute variance

;=== Return the data
IF nVariables GE dims[1] OR nVariables LE 0 THEN $
	RETURN, a_t $
ELSE $
  RETURN, a_t[*,0:nVariables-1]
END
