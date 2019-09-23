FUNCTION COMPUTE_SCALE_OFFSET, data, n, $
	N_MISSING = n_missing, $
	DOUBLE    = double, $
	ADD_FIRST = add_first
;+
; Name:
;   COMPUTE_SCALE_OFFSET
; Purpose:
;   An IDL function for computing scale factor and add offset for scaling data
;   into a netCDF, or any other, file.
; Inputs:
;   data   : The data array to be scaled
;   n      : The number of bits to scale to
; Outputs:
;   Returns a two element array where the first element is the scale factor
;   and the second the add offset.
; Keywords:
;   N_MISSING : Set to the number of values to reserve for missing/fill data. 
;                Values are reserved starting at minimum values and working up, 
;                i.e., for 16-bit scaling and one missing, -32768 is reserved.
;  DOUBLE     : Set to force scale and add values computed in double precision.
;                Default is single precision, unless the input data is double
;                precision, then scale and add values are double precision.
;  ADD_FIRST  : Set for scaling where add_offset is subtraced from data
;                before scale is applied; MODIS convention.
;                By default, to scale the data you use:
;                    scaled = (raw - add) / scale
;                and to get back to raw:
;                    raw = (scaled * scale) + add
;
;                When the ADD_FIRST key is used:
;                    scaled = (raw/scale) + add
;                and to get back to raw:
;                    raw = (scaled -add) * scale
; Author and History:
;   Kyle R. Wodzicki     Created 30 Jun. 2017
;-
COMPILE_OPT IDL2
data_min = MIN(data, MAX = data_max, /NaN)                                      ; Compute min and max of the data
IF NOT FINITE(data_min) OR NOT FINITE(data_max) THEN $                          ; If the min or max is NOT finite, then message
  MESSAGE, 'No finite minimum OR maximum!!!'

IF N_ELEMENTS(n_missing) EQ 0 THEN n_missing = 0                                ; Set default value for n_missing to zero

type = KEYWORD_SET(double) ? 5 : 4                                              ; Set the value of type based on the double keyword
IF SIZE(data, /TYPE) EQ 5 THEN type = 5                                         ; Override the type if the input data is double precision

scale = DOUBLE(data_max - data_min) / FIX(2LL^n - (n_missing+1), TYPE = type)   ; Compute the scale factor
IF KEYWORD_SET(add_first) THEN $
  add   = -( data_min / scale + (2LL^(n-1)-n_missing) ) $                       ; Compute the add offset
ELSE $
  add   = data_min + (2LL^(n-1)-n_missing) * scale                              ; Compute the add offset

IF KEYWORD_SET(double) THEN $
  RETURN, [scale, add] $                                                           ; Return the data
ELSE $
  RETURN, FLOAT([scale, add])

END