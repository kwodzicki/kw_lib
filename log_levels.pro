FUNCTION LOG_LEVELS, min, max
;+


COMPILE_OPT IDL2


x = 10L^(INDGEN(6)+1)
y = INDGEN(9)+1
z = INDGEN(10)
FOR i = 0, 5 DO z = [z, y * x[i]]

id = WHERE(z GE min AND z LE max, CNT)
IF CNT GT 0 THEN RETURN, z[id] ELSE RETURN, z

END