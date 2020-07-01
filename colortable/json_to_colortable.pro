PRO JSON_TO_COLORTABLE, files, OUTDIR = outdir
;+
; Name:
;   JSON_TO_COLORTABLE
; Purpose:
;   An IDL procedure to convert a JSON file containing color table
;   RGB values to an IDL color table file
; Inputs:
;   files   : Scalar or string array with full path to json file(s)
; Outputs:
;   Creates a .tbl file
; Keywords:
;   OUTDIR   : Output directory for the .tbl file
; Author and History:
;   Kyle R. Wodzicki     Created 26 Mar. 2019
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(outdir) EQ 0 THEN outdir = ''
IF N_ELEMENTS(files) EQ 0 THEN files = [files]

FOR j = 0, N_ELEMENTS(files)-1 DO BEGIN
  file     = files[j]
  filebase = FILE_BASENAME(file, '.json')
  ct_file  = filebase + '.tbl'
  ct_file  = FILEPATH( ct_file, ROOT_DIR = outdir, SUBDIRECTORY='tables' )
  IF (FILE_TEST(FILE_DIRNAME(ct_file), /DIR) EQ 0) THEN $
    FILE_MKDIR, FILE_DIRNAME(ct_file)

  ;=== Code to generate new color table file
  OPENW, oid, ct_file, /GET_LUN                                                 ; Open file for writing
  WRITEU, oid, 1B, BYTARR(256L * 3L + 32L)                                      ; Write number of color tables (1), the color table values (256 * 3), and the color table name (32 bytes)
  FREE_LUN, oid

  json = JSON_PARSE( file )                                                     ; Parse information from JSON file
  keys = json.keys()                                                            ; Get all keys from the parsed data
  FOR i = 0, N_ELEMENTS(keys)-1 DO BEGIN                                        ; Iterate over all keys
    key = keys[i]                                                               ; Ith key

    IF json[key, 'rgb', 0].IsEmpty() THEN $
      rgb = BYTARR( 256, 3 ) $
    ELSE BEGIN
      rgb = json[key, 'rgb'].ToArray(/Transpose)                                ; Convert RGB values from list to array; transpose so columns are values and rows are channels
      IF json[key,'n'] LT 256 THEN $
        rgb = CONGRID( rgb, 256, 3 )                                            ; If the colorbar has less than 256 values, use CONGRID() to expand it
    ENDELSE
    MODIFYCT, i, STRMID(key, 0, 32), rgb[*,0], rgb[*,1], rgb[*,2], FILE = ct_file ; Update the table in the file
  ENDFOR
ENDFOR

END