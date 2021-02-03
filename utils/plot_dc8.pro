PRO PLOT_DC8, x, y, dir, SCALE = scale, DEVICE=device, NORMAL=normal

COMPILE_OPT IDL2

COMMON DC8_PLOTTER, dc8_rgb                                                   ; Common plox so don't have to keep reading file

DEFAULT_SCALE = 0.2

IF N_ELEMENTS(dc8_rgb) EQ 0 THEN BEGIN
  savfile = FILEPATH('DC-8_RGB.sav', ROOT_DIR=ROUTINE_DIR())                    ; Get path to SAVE file
  RESTORE, savfile                                                              ; Restore file
ENDIF

IF KEYWORD_SET(device) AND KEYWORD_SET(normal) THEN $
  MESSAGE, 'Cannot set more than one position keyword!'

IF N_ELEMENTS(scale) EQ 0 THEN scale = 1.0

rgb     = dc8_rgb
FOR i = 0, 2 DO rgb[0,0,i] = ROT(rgb[*,*,i], dir)
dims    = SIZE(rgb, /DIMENSIONS)
dims[0] = dims[0:1] * DEFAULT_SCALE * scale 
rgb     = CONGRID(rgb, dims[0], dims[1], dims[2], /INTERP)

xoff = -dims[0] / 2.0
yoff = -dims[1] / 2.0
IF KEYWORD_SET(device) THEN BEGIN
  xx    = x + xoff
  yy    = y + yoff
ENDIF ELSE BEGIN 
  IF KEYWORD_SET(normal) THEN $
    xy0 = CONVERT_COORD(x, y, /NORMAL, /TO_DEVICE) $
  ELSE $ 
    xy0 = CONVERT_COORD(x, y, /DATA, /TO_DEVICE)
  xx    = xy0[0] + xoff
  yy    = xy0[1] + yoff
  ;x1    = xy0[0] + xoff
  ;y1    = xy0[1] + yoff
  ;xy1   = CONVERT_COORD(x1, y1, /DEVICE, /TO_DATA)
  ;xx    = xy1[0]
  ;yy    = xy1[1]
  ;extra = {DATA : 1}
ENDELSE
  
TV, rgb, xx, yy, TRUE=3, /DEVICE

STOP


END
