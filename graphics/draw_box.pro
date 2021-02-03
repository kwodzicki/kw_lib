PRO DRAW_BOX, llur, _EXTRA=_extra

COMPILE_OPT IDL2

x0 = llur[0,0]
x1 = llur[0,1]
y0 = llur[1,0]
y1 = llur[1,1]

xx = [x0, x0, x1, x1, x0]
yy = [y0, y1, y1, y0, y0]

PLOTS, xx, yy, /NORMAL, _EXTRA=_extra

END
