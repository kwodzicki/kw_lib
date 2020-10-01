FUNCTION LOGSPACE, startIn, stopIn, num, ENDPOINT=endpoint, BASE=base

COMPILE_OPT IDL2

IF N_ELEMENTS(num)      EQ 0 THEN num      = 50
IF N_ELEMENTS(endpoint) EQ 0 THEN endpoint = 1B
IF N_ELEMENTS(base)     EQ 0 THEN base     = 10.0

IF num LT 0 THEN MESSAGE, 'Number of samples must be non-negative number'

y = LINSPACE(startIn, stopIn, num, ENDPOINT=endpoint)

RETURN, base^y

END
