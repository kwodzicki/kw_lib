PRO KW_LOADCT, table_number, $
  SILENT    = silent, $
  GET_NAMES = names, $
  FILE      = file, $
  NCOLORS   = ncolors, $
  BOTTOM    = bottom, $
  RGB_TABLE = rgb_table

COMPILE_OPT IDL2, HIDDEN

IF N_ELEMENTS(ncolors) EQ 0 THEN ncolors = 256
IF N_ELEMENTS(bottom)  EQ 0 THEN bottom  =   0

IF (bottom + ncolors) GT 256 THEN $
  MESSAGE, STRING(ncolors, bottom, FORMAT="('Cannot load ',I3,' colors starting at ',I3)")

LOADCT, table_number, FILE=file, RGB_TABLE = rgb_table
IF ncolors NE 256 THEN BEGIN
  p = (LINDGEN(ncolors) * (255-bottom)) / (ncolors-1) + bottom
  rgb_table = rgb_table[p, *]
ENDIF

LOADCT, table_number, SILENT=silent, GET_NAMES=get_names, FILE=file, $
  NCOLORS=ncolors, BOTTOM=bottom

END
