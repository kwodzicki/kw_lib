FUNCTION VALUEINARRAY, value, array, INDEX = index

COMPILE_OPT IDL2

index = WHERE( array EQ value, cnt)

RETURN, cnt

END
