FUNCTION FILE_SIZE, file
;+
; Name:
;   FILE_SIZE
; Purpose:
;   A function to return the size of a file
; Inputs:
;   file  : Path to file
; Outputs:
;   Returns size of file for FILE_INFO command.
; Author and History:
;   Kyle R. Wodzicki     Created 12 Jan. 2015
;-
  COMPILE_OPT HIDDEN
  RETURN, (FILE_INFO(file)).SIZE
END