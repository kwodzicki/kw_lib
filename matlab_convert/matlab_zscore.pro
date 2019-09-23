FUNCTION MATLAB_ZSCORE, x, FLAG = flag, DIMENSION = dimension, $
	UNSCORE = unscore
;+
; Name:
;   MATLAB_ZSCORE
; Purpose:
;   A function to emulate the MATLAB zscore function.
; Inputs:
;   x : Array of values to zscore.
; Outputs:
;   Array of zscores.
; Keywords:
;   FLAG      : Scales X using the standard deviation indicated by flag.
;               If flag is 0 (default), then zscore scales X using the sample 
;               standard deviation, with n - 1 in the denominator of the
;               standard deviation formula. zscore(X,FLAG=0) is the same as 
;               zscore(X). If flag is 1, then zscore scales X using the
;               population standard deviation, with n in the denominator of
;               standard deviation formula.
;   DIMENSION : Standardizes X along dimension DIMENSION
;   UNSCORE   : Set to a named variable to return a list who's first element
;               is to be multiplied by the zscore and the second is to be added
;               to obtain the raw data
; Author and History:
;   Kyle R. Wodzicki     Created 07 May 2017
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1B																; Set default dimension to columns
IF N_ELEMENTS(flag)      EQ 0 THEN flag      = 0B																; Set default flag to zero

dims   = SIZE(x, /DIMENSION)																										; Get dimensions of x
dims1  = dims & dims1[dimension-1] = 1																					; Set up dimension sizes for reforms
x_mean = REBIN(REFORM(MEAN(x, DIMENSION=dimension, /NaN), dims1), dims)					; Compute mean over dimension of interest and rebin to original size
dMean  = x - x_mean																															; Subtract mean from the input data

;=== Compute standard deviation based on flag value
n = flag EQ 0 ? dims[dimension-1]-1 : dims[dimension-1]
S = REBIN(REFORM(SQRT( TOTAL( (dMean)^2, dimension ) / n ), dims1), dims)

unscore = LIST(S, x_mean)																												; List with standard deviation and mean

RETURN, dMean / S																																; Return the zscore

END