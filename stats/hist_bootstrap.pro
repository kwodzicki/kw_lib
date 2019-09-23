FUNCTION ITCZ_PF_1D_BOOTSTRAP, inArray, sampleSize, bootstraps, $
  CONF_LEVEL = conf_level
;+
; Name:
;   ITCZ_PF_1D_BOOTSTRAP
; Purpose:
;   An IDL function to perform bootstrapping of 2D histogram to determine which
;   bins have anomalies that are significantly different from zero
; Inputs:
;   inArray    : 2D array of 1D histograms (second dimension is time) to sample from
;   sampleSize : Size of the sample to take during each bootstrap
;   bootstraps : Number of times to sample from the data; Default is 1000
; Outputs:
;   Returns 2D array
; Keywords:
;   CONF_LEVEL  : Sets the alpha level for confidence interval; must be fraction.
;                   Default is 0.95
; Author and History:
;   Kyle R. Wodzicki
;-
COMPILE_OPT IDL2

IF N_PARAMS() LT 2 THEN MESSAGE, 'Incorrect number of inputs!'
IF N_ELEMENTS(bootstraps) EQ 0 THEN bootstraps = 10^3
IF N_ELEMENTS(conf_level) EQ 0 THEN conf_level = 0.95
conf  = [0.0, 1.0] + [1.0, -1.0] * (1.0 - conf_level)/2.0
info  = SIZE(inArray)
means = FLTARR( info[1], bootstraps, /NoZero )
out   = FLTARR( 2,       info[1],    /NoZero )
FOR i = 0, bootstraps-1 DO BEGIN
  ids = ROUND(RANDOMU(seed, sampleSize) * info[2])					; Generate indices for random sampling of data
  bad = WHERE(ids EQ info[2], cnt)						; Locate index values that are too large
  WHILE cnt GT 0 DO BEGIN							; While too large values exists
    ids[bad] = ROUND(RANDOMU(seed, cnt) * info[2])				; Replace values with new randomly generated values
    bad = WHERE(ids EQ info[2], cnt)						; Check for any too large indices
  ENDWHILE
  means[0, i] = MEAN(inArray[*,ids], DIMENSION=2, /NaN)			; Subset inArray using ids
ENDFOR

means = TRANSPOSE(means)
FOR i = 0, info[1]-1 DO $
    out[0,i] = PERCENTILES( means[*,i], VALUE = conf )     

RETURN, TRANSPOSE(out)

END
