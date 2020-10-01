PRO KW_WINDOW, window_index, SIZE=size, _EXTRA = _extra
COMPILE_OPT IDL2

IF N_ELEMENTS(window_index) EQ 0 THEN window_index = 0

extra = DICTIONARY(_extra)

IF N_ELEMENTS(size) EQ 2 THEN BEGIN
  xsize = size[0]
  ysize = size[1]
ENDIF ELSE BEGIN
  IF extra.HasKey('xsize') THEN xsize = extra.REMOVE('xsize')
  IF extra.HasKey('ysize') THEN ysize = extra.REMOVE('ysize')
ENDELSE

xsize = (N_ELEMENTS(xsize) EQ 1) ? xsize * !X11_DPI : !D.X_VSIZE
ysize = (N_ELEMENTS(ysize) EQ 1) ? ysize * !X11_DPI : !D.Y_VSIZE

WINDOW, window_index, XSIZE = xsize, YSIZE = ysize, _EXTRA = extra.ToStruct()

!X_CH_SIZE = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)
!Y_CH_SIZE = !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)
END
