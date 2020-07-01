FUNCTION GIT_VERSION, pathIn
;+
; Name:
;   GIT_VERSION
; Purpose:
;   Function to determine version number based on git
;   branch name
; Inputs:
;   pathIn   : Full path program file
; Keywords:
;   None.
; Returns:
;   String containing git branch name
;-

COMPILE_OPT IDL2, HIDDEN

path = FILE_TEST(pathIn) ? FILE_DIRNAME(pathIn) : pathIn
cmd = "cd " + path + "; git branch | grep \* | cut -d ' ' -f2"

SPAWN, cmd, res, err
IF (err EQ '') THEN $
  RETURN, res $
ELSE $
  MESSAGE, err
END
