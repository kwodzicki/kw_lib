FUNCTION CREATE_JULDAY, start_date, end_date, $
  MONTH  = month, $
  HOUR   = hour, $
  MINUTE = minute
;+
; Name:
;   CREATE_JULDAY
; Purpose:
;   A function to create an array of Julian dates over a given
;   time period at a given interval.
; Calling Sequence:
;   dates = CREATE_JULDAY('1998-10-01_00:00', '1999-11-01_00:00')
; Inputs:
;   start_date  : Starting time for dates. Must input at least
;                 year, month, day. If only these input but want 
;                 higher resolution (i.e., hourly or minutely),
;                 00:00 used for start and end
;                 Sting input must be of form 'YYYY-MM-DD-HH-MM'
;                 Delimiter does not matter, just must contain one.
;   end_date    : Ending time for dates. Same format as input
; Outputs:
;   Returns an array of dates in Julian day format.
; Keywords:
;   MONTH  : set interval to monthly, day = 0, hour/min=0
;   DAY    : Set interval to daily, Hour = 0, min = 0; DEFAULT
;   HOUR   : Set interval to hourly, min = 0
;   MINUTE : Set interval to every minute, sec. = 0
; Author and History:
;   Kyle R. Wodzicki     Created 18 Nov. 2014
;-
COMPILE_OPT IDL2

IF (N_PARAMS() NE 2 ) THEN MESSAGE, 'Incorrect number of inputs!'

;=== Make sure inputs are strings and determine starting/ending dates
IF (SIZE(start_date, /TNAME) EQ 'STRING') THEN BEGIN
  str_len = STRLEN(start_date)
  IF (str_len LT 10) THEN MESSAGE, 'MUST input year, month, and day!'
  s_year     = LONG(STRMID(start_date,  0, 4))
  s_month    = LONG(STRMID(start_date,  5, 2))
  s_day      = LONG(STRMID(start_date,  8, 2))
  s_hour     = (str_len GE 13) ? LONG(STRMID(start_date, 11, 2)) : 0
  s_minute   = (str_len EQ 16) ? LONG(STRMID(start_date, 14, 2)) : 0
ENDIF ELSE MESSAGE, 'Starting date MUST be a STRING!'

IF (SIZE(end_date, /TNAME) EQ 'STRING') THEN BEGIN
  str_len = STRLEN(end_date)
  IF (str_len LT 10) THEN MESSAGE, 'MUST input year, month, and day!'
  e_year   = LONG(STRMID(end_date,  0, 4))
  e_month  = LONG(STRMID(end_date,  5, 2))
  e_day    = LONG(STRMID(end_date,  8, 2))
  e_hour   = (str_len GE 13) ? LONG(STRMID(end_date, 11, 2)) : 0
  e_minute = (str_len EQ 16) ? LONG(STRMID(end_date, 14, 2)) : 0
ENDIF ELSE MESSAGE, 'Ending date MUST be a STRING!'

dates = []

FOR yy = s_year, e_year DO BEGIN                                      ;Iterate over year
  days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  IF (yy MOD 4 EQ 0) THEN days[2] = days[2]+1
  IF (yy MOD 100 EQ 0 AND yy MOD 400 NE 0) THEN days[2]=days[2]-1
  
  IF KEYWORD_SET(month) THEN BEGIN
    start_month = 1 & end_month = 1
    start_day   = 1 & end_day   = 1
    start_hour  = 0 & end_hour  = 0
    start_minute= 0 & end_minute= 0
  ENDIF ELSE BEGIN
    start_month = (yy EQ s_year) ? s_month :  1
    end_month   = (yy EQ e_year) ? e_month : 12
  ENDELSE
    
  FOR mm = start_month, end_month DO BEGIN                            ;Iterate over month
		IF ~KEYWORD_SET(month) THEN BEGIN
		  start_day = (yy EQ s_year AND mm EQ s_month) ? s_day : 1
		  end_day   = (yy EQ e_year AND mm EQ e_month) ? e_day : days[mm]
		ENDIF ELSE BEGIN
		  start_day = 0 & end_day = 0
		ENDELSE
      
    FOR dd = start_day, end_day DO BEGIN                              ;Iterate over day
      IF KEYWORD_SET(hour) OR KEYWORD_SET(minute) THEN BEGIN
				IF (yy EQ s_year AND mm EQ s_month AND dd EQ s_day) THEN $
				  start_hour = s_hour ELSE start_hour = 0
		    IF (yy EQ e_year AND mm EQ e_month AND dd EQ e_day) THEN $
		      end_hour = e_hour ELSE end_hour = 23
			ENDIF ELSE BEGIN
				start_hour = 0 & end_hour  = 0
			ENDELSE
            
      FOR hr = start_hour, end_hour DO BEGIN                          ;Iterate over hour
				IF KEYWORD_SET(minute) THEN BEGIN
					IF (yy EQ s_year AND mm EQ s_month AND $
					    dd EQ s_day  AND hr EQ s_hour) THEN $
						start_minute = s_minute ELSE start_minute = 0
					IF (yy EQ e_year AND mm EQ e_month AND $
					    dd EQ e_day  AND hr EQ e_hour) THEN $
						end_minute = e_minute ELSE end_minute = 59
				ENDIF ELSE BEGIN
					start_minute = 0 & end_minute  = 0
				ENDELSE
								
			  FOR min = start_minute, end_minute DO BEGIN                   ;Iterate over minutes
			    dates = [dates, JULDAY(mm, dd, yy, hr, min)]
			  ENDFOR                                                        ;END minute
			ENDFOR                                                          ;END hour
		ENDFOR                                                            ;END day
	ENDFOR                                                              ;END month
ENDFOR                                                                ;END year

RETURN, dates
END