FUNCTION WRAP_TEXT, text_in, charWidth, length
;+
; Name:
;   WRAP_TEXT
; Purpose:
;   An IDL function to wrap texting using the !C character
; Inputs:
;   text      : String of text to wrap
;   charWidth : Width of characters in any unit; i.e., device, normal
;   length    : Maximum length of the string
; Keywords:
;   None.
; Outputs:
;   Returns wrapped text
; Author and History:
;   Kyle R. Wodzicki     Created 08 Nov. 2019
;-
COMPILE_OPT IDL2

text     = text_in
text_out = ''
maxWid   = FLOOR( length / FLOAT(charWidth) )
textWid  = STRLEN(text)

IF (textWid LE maxWid) THEN RETURN, text

WHILE (STRLEN(text) GT 0) DO BEGIN
	text_out += STRMID(text, 0, maxWid-1)
	text = STRMID(text, maxWid-1)
	IF (STRLEN(text) GT 0) THEN BEGIN 
		IF (STRMID(text_out, 0, /REVERSE) NE ' ') THEN $
			text_out += '-' $
		ELSE $
			text_out = STRTRIM(text_out, 2)
		text_out += '!C'
	ENDIF 
ENDWHILE

RETURN, text_out
END
