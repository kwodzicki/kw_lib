FUNCTION DATETIME::Init, year, month, day, hour, minute, second, NO_LEAP = no_leap
  ;+
  ;NAME:
  ;		DATETIME::Init
  ;PURPOSE:
  ;		This method initializes a datetime object
  ;CATEGORY:
  ;		Date and time calculations.
  ;CALLING SEQUENCE:
  ;		date = DATETIME([year, [month, [day, [hour, [minute, [second]]]]]])
  ;INPUT:
  ;		year   : Optional calendar year
  ;		month  : Optional month (1 to 12)
  ;		day    : Optional day of the month (1 to 28, 30, or 31)
  ;		hour   : Optional hour (0 to 23)
  ;		minute : Optional minute (0 to 59)
  ;		second : Optional second (0 to 59)
  ;OUTPUT:
  ;		DATETIME object
  ;KEYWORDS:
  ;     NO_LEAP
  ;MODIFICATION HISTORY:
  ;     Kyle R. Wodzicki 2018-20-26, adapted from Kenneth Bowman, 1999-04.
  ;-
  COMPILE_OPT IDL2
  void = self->IDL_Object::Init()
  IF (N_PARAMS() LT 6) THEN second = 0																	;Default value for second
  IF (N_PARAMS() LT 5) THEN minute = 0																	;Default value for minute
  IF (N_PARAMS() LT 4) THEN hour   = 0																	;Default value for hour
  IF (N_PARAMS() LT 3) THEN day    = 1																	;Default value for day
  IF (N_PARAMS() LT 2) THEN month  = 1																	;Default value for month
  IF (N_PARAMS() LT 1) THEN year   = 1																	;Default value for year
  
  IF((month  LT 1) OR (month  GT 12)) THEN MESSAGE, 'Month out of range in MAKE_DATE.'	;Check month range
  IF((day    LT 1) OR (day    GT 31)) THEN MESSAGE, 'Day out of range in MAKE_DATE.'		;Check day range
  IF((hour   LT 0) OR (hour   GT 23)) THEN MESSAGE, 'Hour out of range in MAKE_DATE.'		;Check hour range
  IF((minute LT 0) OR (minute GT 59)) THEN MESSAGE, 'Minute out of range in MAKE_DATE.'	;Check minute range
  IF((second LT 0) OR (second GT 59)) THEN MESSAGE, 'Second out of range in MAKE_DATE.'	;Check second range

  self.YEAR    = year
  self.MONTH   = month
  self.DAY     = day
  self.HOUR    = hour
  self.MINUTE  = minute
  self.SECOND  = second
  self.NO_LEAP = KEYWORD_SET(no_leap)
  RETURN, 1
END

;===============================================================================
PRO DATETIME::Cleanup
  COMPILE_OPT IDL2
  ; Call our superclass Cleanup method
  self->IDL_Object::Cleanup
END

;===============================================================================
PRO DATETIME::SetProperty, $
  YEAR   = year, $
  MONTH  = month, $
  DAY    = day, $
  HOUR   = hour, $
  MINUTE = minute, $
  SECOND = second, $
  NO_LEAP = no_leap

  COMPILE_OPT IDL2
  ; If user passed in a property, then set it.
  IF ISA(year)    THEN self.YEAR    = year
  IF ISA(month)   THEN self.MONTH   = month
  IF ISA(day)     THEN self.DAY     = day
  IF ISA(hour)    THEN self.HOUR    = hour
  IF ISA(minute)  THEN self.MINUTE  = minute
  IF ISA(second)  THEN self.SECOND  = second
  IF ISA(no_leap) THEN self.NO_LEAP = no_leap
END

;===============================================================================
PRO DATETIME::GetProperty, $
  YEAR    = year, $
  MONTH   = month, $
  DAY     = day, $
  HOUR    = hour, $
  MINUTE  = minute, $
  SECOND  = second, $
  NO_LEAP = no_leap
  
  COMPILE_OPT IDL2
  ; If user passed in a property, then set it.
  IF ISA(self) THEN BEGIN
    IF ARG_PRESENT(year)    THEN year   = self.YEAR
    IF ARG_PRESENT(month)   THEN month  = self.MONTH
    IF ARG_PRESENT(day)     THEN day    = self.DAY
    IF ARG_PRESENT(hour)    THEN hour   = self.HOUR
    IF ARG_PRESENT(minute)  THEN minute = self.MINUTE
    IF ARG_PRESENT(second)  THEN second = self.SECOND
    IF ARG_PRESENT(no_leap) THEN no_leap = self.NO_LEAP
  ENDIF
END

;===============================================================================
FUNCTION DATETIME::Now, UTC = utc
  ;+
  ; Name:
  ;   Now
  ; Purpose:
  ;   A static method of the DATETIME class that will create a datetime object
  ;   using the current time
  ; Inputs:
  ;   None.
  ; Outputs:
  ;   Returns a datetime object with the current time
  ; Keywords:
  ;   UTC  : Set to use UTC time
  ; Author and history:
  ;   Kyle R. Wodzicki   created 2018-10-26
  ;-
  COMPILE_OPT IDL2, STATIC
  CALDAT, SYSTIME(/JULIAN, UTC=utc), mm, dd, yy, hr, mn, sc
  RETURN, DATETIME(yy, mm, dd, hr, mn, sc)
END

;===============================================================================
FUNCTION DATETIME::Read_ISO_Date_String, date_string, NO_LEAP = no_leap
  ; NAME:
  ;		Read_ISO_Date_String
  ; PURPOSE:
  ;		This method reads an ISO 8601 formatted date string and converts 
  ;		it to a datetime object
  ; CATEGORY:
  ;		Date and time calculations.
  ; CALLING SEQUENCE:
  ;		date = READ_ISO_DATE_STRING(date_string)
  ; INPUT:
  ;		String containing the date as yyyy-mm-dd hh:mm:ss or other ISO variants.
  ;		Examples: 	2001-01-01 12:33:17
  ;						2001-01-01 12Z			(PRECISION = 'hour', /UTC)
  ;						20010101T123317Z		(/COMPACT, /UTC)
  ; OUTPUT:
  ;		date     : a cdate or cdate_noleap structure containing year, month, day, hour, minute, and second
  ; KEYWORDS:
  ;		no_leap  : if set, create a CDATE_NOLEAP structure (e.g., for CCM3 calendars).
  ; COMMON BLOCKS:
  ;		None.
  ; RESTRICTIONS:
  ;		This function assumes that the ISO date string always has the most significant part of the date.
  ;		It could have, for example, year only; year and month; year, month, and day; etc.  It cannot
  ;		have month only (without year) etc.
  ;		If the time has a UTC indicator (Z suffix), it is ignored.
  ; MODIFICATION HISTORY:
  ;		K. Bowman, 2002-02-21.
  ;   Adapted to DATETIME method by Kyle R. Wodzicki   2018-20-26
  ;-
  
  COMPILE_OPT IDL2, STATIC																						;Set compile options
  
  standard_format = "(I4,5(1X,I2))"																;Standard input format
  compact_format  = "(I4,2I2,1X,3I2)"																;Compact input format
  
  year		= 0																							;Define variable type
  month		= 1																							;Define variable type and set default value
  day		  = 1																							;Define variable type and set default value
  hour		= 0																							;Define variable type and set default value
  minute	= 0																							;Define variable type and set default value
  second	= 0																							;Define variable type and set default value
  
  len      = STRLEN(date_string)																	;Length of date_string
  zpos     = STRPOS(date_string, 'Z')																;Check for Z character
  IF (zpos NE -1) THEN len = len - 1																;Don't include Z character in length
  
  IF (len EQ 4) THEN BEGIN																			;String contains only year
  	READS, date_string, year, FORMAT = standard_format										;Read year
  	RETURN, MAKE_DATE(year, month, day, hour, minute, second, NO_LEAP = no_leap)	;Make date structure and return
  ENDIF
  
  seppos = STRPOS(date_string, '-')
  IF (seppos EQ -1) THEN BEGIN																		;Read compact format
  	CASE len OF
  		4    : READS, date_string, year,                                   FORMAT = compact_format
  		6    : READS, date_string, year, month,                            FORMAT = compact_format
  		8    : READS, date_string, year, month, day,                       FORMAT = compact_format
  		11   : READS, date_string, year, month, day, hour,                 FORMAT = compact_format
  		13   : READS, date_string, year, month, day, hour, minute,         FORMAT = compact_format
  		ELSE : READS, date_string, year, month, day, hour, minute, second, FORMAT = compact_format
  	ENDCASE
  ENDIF ELSE BEGIN																						;Read standard format
  	CASE len OF
  		4    : READS, date_string, year,                                   FORMAT = standard_format
  		7    : READS, date_string, year, month,                            FORMAT = standard_format
  		10   : READS, date_string, year, month, day,                       FORMAT = standard_format
  		13   : READS, date_string, year, month, day, hour,                 FORMAT = standard_format
  		16   : READS, date_string, year, month, day, hour, minute,         FORMAT = standard_format
  		ELSE : READS, date_string, year, month, day, hour, minute, second, FORMAT = standard_format
  	ENDCASE
  ENDELSE
  RETURN, DATETIME(year, month, day, hour, minute, second, NO_LEAP = no_leap)		;Make date structure and return
END

;===============================================================================
FUNCTION DATETIME::Make_ISO_Date_String, $
  PRECISION = precision, $
  COMPACT   = compact, $
  UTC       = utc
  ; NAME:
  ;   Make_ISO_Date_String
  ; PURPOSE:
  ;	 Method of the DATETIME class to convert date to an ISO 8601 string representation.
  ; CATEGORY:
  ;	 Date and time calculations.
  ; CALLING SEQUENCE:
  ;	 date_string = datetime.ISO_DATE_STRING()
  ; INPUT:
  ;	 None.
  ; OUTPUT:
  ;	 String containing the date as yyyy-mm-dd hh:mm:ss or other ISO variants.
  ;   Examples:  2001-01-01 12:33:17
  ;              2001-01-01 12Z			(PRECISION = 'hour', /UTC)
  ;              20010101T123317Z		(/COMPACT, /UTC)
  ; KEYWORDS:
  ;	 precision : Optional keyword to set the desired precision.  Acceptable values are
  ;               'year', 'month', 'day', 'hour', 'minute', 'second'.  Other values are
  ;               ignored.  Not case sensitive.
  ;	 compact   : If set, use compact notation.  (Omit date and time separators, use 'T' to separate
  ;               date from time
  ;	 UTC       : If set, 'Z' is added after the time to indicate that the time is UTC.
  ; COMMON BLOCKS:
  ;	 None.
  ; RESTRICTIONS:
  ;	 None.
  ; MODIFICATION HISTORY:
  ;   Kenneth Bowman, 2001-09-10.
  ;   Adapted to datetime class by Kyle R. Wodzicki   2018-10-26
  ;-
  COMPILE_OPT IDL2

  year    = STRING(self.year,   FORMAT = "(I4.4)")
  month   = STRING(self.month,  FORMAT = "(I2.2)")
  day     = STRING(self.day,    FORMAT = "(I2.2)")
  hour    = STRING(self.hour,   FORMAT = "(I2.2)")
  minute  = STRING(self.minute, FORMAT = "(I2.2)")
  second  = STRING(self.second, FORMAT = "(I2.2)")

  IF KEYWORD_SET(compact) THEN BEGIN															;Define separators for compact notation
    date_sep      = ''
    time_sep      = ''
    date_time_sep = 'T'
  ENDIF ELSE BEGIN																					;Define separators for standard notation
    date_sep      = '-'
    time_sep      = ':'
    date_time_sep = ' '
  ENDELSE

  IF KEYWORD_SET(utc) THEN suffix = 'Z' ELSE suffix = ''

  IF KEYWORD_SET(precision) THEN BEGIN
    CASE STRUPCASE(precision) OF
      'YEAR'   : RETURN, year
      'MONTH'  : RETURN, year + date_sep + month
      'DAY'    : RETURN, year + date_sep + month  + date_sep + day
      'HOUR'   : RETURN, year + date_sep + month  + date_sep + day + date_time_sep + hour + suffix
      'MINUTE' : RETURN, year + date_sep + month  + date_sep + day + date_time_sep + hour + time_sep + minute + suffix
      'SECOND' : RETURN, year + date_sep + month  + date_sep + day + date_time_sep + hour + time_sep + minute + time_sep + second + suffix
		  ELSE     : RETURN, year + date_sep + month  + date_sep + day + date_time_sep + hour + time_sep + minute + time_sep + second + suffix
    ENDCASE
  ENDIF ELSE BEGIN
    RETURN, year + date_sep + month  + date_sep + day + date_time_sep + hour + time_sep + minute + time_sep + second + suffix
  ENDELSE
END

;===============================================================================
FUNCTION DATETIME::ToJULDAY
  ;+
  ; Name:
  ;   ToJULDAY
  ; Purpose:
  ;   Method return julian date of current date in object
  ; Inputs:
  ;   None.
  ; Outputs:
  ;   Returns Julian date
  ; Keywords:
  ;   None.
  ; Author and history:
  ;   Kyle R. Wodzicki   created 2018-10-26
  ;-
  COMPILE_OPT IDL2
  RETURN, JULDAY(self.MONTH, self.DAY, self.YEAR, self.HOUR, self.MINUTE, self.SECOND)
END

;===============================================================================
FUNCTION DATETIME::FromJULDAY, julianDay
  ;+
  ; Name:
  ;   FromJULDAY
  ; Purpose:
  ;   Method update date given a julian date
  ; Inputs:
  ;   None.
  ; Outputs:
  ;   Returns Julian date
  ; Keywords:
  ;   None.
  ; Author and history:
  ;   Kyle R. Wodzicki   created 2018-10-26
  ;-
  COMPILE_OPT IDL2, STATIC
  CALDAT, julianDay, mm, dd, yy, hr, mn, sc
  RETURN, {YEAR    : yy, $
           MONTH   : mm, $
           DAY     : dd, $
           HOUR    : hr, $
           MINUTE  : mn, $
           SECOND  : ROUND(sc)}
END

;===============================================================================
PRO DATETIME::TIMEDELTA, $
  DAYS     = days, $
  MINUTES  = mintues, $
  SECONDS  = seconds
  ;+
  ; Name:
  ;   TIMEDELTA
  ; Purpose:
  ;   Method to increment the time by given amount
  ; Inputs:
  ;   None.
  ; Outputs:
  ;   Returns a datetime object with the current time
  ; Keywords:
  ;   DAYS    : Number of days to increment
  ;   MINUTES : Number of minutes to increment
  ;   SECONDS : Number of seconds to increment
  ; Author and history:
  ;   Kyle R. Wodzicki   created 2018-10-26
  ;-
  COMPILE_OPT IDL2
  delta = 0.0D
  IF N_ELEMENTS(days)    GT 0 THEN delta += days
  IF N_ELEMENTS(minutes) GT 0 THEN delta += minutes /  3600.0
  IF N_ELEMENTS(seconds) GT 0 THEN delta += seconds / 86400.0
  self->SetProperty, _EXTRA = self.FROMJULDAY( self.TOJULDAY() + delta )
END

;===============================================================================
FUNCTION DATETIME::TIME_DIFF, t1, CHECK = check, $
  DAYS     = days, $
  MINUTES  = mintues
  ;+
  ;NAME:
  ;		TIME_DIFF
  ;PURPOSE:
  ;		A method to compute the time difference in seconds between two datetime
  ;   objects expressed as Julian day and seconds.
  ;CATEGORY:
  ;		Date and time calculations.
  ;CALLING SEQUENCE:
  ;		dt = TIME_DIFF(t1, t0)
  ;INPUT:
  ;		t1  : structure {jtime, jday: 0L, seconds: 0L} 
  ;				containing the date as Julian day and seconds from midnight
  ;				or CDATE or CDATE_NO_LEAP structure
  ;OUTPUT:
  ;		dt  : time difference in seconds between t1 and t0 (64-bit integer)
  ;KEYWORDS:
  ;		check  : If set, input parameter range checking is turned on.
  ;					Check can also be set to a two-element array containing
  ;					the lower and upper limts on the Julian day.
  ;   days   : Set to return time difference in days. Default is seconds
  ;   minutes: Set to return time difference in minutes. Default is seconds
  ;   
  ;PROCEDURE:
  ;		This function does some simple range checking on the input parameters
  ;		and then computes the time difference.  The expression for the time
  ;		difference is arranged to reduce the possibility of overflow errors.
  ;MODIFICATION HISTORY:
  ;     KPB, 1995-08.
  ;     KPB, 2001-09-12.  Updated to handle CDATE structures as well as JTIME structures.
  ;     Adapted to DATETIME class by Kyle R. Wodzicki   2018-20-26
  ;-
  COMPILE_OPT IDL2
    
;  IF KEYWORD_SET(check) THEN BEGIN                                 ;Check input parameters
;     IF(N_ELEMENTS(check) EQ 1) THEN BEGIN
;        jdaymin = JULDAY(1, 1, 1900)                               ;Default lower limit on Julian day
;        jdaymax = JULDAY(1, 1, 2100)                               ;Default upper limit on Julian day
;     ENDIF ELSE BEGIN
;        jdaymin = check(1)
;        jdaymax = check(2)
;     ENDELSE
;     IF((t1_temp.jday LT jdaymin) OR (t1_temp.jday GT jdaymax)) THEN $       ;Check Julian day
;        MESSAGE, 'Julian day out of range, t1 in TRAJ3D_TIME_DIFF'
;     IF((t1_temp.seconds LT 0L) OR (t1_temp.seconds GT 86399L)) THEN $       ;Check seconds
;        MESSAGE, 'Seconds out of range, t1 in TRAJ3D_TIME_DIFF'
;     IF((t0_temp.jday LT jdaymin) OR (t0_temp.jday GT jdaymax)) THEN $       ;Check Julian day
;        MESSAGE, 'Julian day out of range, t0 in TRAJ3D_TIME_DIFF'
;     IF((t0_temp.seconds LT 0L) OR (t0_temp.seconds GT 86399L)) THEN $       ;Check seconds
;        MESSAGE, 'Seconds out of range, t0 in TRAJ3D_TIME_DIFF'
;  ENDIF

  diff = ROUND( t1.ToJULDAY() - self.ToJULDAY() )
  
  IF KEYWORD_SET(days) THEN $
    RETURN, diff $
  ELSE IF KEYWORD_SET(mintues) THEN $
    RETURN, diff * 1440 $
  ELSE $
    RETURN, diff * 86400  
END
 
;===============================================================================
FUNCTION DATETIME::CALDAY
  COMPILE_OPT IDL2
  RETURN, JULDAY(self.MONTH, self.DAY, self.YEAR) - JULDAY(1, 1, self.YEAR) + 1
END

;===============================================================================
PRO DATETIME__define
  COMPILE_OPT IDL2, HIDDEN
  void = {DATETIME, $
    INHERITS IDL_Object, $
    year    : 1900, $
    month   :    1, $
    day     :    1, $
    hour    :    0, $
    minute  :    0, $
    second  :    0, $
    no_leap :    0}
END