PRO NCDF_COPYGLOBALATTS, srcID, dstID, atts
;+
; Name:
;   NCDF_COPYGLOBALATTS
; Purpose:
;   Procedure to copy some/all global attributes from one netCDF file to another
; Inputs:
;   srcID   : The netCDF ID of the file to copy data from;
;               Returned from a previous call to NCDF_OPEN, NCDF_CREATE, or NCDF_GROUPDEF.
;   dstID   : The netCDF ID of the file to copy data to;
;               Returned from a previous call to NCDF_OPEN, NCDF_CREATE, or NCDF_GROUPDEF.
;   atts    : (Optional) String array containing names of attributes to copy.
;              If none input, all attributes are copied
; Keywords:
;   None.
; Outputs:
;   None.
;-
COMPILE_OPT IDL2

IF N_PARAMS() LT 2 THEN MESSAGE, 'Incorrect number of inputs'									; If less than 2 input arguments, throw error

IF N_ELEMENTS(atts) EQ 0 THEN BEGIN																						; If no atts input
  info = NCDF_INQUIRE(srcID)																									; Get information about variable
  atts = STRARR( info.NGATTS )																								; Create string array for number attribute names
  FOR i = 0, info.NGATTS-1 DO $																								; Iterate over all variable attributes
    atts[i] = NCDF_ATTNAME(srcID, i, /GLOBAL)																	; Get attibute name
ENDIF

FOREACH att, atts DO $																												; Iterate over all attributes
  id = NCDF_ATTCOPY(srcID, att, dstID, /IN_GLOBAL, /OUT_GLOBAL)								; Copy the attributes

END
