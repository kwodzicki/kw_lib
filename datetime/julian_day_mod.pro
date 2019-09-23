FUNCTION JULIAN_DAY_MOD, yy, MONTH=month

;+
; Name:
;	JULIAN_DAY_MOD
; Purpose:
;	This function will return an array of values that represent
;	the number of days in each month of that year corrected for
;	leap years. Array is 13 elements, first element is a pad of `0'
;	i.e. days[1] will give days for January, the first month
; Calling sequence:
;	JULIAN_DAY_MOD, yy
; Input:
;	yy	:	The year the data was collected in
; Output:
;	Array containing the number of days in each month
; Keywords:
;	MONTH	: If month is set, only the days in month desired is returned.
;				Month can be either three letter abbreviation or full name.
; Author and history:
;	Adapted from	:
;		`read_pf_level1_hdf' VERSION 6.0.2 - Chuntao Liu, 
;			UNIVERSITY OF UTAH   January 2004
;	Modified by	:
;		Kyle R. Wodzicki	28 February 2014
;	Modified 18 June 2014 - Added the MONTH key word
;	MODIFIED 22 July 2014:
;			Now checks if Month keyword is a string or integer.
;-

yy = FIX(yy)													;Convert to integer


days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]		
IF (yy MOD 4 EQ 0) THEN days[2] = days[2]+1
IF (yy MOD 100 EQ 0 AND yy MOD 400 NE 0) THEN days[2]=days[2]-1

IF KEYWORD_SET(month) THEN BEGIN
	IF (SIZE(month, /TYPE) EQ 7) THEN BEGIN
		IF (STRCMP(month,'JAN',3, /FOLD_CASE)) THEN days = days[1]	;Return num days in Jan.
		IF (STRCMP(month,'FEB',3, /FOLD_CASE)) THEN days = days[2]	;Return num days in Feb.
		IF (STRCMP(month,'MAR',3, /FOLD_CASE)) THEN days = days[3]	;Return num days in Mar.
		IF (STRCMP(month,'APR',3, /FOLD_CASE)) THEN days = days[4]	;Return num days in Apr.
		IF (STRCMP(month,'MAY',3, /FOLD_CASE)) THEN days = days[5]	;Return num days in May.
		IF (STRCMP(month,'JUN',3, /FOLD_CASE)) THEN days = days[6]	;Return num days in June.
		IF (STRCMP(month,'JUL',3, /FOLD_CASE)) THEN days = days[7]	;Return num days in July.
		IF (STRCMP(month,'AUG',3, /FOLD_CASE)) THEN days = days[8]	;Return num days in Aug.
		IF (STRCMP(month,'SEP',3, /FOLD_CASE)) THEN days = days[9]	;Return num days in Sep.
		IF (STRCMP(month,'OCT',3, /FOLD_CASE)) THEN days = days[10];Return num days in Oct.
		IF (STRCMP(month,'NOV',3, /FOLD_CASE)) THEN days = days[11];Return num days in Nov.
		IF (STRCMP(month,'DEC',3, /FOLD_CASE)) THEN days = days[12];Return num days in Dec.
	ENDIF ELSE days = days[month]
;		CASE month OF
;			1		: days = days[1]	;Return num days in Jan.
;			2 	: days = days[2]
;			3 	: days = days[3]
;			4 	: days = days[4]
;			5 	: days = days[5]
;			6 	: days = days[6]
;			7 	: days = days[7]
;			8 	: days = days[8]
;			9 	: days = days[9]
;			10 	: days = days[10]
;			11 	: days = days[11]
;			12 	: days = days[12]
;		ENDCASE
;	ENDELSE
ENDIF

RETURN, days

END