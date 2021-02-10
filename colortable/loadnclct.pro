PRO LOADNCLCT, familyIn, tableIn, RGB_TABLE = rgb_table, _EXTRA = extra
;+
; Name:
;   LOADNCLCT
; Purpose:
;   Procedure to load in NCL color tables. Wrapper for the LOADCT procedure
; Inputs:
;   familyIn  : Name of the NCL color table family to use
;   tableIn   : Name of the table or table index to use
; Keywords
;   RGB_TABLE : Same as LOADCT keyword
;   _EXTRA    : Any other keyword for LOADCT, besides the FILE keyword
; Returns:
;   None.
;-
COMPILE_OPT IDL2

dir    = FILE_DIRNAME(ROUTINE_FILEPATH())
family = STRJOIN(STRSPLIT(familyIn, '/', /EXTRACT), '-')
file   = FILEPATH(family+'.tbl', ROOT_DIR=dir, SUBDIRECTORY='tables')
names  = GETCTNAMES(file)
IF ISA(tableIn, 'STRING') THEN BEGIN
  index = WHERE(STRMATCH(names, tableIn, /FOLD_CASE), cnt)
  IF cnt NE 1 THEN MESSAGE, 'Table '+tableIn+' not found in file '+file
ENDIF ELSE $
  index = tableIn

KWLOADCT, index, FILE=file, RGB_TABLE = rgb_table, _EXTRA = extra

END
