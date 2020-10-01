FUNCTION LINSPACE, startIn, stopIn, num, ENDPOINT=endpoint, RETSTEP=step

COMPILE_OPT IDL2

IF N_ELEMENTS(num)      EQ 0 THEN num      = 50
IF N_ELEMENTS(endpoint) EQ 0 THEN endpoint = 1B

IF num LT 0 THEN MESSAGE, 'Number of samples must be non-negative number'

div      = KEYWORD_SET(endpoint) ? num-1 : num

startVal = startIn * 1.0
stopVal  = stopIn  * 1.0

delta    = stopVal - startVal
y        = LINDGEN(num)

IF div GT 0.0 THEN BEGIN
  step = delta / div
  IF TOTAL(step EQ 0, /INT) GT 0 THEN y /= div ELSE y *= step
ENDIF ELSE BEGIN
  step = !Values.F_NaN
  y    = y * delta
ENDELSE

y += startVal

IF KEYWORD_SET(endpoint) and num GT 1 THEN y[-1] = stopVal

RETURN, y

END
