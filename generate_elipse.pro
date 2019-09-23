FUNCTION GENERATE_ELIPSE, majorIn, minorIn, $
	N      = n, $
	ANGLE  = angle, $
	DEGREE = degree, $
	CENTER = center, $
	LONLAT = lonlat, $
	METERS = meters, $
	DOUBLE = double
;+
; Name:
;   GENERATE_ELIPSE
; Purpose:
;   An IDL function to generate an elipse based on the major and minor axes.
; Inputs:
;   majorIn  : Length of the major axis. Units of km (m if METERS keyword set)
;   minorIn  : Length of the minor axis. Units of km (m if METERS keyword set)
; Outputs:
;  	Outputs an nx2 array where the first row is along major axis and second is
;    along minor axis
; Keywords:
;   N     : Sets the number of points to use when building the elipse. 
;            NOTE that n+1 points are returned; needed to close elipse.
;            N MUST BE > 3
;            Default is 100.
;  ANGLE  : Set the angle of the elipse. Positive angle is counter clockwise.
;  DEGREE : Set if the angle input is in degrees
;  CENTER : Set the center of the elipse [x, y] OR [lon, lat]
;  LONLAT : Set if CENTER is longitude/latitude pair.
;  METERS : Set if majorIn and minorIn are in meters.
;  DOUBLE : Set to return double precision values.
; Author and History:
;   Kyle R. Wodzicki     Created 18 May 2017
;-
COMPILE_OPT IDL2

IF N_PARAMS()        NE 2 THEN MESSAGE, 'Incorrect number of inputs!'
IF N_ELEMENTS(n)     EQ 0 THEN n = 100 ELSE IF n LE 3 THEN n = 100

type = KEYWORD_SET(double) ? 5 : 4
out  = MAKE_ARRAY(n+1, 2, TYPE = type)
majorH = FIX(majorIn, TYPE = type) / 2
minorH = FIX(minorIn, TYPE = type) / 2
dMajor = majorIn / FIX(n/2, TYPE = type)

major  = INDGEN(n/2+1, TYPE = type) * dMajor - majorH
minor  = minorH * SQRT(1 - (major/majorH)^2)
out[0,0]     = major
out[0,1]     = minor
out[n/2+1,0] = REVERSE(major[0:-2])
out[n/2+1,1] = -REVERSE(minor[0:-2])

IF N_ELEMENTS(angle) NE 0 THEN BEGIN
	IF KEYWORD_SET(angle) THEN angle = FIX(angle * !DPI/180.0D0, TYPE = type)
	mag      = SQRT( out[*,0]^2 + out[*,1]^2 )							; Determine magnitudes 
	theta    = ATAN( out[*,1], out[*,0] ) + angle						; Compute new angle
	out[0,0] = mag * COS( theta )
	out[0,1] = mag * SIN( theta )
ENDIF

IF N_ELEMENTS(center) EQ 2 THEN BEGIN
	IF NOT KEYWORD_SET(lonlat) THEN $
		out = TEMPORARY(out) + REBIN(REFORM(center,1,2),n+1,2) $										; Simply add the center point to the values
	ELSE BEGIN
		mag      = SQRT( out[*,0]^2 + out[*,1]^2 )							; Determine magnitudes 
		theta    = ATAN( out[*,1], out[*,0] )										; Compute new angle
		IF KEYWORD_SET(meters) THEN mag = TEMPORARY(mag) / 1.0E3
		cent = KEYWORD_SET(degree) ? center * !DPI / 180.0D0 : center
		FOR i = 0, n DO $
			out[i,*] = LL_ARC_DISTANCE(cent, mag[i]/6371.008D0, -theta[i])
		out[0,0] = out * 180.0D0 / !DPI
	ENDELSE
ENDIF

RETURN, out

END