FUNCTION KW_RUN_MEAN, vals, width, FILL = fill
;+
; Name:
;   KW_RUN_MEAN
; Purpose:
;   A function to compute a running mean of an array using a specified width.
; Inputs:
;   vals  : Array to compute running mean of
;   width : Optional input of width to use. MUST BE ODD. Default is 3.
; Outputs:
;   Returns and array of running means. Padding at front an back with
;   NaN characters, i.e., first width/2 and last width/2 points.
; Keywords:
;   FILL    : Set to value to fill with. Default is NaN.
; Author and History:
;   Kyle R. Wodzicki     Created 15 Apr. 2016
;     Modified 02 May 2017 by K.R.W.
;       Add the fill keyword
;-
  COMPILE_OPT IDL2
  IF N_ELEMENTS(fill) EQ 0 THEN fill = !Values.F_NaN
  IF (N_ELEMENTS(width) EQ 0) THEN width = 3
  half_width = width/2
  nVals = N_ELEMENTS(vals)
  out = MAKE_ARRAY(nVals, VALUE=fill, TYPE = SIZE(vals, /TYPE))
  FOR i = half_width, nVals-1-half_width DO $
    out[i] = MEAN(vals[i-half_width:i+half_width], /NaN)
  RETURN, out
END