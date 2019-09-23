PRO kwPLOT, x, y, $
	xStyle     = xStyle,     $
	xTickUnits = xTickUnits, $
  xGridStyle = xGridStyle, $
  xTickLen   = xTickLen,   $
  xTitle     = xTitle,     $
  xTick_GET  = xTick_Get,  $
	yStyle     = yStyle,     $
  yTickUnits = yTickUnits, $
  yGridStyle = yGridStyle, $
  yTickLen   = yTickLen,   $
  yTitle     = yTitle,     $
  yTick_GET  = yTick_Get,  $
  TITLE      = title,      $
  POLAR      = polar,      $
  POSITION   = position,   $
  NO_AXES    = no_axes,    $
  OVERPLOT   = overplot,   $
  LABEL      = label,      $
  _EXTRA     = extra
;+
; Name:
;   kwPLOT
; Purpose:
;   A procedure to augment the IDL PLOT procedure. Namely, this procedure
;   adds some checking and built in scaling for x- and y-axes when 
;   the tick lengths are set to 1
; Inputs:
;   x     : Array of x values
;   y     : Array of y values
; Outputs:
;   A direct graphics plot
; Keywords:
;   Accepts all keywords that the IDL procedure PLOT accepts
; Author and History:
;   Kyle R. Wodzicki     Created 09 Mar. 2016
;-
COMPILE_OPT IDL2

IF N_PARAMS() EQ 1 THEN BEGIN																										; If only one (1) input
	y = TEMPORARY(x)																															; Set y equal to x
	x = FINDGEN(N_ELEMENTS(y))																										; Generate x-values
ENDIF

x_ch = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)
y_ch = !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)
x_tick_len = -0.60 * y_ch
y_tick_len = -1.25 * x_ch
;IF N_TAGS(extra) GT 0 THEN $
;	IF TOTAL(STRMATCH(TAG_NAMES(extra), 'TITLE'), /INT) EQ 1 THEN $
;		extra.TITLE = extra.TITLE + '!C'
;xUnits = TOTAL(STRMATCH(ref_extra, 'xTickUnits', /FOLD_CASE), /INT)
;yUnits = TOTAL(STRMATCH(ref_extra, 'yTickUnits', /FOLD_CASE), /INT)

IF (N_ELEMENTS(xTickLen) NE 0) THEN $
  IF (xTickLen EQ 1) THEN BEGIN
    xAxis = 1
    IF (N_ELEMENTS(xGridStyle) EQ 0) THEN xGridStyle = 1
  ENDIF
IF (N_ELEMENTS(yTickLen) NE 0) THEN $
  IF (yTickLen EQ 1) THEN BEGIN
    yAxis = 1
    IF (N_ELEMENTS(yGridStyle) EQ 0) THEN yGridStyle = 1
  ENDIF
IF N_ELEMENTS(title) NE 0 THEN title = '!A'+title

IF KEYWORD_SET(polar) OR KEYWORD_SET(overplot) THEN BEGIN
	IF N_ELEMENTS(xStyle) EQ 0 THEN xStyle = 4 ELSE $
	  IF (xStyle AND 4) EQ 0 THEN xStyle += 4
	IF N_ELEMENTS(yStyle) EQ 0 THEN yStyle = 4 ELSE $
	  IF (yStyle AND 4) EQ 0 THEN yStyle += 4
ENDIF

PLOT, x, y, POLAR = polar, $
	xStyle     = xStyle,     $
  xTickLen   = x_tick_len, $
	xTickUnits = xTickUnits, $
	xTick_GET  = xTick_GET,     $
	xTitle     = KEYWORD_SET(polar) ? '' : xTitle, $
	yStyle     = yStyle,     $
  yTickLen   = y_tick_len, $
	yTickUnits = yTickUnits, $
	yTick_GET  = yTick_GET,     $
	yTitle     = KEYWORD_SET(polar) ? '' : yTitle, $
	TITLE      = title, $
	POSITION   = position,   $
	NoErase    = KEYWORD_SET(overplot), $
  _EXTRA     = extra
IF N_ELEMENTS(label) NE 0 THEN $
	XYOUTS, position[0]+x_ch, position[3]-y_ch, $
		label, color=0, /Normal

IF KEYWORD_SET(polar) THEN BEGIN
  IF (xStyle AND 4) EQ 4 THEN xStyle -= 4
  IF (yStyle AND 4) EQ 4 THEN yStyle -= 4
ENDIF

IF N_TAGS(extra) GT 0 THEN BEGIN
	ref_extra  = TAG_NAMES(extra)																										; Get names of all tags in the extra structure
	tag_remove = ['*Minor', '*TickFormat', '*Range']																; Tags to remove from the extra structure
	id         = []																																	; Initialize array to store indices
	extra_new  = {}																																	; Initialize structure for filtered tags from extra structure
	FOR i = 0, N_ELEMENTS(tag_remove)-1 DO $																				; Iterate over the tags to remove
		id = [id, WHERE(STRMATCH(ref_extra, tag_remove[i], /FOLD_CASE))]							; Get indices of tags that match the tags to remove
	FOR i = 0, N_ELEMENTS(ref_extra)-1 DO $																					; Iterate over all tags in the extra structure
		IF TOTAL(i EQ id, /INT) EQ 0 THEN $																						; If the index of a give tag is NOT in the id array THEN
			extra_new = CREATE_STRUCT(extra_new, ref_extra[i], extra.(i))								; Append that data to the extra_new structure
ENDIF

IF NOT KEYWORD_SET(no_axes) THEN $
	IF NOT KEYWORD_SET(polar) THEN BEGIN
		IF (N_ELEMENTS(xAxis) NE 0) THEN $
		 AXIS, xAxis=0, xMinor=1, xTickLen=1, xGridStyle=xGridStyle, $
			 xTickFormat="(A1)", $
			 xTickV = xTick_GET, xTicks = N_ELEMENTS(xTick_GET)-1, $
			 xTickUnits = N_ELEMENTS(xTickUnits) GT 0 ? xTickUnits[0] : !NULL, $
			 _EXTRA = extra_new
		IF (N_ELEMENTS(yAxis) NE 0) THEN $
		 AXIS, yAxis=0, yMinor=1, yTickLen=1, yGridStyle=yGridStyle, $
			 yTickFormat="(A1)", $
			 yTickV = yTick_GET, yTicks = N_ELEMENTS(yTick_GET)-1, $
			 yTickUnits = N_ELEMENTS(yTickUnits) GT 0 ? yTickUnits[0] : !NULL, $
			 _EXTRA = extra_new
	ENDIF ELSE BEGIN
		theta = 2*!PI*FINDGEN(360)/360																							; Generate 360 one degree values in radians
		r = ABS(xTick_GET)																															; Get absolut values of r
		r_uniq = r[UNIQ(r, SORT(r))]																								; Get all unique r values
		FOR i = 0, N_ELEMENTS(r_uniq)-1 DO $																				; Iterate over all r values
			OPLOT, REPLICATE(r_uniq[i], 360), theta, LINESTYLE=1, /POLAR							; Plot circles for r values
		AXIS, 0, 0, xAxis=0, xTickLen=0.01, $
			xTickUnits = N_ELEMENTS(xTickUnits) GT 0 ? xTickUnits[0] : !NULL, $
			xStyle = xStyle, xTickName = STRTRIM(FIX(r),2), $
			_EXTRA = extra_new
		AXIS, 0, 0, yAxis=0, yTickLen=0.01, $
			yTickUnits = N_ELEMENTS(yTickUnits) GT 0 ? yTickUnits[0] : !NULL, $
			yStyle = yStyle, yTickName = STRTRIM(FIX(r),2), $
			_EXTRA = extra_new
		XYOUTS, position[0]-2*y_ch, MEAN(position[1:*:2]), xTitle, ALIGNMENT=0.5, $
			ORIENTATION=90, /NORMAL
		XYOUTS, MEAN(position[0:*:2]), position[1]-2*x_ch, yTitle, ALIGNMENT=0.5, $
			/NORMAL
	ENDELSE
END