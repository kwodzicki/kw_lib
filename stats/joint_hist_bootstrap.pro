FUNCTION JOINT_HIST_BOOTSTRAP, inArray, sampleSize, bootstraps, $
  CONF_LEVEL = conf_level, $
  NORMALITY  = normality
;+
; Name:
;   ITCZ_PF_2D_BOOTSTRAP
; Purpose:
;   An IDL function to perform bootstrapping of 2D histogram to determine which
;   bins have anomalies that are significantly different from zero
; Inputs:
;   inArray    : 3D array of 2D histograms (third dimension is time) to sample from
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
IF N_ELEMENTS(bootstraps) EQ 0 THEN bootstraps = 10L^3                        ; Default number of resamples is 1000
IF N_ELEMENTS(conf_level) EQ 0 THEN conf_level = 0.95                         ; Default confidence level is 95 %
conf  = [0.0, 1.0] + [1.0, -1.0] * (1.0 - conf_level)/2.0                     ; Compute confidence levels
info  = SIZE(inArray)                                                         ; Get information about input
means = FLTARR( info[1], info[2], bootstraps, /NoZero )                       ; Create array for resample means
out   = FLTARR( 2,       info[2], info[1],    /NoZero )                       ; Array for confidence limits at requested level
FOR i = 0, bootstraps-1 DO BEGIN                                              ; Iterate 
  ids = ROUND(RANDOMU(seed, sampleSize) * info[3])                            ; Generate indices for random sampling of data
  bad = WHERE(ids EQ info[3], cnt)                                            ; Locate index values that are too large
  WHILE cnt GT 0 DO BEGIN                                                     ; While too large values exists
    ids[bad] = ROUND(RANDOMU(seed, cnt) * info[3])                            ; Replace values with new randomly generated values
    bad = WHERE(ids EQ info[3], cnt)                                          ; Check for any too large indices
  ENDWHILE                                                                    ; End WHILE
  means[0, 0, i] = MEAN(inArray[*,*,ids], DIMENSION=3, /NaN)                  ; Subset inArray using ids
ENDFOR                                                                        ; END i

normality = SHAPIRO(means, DIMENSION=3)                                       ; Check normality of bootstrapped distrbtions
means = TRANSPOSE(means)                                                      ; Transpose the array
FOR j = 0, info[1]-1 DO $
  FOR i = 0, info[2]-1 DO $
    out[0,i,j] = PERCENTILES( means[*,i,j], VALUE = conf )                    ; Compute confidence bounds

RETURN, TRANSPOSE(out)                                                        ; Transpose

END
