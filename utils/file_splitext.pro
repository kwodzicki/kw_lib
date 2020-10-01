PRO FILE_SPLITEXT, file, base, ext
;+
; Name:
;   FILE_SPLITEXT
; Purpose:
;   Function to split file name and file extension.
;   Modeled after python os.path.splitext()
; Inputs:
;   file : Path to file
; Keywords:
;   None.
; Returns:
;   2-element string array with first (0th) element containing root a
;   and second (1st element) containing ext.
;-

COMPILE_OPT IDL2

dir  = FILE_DIRNAME(file)
base = FILE_BASENAME(file)
ext  = ''																																			; Default extension is empty
tmp  = STRSPLIT(base, '.', /EXTRACT, /PRESERVE_NULL)

IF (tmp[0] NE '' AND tmp.LENGTH GT 1) OR (tmp[0] EQ '' AND tmp.LENGTH GT 2) THEN BEGIN																								; If there is more than one value in the split
  base = STRJOIN(tmp[0:-2], '.')
  ext  = '.' + tmp[-1]
ENDIF

IF (dir NE '.') THEN $
  base = FILEPATH(base,  ROOT_DIR=dir)

END
