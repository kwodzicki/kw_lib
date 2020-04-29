FUNCTION KW_HISTOGRAM, in_data, $
  MIN             = in_min, $
  MAX             = in_max, $
  BINSIZE         = in_bin, $
  REVERSE_INDICES = ri,     $
  OUT_OF_BOUND    = out_of_bound
;+
; Name:
;   KW_HISTOGRAM
; Purpose:
;   A function to add the ability to create a histogram with
;   an odd bin size.
; Inputs:
;   in_data   : The data to create the histogram of.
; Outputs:
;   Returns an array containing the number of data points in each bin.
; Keywords:
;   MIN             : Minimum for the histogram binning.
;   MAX             : Maximum for the histogram binning.
;   BIN             : Bin size(s) for the histogram. If there is more than
;                      one (1) value in this keyword, then assumes it contains
;                      boundaries for all bins.
;   REVERSE_INDICES : Set to named variable to return the reverse indices to.
;   OUT_OF_BOUND    : Set to named varaible to return boolean of whether
;                      out-of-bound data are include in histogram.
; Author and History:
;   Kyle R. Wodzicki     Created 11 Jan. 2016
;-

COMPILE_OPT IDL2

out_of_bound = N_ELEMENTS(in_bin) GT 1
IF out_of_bound THEN $
  RETURN, HISTOGRAM( VALUE_LOCATE(in_bin, in_data), $
    MIN             = -1, $
    MAX             = N_ELEMENTS(in_bin)-1, $
    BINSIZE         = 1, $
    REVERSE_INDICES = ri) $
ELSE $
  RETURN, HISTOGRAM(in_data,  $
    MIN             = in_min, $
    MAX             = in_max, $
    BINSIZE         = in_bin, $
    REVERSE_INDICES = ri)
END
