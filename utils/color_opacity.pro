FUNCTION COLOR_OPACITY, c24, opacity
; Input:
;   c24      : 24-bit color to change opacity
;   opacity  : Opacity, as percent
COMPILE_OPT IDL2

alpha = opacity / 100.0

rgb   = COLOR_24(c24, /INVERT, /ARRAY)
back  = REBIN(COLOR_24(!P.BACKGROUND, /INVERT, /ARRAY), rgb.DIM)
new   = rgb * (1.0 - alpha) + back * alpha

RETURN, COLOR_24(new[0,*], new[1,*], new[2,*])

END
