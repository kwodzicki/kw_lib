FUNCTION GETCTNAMES, file
COMPILE_OPT IDL2

n = 0B
OPENR, iid, file, /GET_LUN
READU, iid, n

SKIP_LUN, iid, 256L*3L*n
names = BYTARR(32,  n, /NoZero)
READU, iid, names

FREE_LUN, iid

names = STRTRIM( STRING(names), 2 )

RETURN, names

END
