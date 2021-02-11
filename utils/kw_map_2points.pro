; $Id: //depot/Release/ENVI51_IDL83/idl/idldir/lib/map_2points.pro#1 $
;
; Copyright (c) 2000-2013, Exelis Visual Information Solutions, Inc. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	Map_2Points
;
; PURPOSE:
;	Return parameters such as distance, azimuth, and path relating to
;	the great circle or rhumb line connecting two points on a sphere.
;
; CATEGORY:
;	Maps.
;
; CALLING SEQUENCE:
;	Result = Map_2Points(lon0, lat0, lon1, lat1)
; INPUTS:
;	Lon0, Lat0 = longitude and latitude of first point, P0.
;	Lon1, Lat1 = longitude and latitude of second point, P1.
;
; KEYWORD PARAMETERS:
;   RADIANS = if set, inputs and angular outputs are in radians, otherwise
;	degrees.
;   NPATH, DPATH = if set, return a (2, n) array containing the
;	longitude / latitude of the points on the great circle or rhumb
;	line connecting P0 and P1.  If NPATH is set, return NPATH equally
;	spaced points.  If DPATH is set, it specifies the maximum angular
;	distance between the points on the path in the prevalent units,
;	degrees or radians.
;   PARAMETERS: if set, return [SIN(c), COS(c), SIN(az), COS(az)]
;	the parameters determining the great circle connecting the two
;	points.  c is the great circle angular distance, and az is the
;	azimuth of the great circle at P0, in degrees east of north.
;   METERS: Return the distance between the two points in meters,
;	calculated using the Clarke 1866 equatorial radius of the earth.
;   MILES: Return the distance between the two points in miles,
;	calculated using the Clarke 1866 equatorial radius of the earth.
;   RADIUS: If given, return the distance between the two points
;	calculated using the given radius.
;   RHUMB: Set this keyword to return the distance and azimuth of the
;	rhumb line connecting the two points, P0 to P1. The default is to
;	return the distance and azimuth of the great circle connecting the
;	two points.  A rhumb line is the line of constant direction
;	connecting two points.
;
; OUTPUTS:
;	If the keywords NPATH, DPATH, METERS, MILES, or RADIUS, are not
;	specified, the function result is a two element vector containing
;	the distance and azimuth of the great circle or rhumb line
;	connecting the two points, P0 to P1, in the specified angular units.
;
;	If MILES, METERS, or RADIUS is not set, Distances are angular
;	distance, from 0 to 180 degrees (or 0 to !pi if the RADIANS keyword
;	is set), and Azimuth is measured in degrees or radians, east of north.
;
; EXAMPLES:
;	Given the geocoordinates of two points, Boulder and London:
;	B = [ -105.19, 40.02]	;Longitude, latitude in degrees.
;	L = [ -0.07,   51.30]
;
;	PRINT, Map_2Points(B[0], B[1], L[0], L[1])
; prints: 67.854333 40.667833 for the angular distance and
; azimuth, from B, of the great circle connecting the two
; points.
;
;	PRINT, Map_2Points(B[0], B[1], L[0], L[1],/RHUMB)
; prints 73.966280 81.228056, for the angular distance and
; course (azimuth), connecting the two points.
;
;	PRINT, Map_2Points(B[0], B[1], L[0], L[1],/MILES)
; prints:  4693.5845 for the distance in miles between the two points.
;
;	PRINT, Map_2Points(B[0], B[1], L[0], L[1], /MILES,/RHUMB)
; prints: 5116.3569, the distance in miles along the rhumb line
; connecting the two points.
;
; The following code displays a map containing the two points, and
; annotates the map with both the great circle and the rhumb line path
; between the points, drawn at one degree increments.
;	MAP_SET, /MOLLWEIDE, 40,-50, /GRID, SCALE=75e6,/CONTINENTS
;	PLOTS, Map_2Points(B[0], B[1], L[0], L[1],/RHUMB, DPATH=1)
;	PLOTS, Map_2Points(B[0], B[1], L[0], L[1],DPATH=1)
;
;
; MODIFICATION HISTORY:
; 	Written by:
;	DMS, RSI	May, 2000. Written.
;   CT, RSI, September 2001: For /RHUMB, reduce lon range to -180,+180
;   CT, RSI, September 2002: For /RHUMB, fix computation at poles.
; Kyle R Wodzicki, Modified to handle vectors using a where statement.
;   changed names so that I could edit.
;   Added kilometers keyword
;-

Function kw_Map_2points, in_lon0, in_lat0, in_lon1, in_lat1, $
            DPATH=dPath, $
            METERS=meters, $
            KILOMETERS=kilometers, $
            MILES=miles, $
            NPATH=nPath, $
            PARAMETERS=p, $
            RADIANS=radians, $
            RADIUS=radius, $
            RHUMB=rhumb

COMPILE_OPT idl2
ON_ERROR, 2  ; return to caller

IF N_PARAMS() EQ 4 THEN BEGIN
  lon0=in_lon0 & lat0=in_lat0 & lon1=in_lon1 & lat1=in_lat1
ENDIF ELSE $
IF N_PARAMS() EQ 3 THEN BEGIN
  lon0=in_lon0 & lat0=in_lat0 & lon1=in_lon1
ENDIF ELSE MESSAGE, 'Incorrect number of inputs!'

IF (lat1 EQ !NULL) THEN BEGIN
	IF ~KEYWORD_SET(lat) THEN BEGIN
		lat1 = lon1
		lon1 = lon0
	ENDIF ELSE BEGIN
		lat1 = lon0
		lon0 = lat0
		lat0 = lat1
	ENDELSE
ENDIF

;=== Check size of arrays
nLon0 = N_ELEMENTS(lon0) & nLat0 = N_ELEMENTS(lat0)
nLon1 = N_ELEMENTS(lon1) & nLat1 = N_ELEMENTS(lat1)

IF (nLon0 NE nLat0) THEN $
  MESSAGE, 'Lat/Lon of first point(s) MUST be same size!'
IF (nLon1 NE nLat1) THEN $
  MESSAGE, 'Lat/Lon of second point(s) MUST be same size!'
;=== Rebin arrays to match each other
IF (nLon0 EQ 1) THEN BEGIN
  lon0 = REBIN([lon0], nLon1) & lat0 = REBIN([lat0], nLon1)
ENDIF
IF (nLon1 EQ 1) THEN BEGIN
  lon1 = REBIN([lon1], nLon0) & lat1 = REBIN([lat1], nLon0)
ENDIF


mx = MAX(ABS([lat0,lat1]))
pi2 = !DPI/2
IF (mx GT (KEYWORD_SET(radians) ? pi2 : 90)) THEN $
	MESSAGE, 'Value of Latitude is out of allowed range.'
IF (N_ELEMENTS(nPath) GT 0) THEN IF (nPath LT 2) THEN $
	MESSAGE, 'Illegal keyword value for NPATH.'

k = KEYWORD_SET(radians) ? 1.0d0 : !DPI/180.0
r_earth = 6378206.4D0 ;Earth equatorial radius, meters, Clarke 1866 ellipsoid

IF KEYWORD_SET(rhumb) THEN BEGIN ;Rhumb line section
    x1 = (lon1-lon0)*k          ;Delta longit, to radians
    WHILE (x1 LT -!Dpi) DO x1 = x1 + 2*!DPI ;Reduce to -180 + 180.
    WHILE (x1 GE  !Dpi) DO x1 = x1 - 2*!DPI
    lr0 = lat0 * k
    lr1 = lat1 * k

    ; Mercator y coordinates. Avoid computing alog(0).
    y0 = ALOG(TAN(!dpi/4 + lr0 / 2) > 1d-300)
    y1 = ALOG(TAN(!dpi/4 + lr1 / 2) > 1d-300)

    Az = ATAN(x1, y1-y0)
; S is the angular distance between points, in radians.
    s = (lr0 NE lr1) ? (lr1-lr0)/COS(Az) : ABS(x1) * COS(lr0)

    IF KEYWORD_SET(nPath) or KEYWORD_SET(dPath) THEN BEGIN ;Compute a path?
        n = KEYWORD_SET(dPath) ? CEIA(s / (dPath*k)) > 2 : (nPath > 2)
        x = DINDGEN(n) * (x1 / (n-1))
        y = y0 + DINDGEN(n) * ((y1-y0) / (n-1))
        lat = pi2 - 2 * ATAN(EXP(-y))
        lon = x + lon0*k
        RETURN, TRANSPOSE([[lon/k], [lat/k]])
    ENDIF
    IF KEYWORD_SET(radius) THEN $ ;Radius supplied? Return distance.
      RETURN, s * radius
    IF KEYWORD_SET(meters) THEN $ ;Meters?
      RETURN, s * r_earth
    IF KEYWORD_SET(kilometers) THEN $   ;Kiloeters?
      RETURN, aCOS(cosc) * r_earth *1.0D-03
    IF KEYWORD_SET(miles) THEN $ ;Miles?
      RETURN, s * r_earth * 0.6213712d-3 ;Meters->miles
    RETURN, [s/k, Az/k]         ;Return distance, course (azimuth)
ENDIF


coslt1 = COS(k*lat1)
sinlt1 = SIN(k*lat1)
coslt0 = COS(k*lat0)
sinlt0 = SIN(k*lat0)

cosl0l1 = COS(k*(lon1-lon0))
sinl0l1 = SIN(k*(lon1-lon0))

cosc = sinlt0 * sinlt1 + coslt0 * coslt1 * cosl0l1 ;Cos of angle between pnts
; Avoid roundoff problems by clamping cosine range to [-1,1].
;  Also added check for finite values to eliminate illegal operand errors
fid  = WHERE(FINITE(cosc), CNT)
IF (CNT GT 0) THEN $
  cosc[fid] = -1 > cosc[fid] < 1 $
ELSE BEGIN
  RETURN, !Values.F_NaN
ENDELSE

sinc = sqrt(1.0 - cosc^2)

;=== Initialize the arrays
cosaz = DBLARR(N_ELEMENTS(cosc))
sinaz = DBLARR(N_ELEMENTS(sinc))
id = WHERE(ABS(sinc) GT 1.0e-7, CNT, COMPLEMENT=cID, NCOMPLEMENT=cCNT) ;Small angle?
IF (CNT GT 0) THEN BEGIN
    cosaz[id] = (coslt0[id] * sinlt1[id] - sinlt0[id]*coslt1[id]*cosl0l1[id]) / sinc[id] ;Azmuith
    sinaz[id] = sinl0l1[id] * coslt1[id]/sinc[id]
ENDIF
IF (cCNT GT 0) THEN BEGIN		;Its antipodal
    cosaz[cID] = 1.0
    sinaz[cID] = 0.0
ENDIF

;if abs(sinc) gt 1.0e-7 THEN BEGIN ;Small angle?
;    cosaz = (coslt0 * sinlt1 - sinlt0*coslt1*cosl0l1) / sinc ;Azmuith
;    sinaz = sinl0l1*coslt1/sinc
;ENDIF else begin		;Its antipodal
;    cosaz = 1.0
;    sinaz = 0.0
;endelse

IF KEYWORD_SET(print) THEN BEGIN
    PRINT, 'Great circle distance: ', ACOS(cosc) / k
    PRINT, 'Azimuth: ', ATAN(sinaz, cosaz)/k
ENDIF

IF KEYWORD_SET(p) THEN $        ;Return parameters of great circle?
  RETURN, [sinc, cosc, sinaz, cosaz] ;Return parameters

IF KEYWORD_SET(nPath) or KEYWORD_SET(dPath) THEN BEGIN ;Compute a path?
    s = ACOS(cosc)              ;Angular distance between points
    IF KEYWORD_SET(nPath) THEN BEGIN ;Desired # of elements req?
        s0 = DINDGEN(nPath > 2) * (s / (nPath > 2 -1))
    ENDIF else begin            ;Distance between pnts specified..
        delc = dPath * k        ;Angle between points
        s0 = DINDGEN(CEIL(s / delc) + 1) * delc < s ;Last step might be smaller
    endelse

    sins = SIN(s0)
    coss = COS(s0)
    lats = ASIN(sinlt0 * coss + coslt0 * sins * cosaz) / k
    lons = lon0 + ATAN(sins * sinaz, coslt0 * coss - sinlt0 * sins * cosaz)/k
    RETURN, TRANSPOSE([[lons], [lats]])
ENDIF

IF KEYWORD_SET(radius) THEN $   ;Radius supplied? Return distance.
  RETURN, ACOS(cosc) * radius
IF KEYWORD_SET(meters) THEN $   ;Meters?
  RETURN, ACOS(cosc) * r_earth
IF KEYWORD_SET(kilometers) THEN $   ;Kiloeters?
  RETURN, ACOS(cosc) * r_earth *1.0D-03
IF KEYWORD_SET(miles) THEN $    ;Miles?
  RETURN, ACOS(cosc) * r_earth * 0.6213712d-3 ;Meters->miles

RETURN, [ACOS(cosc) / k, ATAN(sinaz, cosaz) / k] ;Return distance, azimuth
END
