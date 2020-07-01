FUNCTION FORMAT_TEXT, strIn
;+
; Name:
;   FORMAT_TEXT
; Purpose:
;   Function to parse units and other text to replace characters
;   like ** and ^ with IDL exponent notation
; Inputs:
;   strIn : String to format
; Keywords:
;   None.
; Returns:
;   IDL formatted string
;-

COMPILE_OPT IDL2

tmp = STRSPLIT(strIn, /EXTRACT)
FOR i = 0, N_ELEMENTS(tmp)-1 DO BEGIN
  IF STRMATCH(tmp[i], '*\*\**') THEN $
    tmp[i] = STRREP(tmp[i], '**', '!E') + '!N' $
  ELSE IF STRMATCH(tmp[i], '^') THEN $
    tmp[i] = STRREP(tmp[i], '^', '!E') + '!N' 
ENDFOR

RETURN, STRJOIN(tmp, ' ')

END
