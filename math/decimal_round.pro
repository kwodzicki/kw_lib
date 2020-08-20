FUNCTION DECIMAL_ROUND, num, decimal
COMPILE_OPT IDL2
type   = SIZE(num, /TYPE)
factor = 10.0D0^decimal

RETURN, FIX( ROUND( num * factor ) / factor, TYPE=type ) 

END
