PRO KW_PLOT_CONF_LVL, x, y, sl, dof, LEFT = left, POWER = power, _EXTRA = extra
;+
; Name:
;   KW_PLOT_CONF_LVL
; Purpose:
;   An IDL procedure to plot error bars (confidence limits) on a loglog plot
;   for spectra.
; Inputs:
;   x       : X location to place the bars.
;   y       : Y value to plot limit around
;   sl			: Significance level, in percent
;   dof			: Degrees of freedom
; Outputs:
;   Plots on current window
; Keywords:
;		LEFT : Set to write text to left of error bars. Default is right
; Author and History:
;   Kyle R. Wodzicki     Created 03 Mar. 2017
;
; Notes:
;   Tabs set to 2
;-
COMPILE_OPT IDL2

; Make a vector of 16 points, A[i] = 2pi/16 and define the symbol to be a unit circle with 16 points, 
; and set the filled flag:
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL

txt = STRING(sl, FORMAT="(F4.1)")+'% CL'
IF KEYWORD_SET(left) THEN txt += '  ' ELSE txt = '  '+txt

cl = KW_CF_LOGLOG(y, sl, dof)
IF KEYWORD_SET(power) THEN BEGIN
	cl = 10 * ALOG10(cl)
	PLOTS,  x, 10 * ALOG10(y), PSYM=8, _EXTRA = extra
	XYOUTS, x, 10 * ALOG10(y), txt, ALIGNMENT=KEYWORD_SET(left), CHARSIZE = 0.8, /DATA
ENDIF ELSE BEGIN
	PLOTS,  x, y, PSYM=8, _EXTRA = extra
	XYOUTS, x, y, txt, ALIGNMENT=KEYWORD_SET(left), CHARSIZE = 0.8, /DATA
ENDELSE

ERRPLOT, x, cl[0], cl[1], WIDTH = 0.05, _EXTRA = extra

END