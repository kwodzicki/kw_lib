FUNCTION KW_ESAT, temp_in, $
  UNIT = unit, $
	PA   = Pa,  $
	KPA  = kPa, $
	PRES = pres
;+
; Name:
;   KW_ESAT
; Purpose:
;		To determine the saturation vapor pressure at a given temperature
; Calling Sequence:
;		result = KW_ESAT(input_temp, UNIT='f')
; Inputs:
;   temp  : The temperature at which to determine the 
;           the saturation vapor pressure at.
;           Standard input units are KELVIN, if
;           different units for temperature are used,
;           one must utilized the UNIT keyword.
; Outputs:
;   The saturation vapor pressure in units of hPa is returned.
; Keywords:
;   UNTI  : Use this to specify if the input temperature
;           is in unites other than Kelvin. Options are:
;             'k' or 'K' -> Kelvin (Default)
;             'c' or 'C' -> Celsius
;             'f' or 'F' -> Fahrenheit
;		KPA		: Set if pressure input/return is in kilo Pascales
;		HPA		: Set if pressure input/return is in hectoPascales
;						Default for both is to use Pascales
;		PRES	: Set this to determine the dew point from a given 
;						vapor pressure
; Author and History:
;   Kyle R. Wodzicki	Created 01 July 2014
;
;			MODIFIED 29 Sep. 2014
;				Added keyword for different pressure unit returns and
;				a keyword to invert the equation
;			MODIFIED 30 Sep. 2014
;				Changed name to kwCLAUS_CLAP from CLAUS_CLAP
;     MODIFIED 19 Sep. 2017 by Kyle R. Wodzicki
;       Changed name to KW_ESAT
;-

COMPILE_OPT IDL2                                                                ;Set compile options.

type = SIZE(temp_in, /TYPE)                                                     ;Get type of input data
IF type LT 4 THEN type = 4

E0 = KEYWORD_SET(kPa) ? 6.11D-01 : $
		 KEYWORD_SET(Pa) ?  6.11D02  : 6.11D00
T0 = 273.16D0                                                         ;T_0 K

IF N_ELEMENTS(unit) EQ 0 THEN unit = 'k'

CASE STRUPCASE(unit) OF
	'K'  : temp = DOUBLE(temp_in)
	'C'  : temp = temp_in + 273.15D0
	'F'  : temp = (temp_in - 32.0D0) * 5.0D0 / 9.0D0 + 273.15D0
ENDCASE

IF KEYWORD_SET(pres) THEN $
	RETURN, (1.0D00/T0 - (!Rv/!Lv0)*ALOG(pres/E0))^(-1)	$
ELSE BEGIN
	ES = E0 * EXP( -1 * !Lv0/!Rv * ((1.0D00/TEMP) - (1.0D00/T0)))	                ; es is pressure in this context
	RETURN, FIX(ES, TYPE = type)  									                              ; Return answer
ENDELSE 
END 
