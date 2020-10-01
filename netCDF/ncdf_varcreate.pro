FUNCTION NCDF_VARCREATE, Cdfid, Name, dim, $
  TYPE    = type, $
  NO_FILL = no_fill, $
  _EXTRA  = _extra
;+
; Name:
;   NCDF_VARCREATE
; Purpose:
;   Wrapper function for NCDF_VARDEF that makes setting the type easier
; Inputs:
;   Cdfid : The NetCDF ID, returned from a previous call to NCDF_OPEN, NCDF_CREATE, or NCDF_GROUPDEF.
;   Name  : A scalar string containing the variable name
;   dim   : An optional vector containing the dimension IDs corresponding to the variable dimensions. 
;           If the ID of the unlimited dimension is included, it must be the right most element in the array. 
;           If Dim is omitted, the variable is assumed to be a scalar.
;           This can be list of strings specifing dimension names as well.
; Keywords:
;   TYPE    : IDL data type code or type string for netCDF variable type.
;   NO_FILL : Set to disable default filling
;   _EXTRA  : All other keywords (except data type keys) accepted by NCDF_VARDEF
; Returns:
;   Same as NCDF_VARDEF
;-

COMPILE_OPT IDL2

IF N_ELEMENTS(dim) NE 0 THEN BEGIN																						; If the dim input is NOT empty
  IF ISA(dim, 'STRING') THEN BEGIN																						; If input is string type, then we must find dimension ids
    dimIDs = LONARR(N_ELEMENTS(dim))																					; Create long array for ids
    FOR i = 0, N_ELEMENTS(dim)-1 DO BEGIN																			; Iterate over dimension names
      dimID = NCDF_DIMID(Cdfid, dim[i])																				; Get dimension id
      IF dimID EQ -1 THEN MESSAGE, 'No dimension found with name : ' + dim[i]	; If it is -1, throw error
      dimIDs[i] = dimID																												; Place dimID in dimIDs array 
    ENDFOR
  ENDIF ELSE $																																; Else
    dimIDs = dim																															; Set dimIDs to dim
ENDIF

varType = (N_ELEMENTS(type) EQ 0) ? 4 : type																	; If no type input, then set to 4
IF ISA(varType, 'STRING') THEN $																							; If varType is string
  CASE STRUPCASE(varType) OF																									; Convert string to corresponding TYPECODE
    'BYTE'    : varType =  1
    'INT'     : varType =  2
    'UINT'    : varType = 12
    'LONG'    : varType =  3
    'ULONG'   : varType = 13
    'ULONG64' : varType = 15
    'FLOAT'   : varType =  4
    'DOUBLE'  : varType =  5
  ENDCASE

vid = NCDF_VARDEF(Cdfid, Name, dimIDs, _EXTRA = _extra, $										; Create the variable in the netCDF file and return the ID
  UBYTE  = varType EQ  1, $
  SHORT  = varType EQ  2, $
  USHORT = varType EQ 12, $
  LONG   = varType EQ  3, $
  ULONG  = varType EQ 13, $
  UINT64 = varType EQ 15, $
  FLOAT  = varType EQ  4, $
  DOUBLE = varType EQ  5, $
  STRING = varType EQ  8) 

IF ~KEYWORD_SET(no_fill) THEN BEGIN
  CASE varType OF
     1   : fill = !NCDF_FILL.BYTE
     2   : fill = !NCDF_FILL.SHORT
     3   : fill = !NCDF_FILL.LONG
    13   : fill = !NCDF_FILL.ULONG
     4   : fill = !NCDF_FILL.FLOAT
     5   : fill = !NCDF_FILL.DOUBLE
    ELSE : fill = !NULL
  ENDCASE
  IF N_ELEMENTS(fill) EQ 1 THEN $
    NCDF_ATTPUT, Cdfid, vid, '_FillValue', fill, $
      UBYTE  = varType EQ  1, $
      SHORT  = varType EQ  2, $
      LONG   = varType EQ  3, $
      ULONG  = varType EQ 13, $
      FLOAT  = varType EQ  4, $
      DOUBLE = varType EQ  5

ENDIF

RETURN, vid

END
