FUNCTION STRTITLE, str, CHARS = chars

COMPILE_OPT IDL2

IF N_ELEMENTS(chars) EQ 0 THEN chars = [' ', '-']
x = str
FOR j = 0, chars.LENGTH-1 DO BEGIN
  x = STRSPLIT(x, chars[j], /EXTRACT)
  FOR i = 0, x.LENGTH-1 DO $
    x[i] = STRUPCASE(STRMID(x[i], 0, 1)) + STRMID(x[i], 1)
  x = STRJOIN(x, chars[j])
ENDFOR

RETURN, x

END
