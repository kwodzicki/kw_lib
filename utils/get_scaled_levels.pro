FUNCTION GET_SCALED_LEVELS, raw, scaled

COMPILE_OPT IDL2

levels = ULON64ARR(256, /NoZero)

levels[0] = 0
FOR i = 0, 254 DO $
  WHILE TOTAL((raw GE levels[0]) AND (raw LT levels[i+1]), /INT) LT TOTAL(scaled EQ i, /INT) DO $
    levels[i] += 1

RETURN, levels

END
