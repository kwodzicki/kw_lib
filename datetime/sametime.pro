FUNCTION SAMETIME, t1, t2, PRECISION = precision
;Check the time difference between two dates given percision in seconds
COMPILE_OPT IDL2

IF N_ELEMENTS(precision) EQ 0 THEN precision = 1.0D0
eps   = 5.0D-05
spd   = 0.864D05
dt    = ABS( t1-t2 ) * spd

RETURN, (dt+eps) LT precision

END
