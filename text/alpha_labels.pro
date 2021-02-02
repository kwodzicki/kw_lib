FUNCTION ALPHA_LABELS, n, UPPERCASE = uppercase
COMPILE_OPT IDL2

IF n GT 26 THEN MESSAGE, 'Can only make 26 labels!!'

chars = 'abcdefghijklmnopqrstuvwxyz'
IF KEYWORD_SET(uppercase) THEN chars = STRUPCASE(chars)

out = STRARR(n)
FOR i = 0, n-1 DO out[i] = '(' + STRMID(chars,i,1) + ')'

RETURN, out

END
