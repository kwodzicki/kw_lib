FUNCTION _STRIP_TRAILING_DOLLAR_SIGN, line
;+
; Name:
;   _STRIP_TRAILING_DOLLAR_SIGN
; Purpose:
;   Function to remove last character of a string
;   if that character is a dollar sign ($)
; Inputs:
;   line  : String of text
; Keywords:
;   None.
; Returns:
;   Line with last character removed if that character was a 
;   dollar sign ($)
;-
COMPILE_OPT IDL2, HIDDEN

IF STRMID(line, 0, /REVERSE) EQ '$' THEN $
  RETURN, STRMID(line, 0, STRLEN(line)-1)

RETURN, line
END

FUNCTION GET_STARTUP_TEXT
;+
; Name:
;   GET_STARTUP_TEXT
; Purpose:
;   Function to read and parse text from IDL_STARTUP file into an array
;   so that the array elements can be passed to IDL_IDLBridge.Execute
;   to set up environment.
; Inputs:
;   None.
; Keywords:
;   None.
; Returns:
;   List of strings containing parsed data from IDL_STARTUP, empty array
;   if nothing parsed.
;-
COMPILE_OPT IDL2

startup = GETENV('IDL_STARTUP')																								; Get path to IDL_STARTUP
IF startup NE '' THEN BEGIN																										; If path is not empty string
  line  = ''																																	; Initialize line as emty string
  lines = LIST('')																														; List to hold lines from file
  OPENR, iid, startup, /GET_LUN																								; Open IDL_STARTUP for reading

  append = 0B																																	; Initiailze append flag to false
  WHILE NOT EOF(iid) DO BEGIN																									; Iterate while not at end of file
    READF, iid, line																													; Read line
    IF STRMATCH(line, '*DEVICE,*', /FOLD_CASE) EQ 0 AND line NE '' THEN BEGIN	; If line does NOT contain 'DEVICE,' AND line is not empty
      id = STREGEX(line, ' *\;[^\;]*$')																				; Get index of start of comment with preceeding spaces
      IF id NE -1 THEN line = STRMID(line, 0, id)															; If the index is NOT -1, then use STRMID() to get valid text
      line = STRTRIM(line, 2)																									; Strip any remaining white space
      IF STRLEN(line) EQ 0 THEN CONTINUE																			; If length of string is zero, then skip line
      IF append EQ 1B THEN $																									; If append is true
        lines[-1] += _STRIP_TRAILING_DOLLAR_SIGN(line) $											; Strip off any trailing dollar sign ($) and append to previous line
      ELSE $																																	; Else
        lines.ADD, _STRIP_TRAILING_DOLLAR_SIGN(line)													; Strip off any trailing dollar sign ($) and add to list as new line
      append = STRMID(line, 0, /REVERSE) EQ '$'																; Set append flag to True if line ended with dollar sign ($)
    ENDIF
  ENDWHILE
  FREE_LUN, iid																																; Close file
  RETURN, lines.ToArray(/No_Copy)																							; Convert list to array and return
ENDIF

RETURN, []																																		; Return empty list

END
