PRO MASS_STREAM_FUNC, vv, in_lat, in_lvl, psi, p
;+
; Name:
;   MASS_STREAM_FUNC
; Purpose:
;   An IDL procedure to compute the zonal-mean meridional stream
;   function
; Inputs:
;   vv     : 2-D array of meridional winds
;   in_lat : A 1- or 2-D array of latitude values (degrees)
;   in_lvl : A 1- or 2-D array of pressure levels (Pa)
; Outputs:
;   psi    : The meridional mass stream function (kg s**-1)
;   p      : Pressures for the stream function (Pa)
; Keywords:
;   None.
; Author and history:
;   Kyle R. Wodzicki
;-
COMPILE_OPT IDL2

dims = SIZE(vv, /DIMENSION)                                                     ; Get dimensions of VV
IF SIZE(in_lat, /N_DIMENSIONS) EQ 1 THEN $                                      ; If the latitude is only 1-D
  lat = REBIN( in_lat, dims ) $                                                 ; Rebin to dimension of vv
ELSE $                                                                          ; Else
  lat = in_lat                                                                  ; Just use input values
IF SIZE(in_lvl, /N_DIMENSIONS) EQ 1 THEN $                                      ; If the level is only 1-D
  lvl = REBIN( REFORM( in_lvl, 1, dims[1] ), dims ) $                           ; Rebin/reform to dimension of vv
ELSE $                                                                          ; Else
  lvl = in_lvl                                                                  ; Just use input

revFlat = 0B
IF lvl[0,0] GT lvl[0,-1] THEN BEGIN                                             ; If pressure levels are decending
  revFlat = 1B
  lvl     = REVERSE( lvl, 2, /OVERWRITE)                                        ; Reverse to ascending
  vv      = REVERSE( vv,  2, /OVERWRITE)                                        ; Reverse vv too
ENDIF

dp = lvl[*,1:-1] - lvl[*,0:-2]                                                  ; Compute change in pressure between levels
dv = (vv[ *,1:-1] + vv[ *,0:-2]) / 2.0                                          ; Compute mean wind for level

p   = REFORM( (lvl[0,1:-1] + lvl[0,0:-2]) / 2.0 )                               ; Reform mean pressure for level for output
psi = 2.0 * !PI * !EARTH.AE * COS(lat*!DTOR) / !GRAVITY                         ; Compute scalar for psi equation
psi = psi * TOTAL( dv * dp, 2, /CUMULATIVE )                                    ; Multiply scalar by the integeral of vv * dp

IF revFlat EQ 1B THEN vv = REVERSE( vv,  2, /OVERWRITE)                         ; Reverse vv too

END