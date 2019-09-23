FUNCTION KW_EOF_SCAT_MAT, inArray, $
	EIGENVECTORS = eigenvectors, $
	EIGENVALUES  = eigenvalues,  $
	VARIANCE     = variance,     $
	NVARIABLES   = nvariables,   $
	DOUBLE       = double
;+
; Name:
;   KW_EOF
; Purpose:
;   An IDL function to compute Empirical Orthogonal Functions using the 
;   scatter matrix approach.
; Inputs:
;   inArray : An n x m matrix where the rows m are locations and the columns n
;              are observations (in time).
; Outputs:
;   Time series of each mode a_t(t).
; Keywords:
;   EIGENVECTORS : Set to a named variable to return then Eigenvectors to.
;   EIGENVALUES  : Set to a named variable to return then Eigenvalues to.
;   VARIANCE     : Set to a named variable to return the percent of variance in
;                   each mode to.
;   NVARIABLES   : Use this keyword to specify the number of derived variables.
;                  A value of zero, negative values, and values in excess of
;                  the input array's column dimension result in a complete set
;                  (M-columns and N-rows) of derived variables.
;   DOUBLE       : Set this keyword to perform calculations in double precision.
; Author and History:
;   Kyle R. Wodzicki     Created 21 Apr. 2016
;
;     MODIFIED 08 May 2017
;       Added a transpose of the Eigenvectors so that the raw data can be
;       recovered thought the equation a_t # eigenvectors.
;-
COMPILE_OPT IDL2

info = SIZE(inArray)
IF info[0] NE 2 THEN MESSAGE, 'Input array must be two-dimensional!'
IF N_ELEMENTS(double) EQ 0 THEN double = info[info[0]+1] EQ 5
nvariables = KEYWORD_SET(nVariables) eq 0 ? info[1] : LONG(nVariables)					; Set number of variables to return

array = KEYWORD_SET(double) ? DOUBLE(inArray) : FLOAT(inArray)									; Set type of input array based on double keyword

C = MATRIX_MULTIPLY(array, array, /ATRANSPOSE) / (info[1]-1)										; EOF decomposition in terms of m x m 'spatial' covariance matrix
eigenvalues = EIGENQL(C, EIGENVECTORS=eigenvectors, DOUBLE=double)							; Eigen value is gamma, Eigen vector is phi
id = WHERE(ABS(eigenvalues) LE (machar(DOUBLE=double)).EPS, cnt)								; Locate any values less than machine epsilon
IF CNT NE 0 THEN eigenvalues[id] = 0.0																					; Set values less than machine epsilon to zero
;variance  =  eigenvalues / info[2]																							; Compute variance in each mode
variance  =  eigenvalues / TOTAL(eigenvalues)																		; Compute variance in each mode

a_t  = MATRIX_MULTIPLY(array, eigenvectors)																			; Compute time series for each mode
eigenvectors = TRANSPOSE(eigenvectors)

;=== Return the data
IF nVariables GE info[1] OR nVariables LE 0 THEN $
	RETURN, a_t $
ELSE $
  RETURN, a_t[*,0:nVariables-1]

END