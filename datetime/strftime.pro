FUNCTION STRFTIME, julian, format
;+
; Function to replicate the datetime.datetime.strftime() method from
; python standard library
;-
COMPILE_OPT IDL2

JUL2GREG, julian, mm, dd, yy, hr, mn, sc
yearStart   = GREG2JUL(1, 1, yy, 0, 0, 0)-1.0
microSecond = (sc - FLOOR(sc)) * 1.0D6
dOWeek      = DAYOFWEEK(yy, mm, dd)

months  = ['January',   'February', 'March',    'April', $
           'May',       'June',     'July',     'August', $
           'Septebmer', 'October',  'November', 'December']
months2 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',  'Nov', 'Dec']

days    = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', $
           'Thursday', 'Friday', 'Saturday']
days2   = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

outSTR = ''
i      = 0
WHILE i LT STRLEN(format) DO BEGIN
  tmp = STRMID(format, i, 2)
  CASE tmp OF
    '%Y' : outSTR += STRING(yy,                     FORMAT="(I04)")
    '%y' : outSTR += STRING(yy-FLOOR(yy/100.0)*100, FORMAT="(I02)")
    '%m' : outSTR += STRING(mm,                     FORMAT="(I02)")
    '%B' : outSTR += months[ mm-1]
    '%b' : outSTR += months2[mm-1]
    '%A' : outSTR += days[ doWeek]
    '%a' : outSTR += days2[doWeek]
    '%w' : outSTR += STRING(doWeek,                 FORMAT= "(I1)")
    '%d' : outSTR += STRING(dd,                     FORMAT="(I02)")
    '%j' : outSTR += STRING(julian-ref,             FORMAT="(I03)")
    '%H' : outSTR += STRING(hr,                     FORMAT="(I02)")
    '%I' : outSTR += STRING(hr MOD 13,              FORMAT="(I02)")
    '%M' : outSTR += STRING(mn,                     FORMAT="(I02)")
    '%S' : outSTR += STRING(sc,                     FORMAT="(I02)")
    '%f' : outSTR += STRING(microSecond,            FORMAT="(I06)")
    ELSE : BEGIN
             outSTR += STRMID(tmp, 0, 1)
             i      -= 1
           END
  ENDCASE
  i += 2
ENDWHILE

RETURN, outSTR

END
