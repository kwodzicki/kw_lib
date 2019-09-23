FUNCTION EARTH_RADIUS, phi, $
  METER  = meter, $
  DEGREE = degree, $
  DOUBLE = double
;+
; Name:
;   EARTH_RADIUS
; Purpose:
;   A function to return the radius of the earth at a given latitude.
;   Earth radii and geocentric radius formula found at:
;   https://en.wikipedia.org/wiki/Earth_radius
; Inputs:
;   phi : Latitude to calculate radius at.
; Outputs:
;   Returns the radius in meters or kilometers depending on the 
;   keywords set.
; Keywords:
;   METER  : Set to return the radius in meters. Default is kilometers
;   DEGREE : Set if latitude input is in degrees.
;   DOUBLE : Set to perform all calculations using double precision.
; Author and History:
;   Kyle R. Wodzicki     Created 11 Apr. 2016
;-
  COMPILE_OPT IDL2
  
  IF KEYWORD_SET(double) THEN BEGIN
    a    = 6378.1370D00^2                                  ; Radius of earth at equator squared
    b    = 6356.7523D00^2                                  ; Radius of earth at pole squared
    c    = !DPI/1.8D02                                     ; Conversion for degrees to radians
    phi0 = FIX(phi, TYPE=5)                                ; Ensure that phi is of type double
  ENDIF ELSE BEGIN
    a    = 6378.1370E00^2                                  ; Radius of earth at equator squared
    b    = 6356.7523E00^2                                  ; Radius of earth at pole squared
    c    = !PI/1.8E02                                      ; Conversion for degrees to radians
    phi0 = FIX(phi, TYPE=4)                                ; Ensure that phi is of type float
  ENDELSE
  
  IF KEYWORD_SET(degree) THEN phi0 = TEMPORARY(phi0) * c   ; If phi is in degrees then convert to radians

  cos_phi = COS(phi0)^2                                    ; Compute cos(phi)^2
  sin_phi = SIN(phi0)^2                                    ; Compute sin(phi)^2
  
 r = SQRT( ( a^2 * cos_phi + b^2 * sin_phi ) / $           ; Compute radius of the earth at each phi
           ( a   * cos_phi + b   * sin_phi )  )

  IF KEYWORD_SET(meter) THEN $                             ; Return as in units of meters
    RETURN, r * 10^3 $
  ELSE $                                                   ; Return as in units of kilometers
    RETURN, r
END