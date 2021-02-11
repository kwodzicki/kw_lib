PRO KW_PLOTS, x, y, z, OUTLINE=outline, _EXTRA=_extra
;+
; Name:
;   KW_PLOTS
; Purpose:
;		A procedure based around the PLOTS procedure. This procedure
;		will simply iterate over the rows of input arrays. Assumed
;		iteration is over `y' array. If x points are the same for
;		all `y' points, only 1-D array must be input
; Inputs:
;		See IDL Help PLOTS for information.
; Outputs:
;		Same as IDL PLOTS procedure
; Keywords:
;   OUTLINE : Set to color (RGB or 24-bit) to draw outline around line
;		See IDL Help PLOTS for information.
; Author and History:
;		Kyle R. Wodzici		Created 19 Sep. 2014
;		Modified 10 Feb. 2021 by Kyle R. Wodzicki:
;     Combines functionality of old kwplots and this kw_plots procedure
;-

COMPILE_OPT IDL2

dims = SIZE(x, /DIMENSIONS)

IF (N_ELEMENTS(dims) EQ 1) THEN BEGIN
	dims = [dims, 1]
ENDIF ELSE BEGIN
	IF (SIZE(x, /N_DIMENSIONS) EQ 1) THEN x = REBIN(x, dims)
ENDELSE

FOR i = 0, dims[1]-1 DO BEGIN
  IF N_ELEMENTS(outline) EQ 1 THEN BEGIN
    extra = DICTIONARY(_extra)
    extra['color'] = outline
    IF extra.HasKey('thick') THEN thick = extra['thick'] ELSE thick = 1
    extra['thick'] = thick + 3
    CASE N_PARAMS() OF
      1 : PLOTS, x,       _EXTRA = extra.ToStruct() 
      2 : PLOTS, x, y,    _EXTRA = extra.ToStruct() 
      3 : PLOTS, x, y, z, _EXTRA = extra.ToStruct() 
    ENDCASE
  ENDIF
  
  CASE N_PARAMS() OF
    1 : PLOTS, x[*,i],                 _EXTRA = _extra 
    2 : PLOTS, x[*,i], y[*,i],         _EXTRA = _extra 
    3 : PLOTS, x[*,i], y[*,i], z[*,i], _EXTRA = _extra 
  ENDCASE

END
