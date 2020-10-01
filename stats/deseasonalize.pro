FUNCTION DESEASONALIZE, months, data, $
  JULIAN    = julian,    $
  GREGORIAN = gregorian, $
  PERCENT   = percent,   $
  DIMENSION = dimension, $
  WEIGHTED_NAN = weighted_nan, $
  NaN       = nan
;+
; Name:
;   DESEASONALIZE
; Purpose:
;   IDL Function to deseasonalize a variable given months
; Inputs:
;   months : Array of month numbers (1-12) or julian days matching data
;   data   : Array of data to deseasonalize; one of the dimensions MUST match
;             size of mm
; Keywords:
;   JULIAN    : Set if the data in mm are IDL JULDAY format, uses CALDAT
;   GREGORIAN : Set if should use JUL2GREG.
;   PERCENT   : Set to return anomalies in percent form
;   DIMENSION : Specify the dimension overwhich to compute anomalies, default is first dimension
;   WEIGHTED_NAN : Unlike the nan keyword, this excludes nans but still weights for the number of pionts.
;                   so, say have array [1, NaN, 3], using just nan gives mean of (1+3)/2 = 2. With this
;                   keyword, you get (1+3)/3 = 4/3.
;   NaN       : Set to exclude NaN values from means.
; Outputs:
;   Returns array of anomalies of same type and shape as data input
;-
COMPILE_OPT IDL2																															; Set compile options

IF N_PARAMS() NE 2 THEN MESSAGE, 'Incorrect number of inputs'									; Check inputs
IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1

IF KEYWORD_SET(julian) THEN $																									; If julian set
  CALDAT, months, mm $																												; Get months
ELSE IF KEYWORD_SET(gregorian) THEN $																					; If gregorian set
  JUL2GREG, months, mm $																											; Get months
ELSE $																																				; Else
  mm = months																																	; Get months

IF dimension NE 1 THEN BEGIN																									; If dimension keyword set
  dimOrd = INDGEN( SIZE(data, /N_DIMENSION) )																	; Array of dimension indices
  id     = WHERE( dimOrd NE (dimension-1), cnt )															; Locate all dimension that are NOT the one requested
  IF cnt EQ 0 THEN MESSAGE, 'Dimension not compatible'												; Error
  dimOrd = [dimension-1, id]																									; Create new dimension order
  anoms  = TRANSPOSE(data, dimOrd)																						; Transpose to new order
ENDIF ELSE $
  anoms = data																																; Just use data as is

dims    = SIZE(anoms)																													; Get information
dims[1] = 1																																		; Set first dimension length to one (1); this makes reform a little easier
FOR i = 1, 12 DO BEGIN																												; Iterate over 12 months
  id = WHERE(mm EQ i, cnt)																										; Locate all data in month
  IF cnt GT 0 THEN BEGIN																											; If located data
    IF KEYWORD_SET(weighted_nan) THEN $
      tmpAVG = TOTAL(anoms[id,*,*,*,*,*,*,*], 1, /NaN) / cnt $
    ELSE $
      tmpAVG = MEAN(anoms[id,*,*,*,*,*,*,*], NaN = nan, DIMENSION = 1)					; Compute average
    IF dims[0] GT 1 THEN $																										; If more than one dimension
      tmpAVG = REBIN(REFORM(tmpAVG, dims[1:dims[0]]), [cnt,dims[2:dims[0]]])	; Rebin to match original size
    anoms[id,*,*,*,*,*,*,*] -= tmpAVG																					; Compute anomalies
    IF KEYWORD_SET(percent) THEN $																						; If want percent
      anoms[id,*,*,*,*,*,*,*] *= (100.0 / tmpAVG)															; Multiply by 100.0 / average to get percent
  ENDIF
ENDFOR

IF dimension NE 1 THEN $																					; If dimension set
  RETURN, TRANSPOSE(anoms, SORT(dimOrd)) $																		; Return data in same order as input
ELSE $																																				; Else
  RETURN, anoms																																; Just return

END
