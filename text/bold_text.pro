FUNCTION BOLD_TEXT, text, format
COMPILE_OPT IDL2

IF N_PARAMS() EQ 1 THEN $
  RETURN, '!4' + text + '!3' $
ELSE IF N_PARAMS() EQ 2 THEN BEGIN
  n   = STRLEN(format)-2
  fmt = STRMID(format, 1, n)
  IF fmt.CONTAINS("'") THEN $
    fmt = "('!4'," + fmt + ",'!3')" $
  ELSE $
    fmt = '("!4",' + fmt + ',"!3")'
  RETURN, STRING(text, FORMAT=fmt)
ENDIF

MESSAGE, 'Incorrect number of inputs'

RETURN, -1

END
