PRO CHUNTAO_COLORS_2_IDL, TABLENAME = tablename, DIR = dir
;+
; Name:
;   CHUNTAO_COLORS_2_IDL
; Purpose:
;   An IDL procedure to convert the color table files in Chuntao Liu's
;   IDL code to a single IDL color table file
; Inputs:
;   None
; Outputs:
;   An IDL colortable file
; Keywords:
;   TABLENAME : Name of the output color table file. Default is Chuntao_TRMM.tbl
;   DIR       : Path to directory where Chuntao's color table files are stored.
; Author and History:
;   Kyle R. Wodzicki     Created 20 May 2019
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(tablename) EQ 0 THEN $
  tablename = 'Chuntao_TRMM.tbl'

IF N_ELEMENTS(dir) EQ 0 THEN $
  dir = '/Users/kwodzicki/Programming/idl/Data_Analysis/TRMM/Chuntao/colors'

ctFile = FILEPATH( tablename, $
  ROOT_DIR     = FILE_DIRNAME( GETENV('IDL_STARTUP') ), $
  SUBDIRECTORY = 'color_tables')

IF (FILE_TEST(FILE_DIRNAME(ctFile), /DIR) EQ 0) THEN $
  FILE_MKDIR, FILE_DIRNAME(ctFile)

;=== Code to generate new color table file
OPENW,  oid, ctFile, /GET_LUN                                                   ; Open file for writing
WRITEU, oid, 1B, BYTARR(256L * 3L + 32L)                                        ; Write number of color tables (1), the color table values (256 * 3), and the color table name (32 bytes)
FREE_LUN, oid

;=== Find color files
files = FILE_SEARCH(dir, '*.clr', COUNT = nFiles)
rIDs  = WHERE(STRMATCH(files, '*red_*.clr', /FOLD_CASE), rcnt)
gIDs  = WHERE(STRMATCH(files, '*grn_*.clr', /FOLD_CASE), gcnt)
bIDs  = WHERE(STRMATCH(files, '*blu_*.clr', /FOLD_CASE), bcnt)

;=== Check that same number of each color found
IF (rcnt EQ 0) OR (gcnt EQ 0) OR (bcnt EQ 0) THEN $
  MESSAGE, 'Did not find any files for one of the colors!' $
ELSE IF (rcnt NE gcnt) OR (rcnt NE bcnt) THEN $
  MESSAGE, 'Number of color files mismatch!'

;=== Put all files into list
rgbFiles = [ [ files[rIDs] ], [ files[gIDs] ], [ files[bIDs] ] ]

;=== Iterate over all color tables
FOR i = 0, rcnt-1 DO BEGIN
  info = FILE_INFO( rgbFiles[i,0] )
  rgb  = BYTARR( info.SIZE, 3 )
  vals = BYTARR( info.SIZE )
  FOR j = 0, 2 DO BEGIN
    OPENR, iid, rgbFiles[i,j], /GET_LUN
    READU, iid, vals
    FREE_LUN, iid
    rgb[0,j] = vals
  ENDFOR
  IF (info.SIZE NE 256) THEN rgb = CONGRID( rgb, 256, 3 )
  ctName = STRSPLIT(FILE_BASENAME(rgbFiles[i,0], '.clr'), '_', /EXTRACT)
  MODIFYCT, i, STRMID(ctName[1], 0, 32), rgb[*,0], rgb[*,1], rgb[*,2], $
    FILE = ctFile                                                               ; Update the table in the file
ENDFOR



END