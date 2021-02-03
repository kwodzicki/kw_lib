PRO PLOT_AIRCRAFT, xIn, yIn, $
  ORIENTATION = orientation, $
  FILL        = fill, $
  SYMSIZE     = symsize, $
  OVERPLOT    = overplot, $
  _EXTRA      = _extra

;+
; Name:
;   Plot_AIRCRAFT
; Purpose:
;   Plot aircraft symbol at points (x,y). Plane symbol modeled after DC-8
; Inputs:
;   xIn   : X-values for aircraft location
;   yIn   : Y-values for aircraft location
; Keywords:
;   ORIENTATION : Set the direction the aircraft faces. (0; default) is norht,
;                  (180) is south, (90) is east, (270) west
;   FILL        : Set to fill the aircraft
;   SYMSIZE     : Scales the aircraft size. Default size is 3 times text character width
;   OVERPLOT    : Set to overplot on existing plot
;   _EXTRA      : Any keyword accepted by POLYFILL when FILL=1 OR
;                 Any keyword accepted by PLOTS when FILL=0
; Requirements:
;   Requires the DC8_xy.sav file
; Author and History:
;   Kyle R. Wodzicki     Created 3 Feb. 2021
;-
COMPILE_OPT IDL2

COMMON _DC8_XY, xx, yy, width                                                   ; Common so don't need to keep loading data

IF N_ELEMENTS(xx) EQ 0 THEN BEGIN
  file = FILEPATH('DC8_xy.sav', ROOT_DIR=ROUTINE_DIR())
  RESTORE, file
  width = MAX(xx) - MIN(xx)
ENDIF

IF N_PARAMS() EQ 0 THEN BEGIN                                                   ; if no arguments
  MESSAGE, 'Incorrect number of arguments!'                                     ; Message
ENDIF ELSE IF N_PARAMS() EQ 1 THEN BEGIN                                        ; If one argument
  y = xIn                                                                       ; Set y to xIn
  x = LINDGEN( N_ELEMENTS(y) )                                                  ; Generate x
ENDIF ELSE BEGIN                                                                ; Else, at least 3 args
  nx = N_ELEMENTS(xIn)                                                          ; Number of x-values
  ny = N_ELEMENTS(yIn)                                                          ; Number of y-values
  IF nx NE ny THEN BEGIN                                                        ; If # x/y not same
    n = MIN( [nx, ny] )                                                         ; Determine smaller array
    x = xIn[0:n-1]                                                              ; Set x to subset of x
    y = yIn[0:n-1]                                                              ; Set y to subset of y
  ENDIF ELSE BEGIN                                                              ; Else
    x = xIn                                                                     ; set x
    y = yIn                                                                     ; set y
  ENDELSE
ENDELSE

IF N_ELEMENTS(symsize) EQ 0 THEN symsize = 1.0

IF KEYWORD_SET(overplot) EQ 0 THEN PLOT, x, y, /NoData, _EXTRA=_extra

scale = 3.0*!D.X_CH_SIZE / width * symsize 
xy    = CONVERT_COORD(x, y, /DATA, /TO_DEVICE)

FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  IF i LT N_ELEMENTS(orientation) THEN BEGIN 
    II     = SQRT(xx^2 + yy^2)
    phi    = ACOS(yy/II)
    phi    = phi + 2.0 * (!PI - phi) * (xx LT 0)
    phi    = phi + !DDTOR * orientation[i]
    xplane = II * SIN(phi) * scale
    yplane = II * COS(phi) * scale
  ENDIF ELSE BEGIN
    xplane = xx * scale
    yplane = yy * scale
  ENDELSE
  IF KEYWORD_SET(fill) THEN $
    POLYFILL, xy[0,i] + xplane, xy[1,i] + yplane, _EXTRA=_extra, /DEVICE $
  ELSE $
    PLOTS, xy[0,i] + xplane, xy[1,i] + yplane, _EXTRA=_extra, /DEVICE

ENDFOR
STOP

END
