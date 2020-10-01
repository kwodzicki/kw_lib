FUNCTION KW_GAMMA_LEVELS, z, gamma, NLEVELS=nlevels
COMPILE_OPT IDL2

IF N_PARAMS() NE 2 THEN MESSAGE, 'Incorrect number of inputs'
IF N_ELEMENTS(nlevels) EQ 0 THEN nlevels = 256

zz     = z^gamma

zzMin  = MIN(zz, MAX=zzMax, /NaN)

levels = INDGEN(nlevels) / FLOAT(nlevels-1)
levels = TEMPORARY(levels) * (zzMax-zzMin) + zzMin

RETURN, levels^(1.0/gamma)

END
