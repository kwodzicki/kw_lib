FUNCTION STRREP, inStr, old, new
;+
; Name:
;   STRREP
; Purpose:
;   An IDL function for replacing characters in a string
; Inputs:
;   inStr : String with characters for replacing
;   old   : Character to be replaced
;   new   : Character to replace with
; Keywords:
;   None.
; Outputs:
;   String with any instance of old replaced with new
; Example
;   IDL> s1 = 'Hello.Goodbye'
;   IDL> s2 = STRREP(s1, '.', '_')
;   IDL> PRINT, s2
;   Hello_Goodbye
;-
  RETURN, STRJOIN( STRSPLIT(inStr, old, /EXTRACT), new )											; Split string on old and join with new
END
