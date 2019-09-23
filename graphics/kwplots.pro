PRO kwPLOTS, x, y,  $
			CLIP			= clip, $
			COLOR			= color, $
			DATA			= data, $
			DEVICE 		= device, $
			NORMAL		= normal, $
			LINESTYLE	= linestyle, $
			NOCLIP		= noclip, $
			PSYM			= psym, $
			SYMSIZE		= symsize, $
			T3D				= t3d, $
			THICK			= thick, $
			Z					= Z

;+
; Name:
;		kwPLOTS
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
;		See IDL Help PLOTS for information.
; Author and History:
;		Kyle R. Wodzici		Created 19 Sep. 2014
;-

COMPILE_OPT IDL2, HIDDEN																							;Set compile options

dims = SIZE(y, /DIMENSIONS)

IF (N_ELEMENTS(dims) EQ 1) THEN BEGIN
	dims = [dims, 1]
ENDIF ELSE BEGIN
	IF (SIZE(x, /N_DIMENSIONS) EQ 1) THEN x = REBIN(x, dims)
ENDELSE

FOR i = 0, dims[1]-1 DO BEGIN
	PLOTS, x[*,i], y[*,i], $
				CLIP			= clip, $
				COLOR			= color, $
				DATA			= data, $
				DEVICE 		= device, $
				NORMAL		= normal, $
				LINESTYLE	= linestyle, $
				NOCLIP		= noclip, $
				PSYM			= psym, $
				SYMSIZE		= symsize, $
				T3D				= t3d, $
				THICK			= thick, $
				Z					= Z
ENDFOR
END