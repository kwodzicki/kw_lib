FUNCTION SAMETIME, t1, t2, PRECISION = precision
;Check the time difference between two dates given percision in seconds
COMPILE_OPT IDL2

precision = (N_ELEMENTS(precision) EQ 0) ? 1.0D0 : DOUBLE(precision)					; Set precision in seconds
eps   = 5.0D-05																																; Set precision of JULDAY function based on documentation
spd   = 0.864D05																															; Set number of seconds per day
dt    = ABS( t1-t2 ) * spd																										; Compute time differences between dates in seconds

RETURN, (dt + eps) LT precision

END
