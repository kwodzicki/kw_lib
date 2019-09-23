PRO RENAME_FILES, dir, old_pattern, new_pattern

;+
; Name:
;		RENAME_FILES
; Purpose:
;		To batch rename all files in a directory.
; Inputs:
;		dir         : Directory where the data is located.
;   old_pattern : The pattern currently used to identify data.
;   new_pattern : The new pattern that is to be used to identify
;                 files.
; Outputs:
;		New files with the names desired.
; Keywords:
;		None.
; Author and History:
;		Kyle R. Wodzicki		Created 25 July 2014
;
;    MODIFIED 07 Oct. 2014
;      Added inputs to make a more robust and flexible procedure.
;-

COMPILE_OPT IDL2, HIDDEN                                              ;Set Compile options

IF (N_PARAMS() NE 3) THEN MESSAGE, 'Incorrect number of arguments.'   ;Check number of inputs

files = FILE_SEARCH(dir, '*')                                         ;Search for all files in directory
id    = WHERE(STRMATCH(files, '*'+old_pattern+'*', /FOLD_CASE),CNT)   ;Find indices of files matching pattern

IF (CNT NE 0) THEN files = files[id]                                  ;Filter to only files with pattern

FOR i = 0, N_ELEMENTS(files)-1 DO BEGIN                               ;Iterate over all files
	dir_name  = FILE_DIRNAME(files[i])+'/'                              ;Get the location of the file
	base_name = FILE_BASENAME(files[i])                                 ;Get name of the file
	name_len  = STRLEN(base_name)                                       ;Get length of the file name
	start_pos = STRPOS(base_name, old_pattern)                          ;Determine location of old_pattern in string
	IF (start_pos EQ 0) THEN BEGIN                                      ;If pattern at the beginning of file name
	  old_pat_len = STRLEN(old_pattern)                                     ;Determine length of old pattern string
	  new_file = dir_name + new_pattern + $                             ;Create new file name
	             STRMID(base_name,old_pat_len, name_len - old_pat_len)
	  FILE_MOVE, files[i], new_file                                     ;Rename the file
	ENDIF ELSE BEGIN                                                    ;If pattern does not start at beginning of name
	  old_pat_len = start_pos+STRLEN(old_pattern)                       ;Set old_pat_len to position of last character
	  new_file = STRMID(base_name,0,start_pos)+new_pattern              ;Create first part of new file name
	  new_file = new_file + STRMID(base_name, $                         ;Add second part to name
	                               old_pat_len, $
	                               name_len-old_pat_len)
	  FILE_MOVE, files[i], dir_name + new_file                          ;Rename the file
  ENDELSE
ENDFOR 

END