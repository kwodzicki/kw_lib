FUNCTION FORMAT_EXP, val, FORMAT = format

COMPILE_OPT IDL2

IF N_ELEMENTS(format) EQ 0 THEN FORMAT="(F4.1)"

tmp = STRING(val, FORMAT="(E100.50)")																					; Get string representation with lots of precision
tmp = STRSPLIT(STRTRIM(tmp,2), 'E', /Extract)																	; Split on E

power = LONG(tmp[1])																													; Get value of power
IF SIZE(val, /TNAME) EQ 'FLOAT' THEN BEGIN																		; If dealing with float
  eps   = MACHAR()																														; Get floating machin precision
  scale = 10.E0^power																													; Compute scaling for number
  diff  = val - scale																													; Compute difference, used to check if 'mantissa' is 'one'
ENDIF ELSE BEGIN																			
  eps   = MACHAR(/DOUBLE)
  scale = 10.D0^power
  diff  = val - scale
ENDELSE

factor = '10!E'+STRTRIM(power,2)+'!N'																					; String of factor to add on end
IF diff LE eps.EPS THEN $																											; If difference is 'zero'
  RETURN, factor  $																														; Return factor
ELSE $																																				; Else	
  RETURN, STRTRIM(STRING(val/scale, FORMAT=format)+' '+factor, 2)							; Get leading factor, append trailing factor, strip leading/trailing white space

END
