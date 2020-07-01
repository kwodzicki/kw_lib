PRO NCDF_COPYVARATTS, srcID, dstID, varName, atts
;+
; Name:
;   NCDF_COPYVARATTS
; Purpose:
;   Procedure to copy some/all attributes for a given variable from
;   one netCDF file to another
; Inputs:
;   srcID   : The netCDF ID of the file to copy data from;
;               Returned from a previous call to NCDF_OPEN, NCDF_CREATE, or NCDF_GROUPDEF.
;   dstID   : The netCDF ID of the file to copy data to;
;               Returned from a previous call to NCDF_OPEN, NCDF_CREATE, or NCDF_GROUPDEF.
;   varName : String name of the variable to copy data from/to
;   atts    : (Optional) String array containing names of attributes to copy.
;              If none input, all attributes are copied
; Keywords:
;   None.
; Outputs:
;   None.
;-
COMPILE_OPT IDL2

IF N_PARAMS() LT 3 THEN MESSAGE, 'Incorrect number of inputs'									; If less than 3 input arguments, throw error

IF N_ELEMENTS(atts) EQ 0 THEN BEGIN																						; If no atts input
  varInfo = NCDF_VARINQ(srcID, varName)																				; Get information about variable
  atts    = STRARR( varInfo.NATTS )																						; Create string array for number attribute names
  FOR i = 0, varInfo.NATTS-1 DO $																							; Iterate over all variable attributes
    atts[i] = NCDF_ATTNAME(srcID, varName, i)																	; Get attibute name
ENDIF

FOREACH att, atts DO $																												; Iterate over all attributes
  id = NCDF_ATTCOPY(srcID, varName, att, dstID, varName)											; Copy the attributes

END
