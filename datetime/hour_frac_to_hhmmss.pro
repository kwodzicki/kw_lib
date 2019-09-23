FUNCTION HOUR_FRAC_TO_HHMMSS, time_in
;+
; Name:
;   HOUR_FRAC_TO_HHMMSS
; Purpose:
;   A function to calculate the hour, minutes, and seconds from
;   a fractional hour input. Seconds are rounded
; Inputs:
;   time_in  : A scalar or array of fractional hours.
; Outputs:
;   Returns an n x 3 array of hour, minutes, and seconds.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 11 Nov. 2015
;-

COMPILE_OPT IDL2

dims = SIZE(time_in, /DIMENSIONS)
id   = WHERE(FINITE(time_in), CNT, COMPLEMENT=cID, NCOMPLEMENT=cCNT)
hour = FLOAT(FLOOR(time_in))    ; Get the full hour
frac = time_in - hour           ; Get the fraction of the hour
min  = FLOAT(FLOOR(60.0 * frac))
sec  = FLOAT(ROUND((3600.0*frac)/60.0))
IF (cCNT GT 0) THEN BEGIN
  hour[cid] = !Values.F_NaN
  min[cid]  = !Values.F_NaN
  sec[cid]  = !Values.F_NaN
ENDIF
;PRINT, hour
out  = LIST()
out.ADD, hour, /NO_COPY
out.ADD, min,  /NO_COPY
out.ADD, sec,  /NO_COPY


RETURN, out.ToArray(/TRANSPOSE)

END