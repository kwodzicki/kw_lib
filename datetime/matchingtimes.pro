FUNCTION MATCHINGTIMES, dates, check, COUNT=count, _EXTRA = extra
;+
; Name:
;   MATCHINGTIMES
; Purpose:
;   Function to get indices in dates that match check
; Inputs:
;   dates  : Array of dates to get indices for
;   check  : Array of dates to match in the dates array
; Keywords:
;   None.
; Returns:
;   Indices into the dates array where dates match those of the check array
;-

COMPILE_OPT IDL2

ids = LONARR( N_ELEMENTS(check), /NoZero )
FOR i = 0, N_ELEMENTS(check)-1 DO BEGIN
  id   = WHERE(SAMETIME(dates, check[i], _EXTRA=extra), cnt)
  IF cnt EQ 1 THEN ids[i] = id ELSE ids[i] = -1 
ENDFOR

id = WHERE(ids NE -1, count)
IF count GT 0 THEN RETURN, ids[id] ELSE RETURN, -1

END
