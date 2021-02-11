FUNCTION KW_CONTOUR_LINES, z, x, y, level, $
           X_SKIP  = x_skip, $
           Y_SKIP  = y_skip, $
           XRANGE  = xrange, $
           YRANGE  = yrange

;+
; Name:
;   KW_CONTOUR_LINES
; Purpose:
;   A function to determine the location of a contour line
;   at a single level. Done by iteration over x-values then
;   iteration over y-values, using the INTERPOL function to
;   determine if the level is between two y-values.
; Inputs:
;   z     : A 2-D array of data to find the contour line for.
;   x     : X-values of the data array
;   y     : Y-values of the data array
;   level : The level of the contour to find, eg. where the array = 0.
; Outputs:
;   Returns a structure where each tag in the structure contains
;   the x and y values for a single contour line.
; Keywords:
;   X_SKIP  : Optional input to set the distance in the x-direction
;               to check around a given point for joining points.
;               Default is the spacing in the x-direction.
;   Y_SKIP  : Optional input to set the distance in the y-direction
;               to check around a given point for joining points.
;               Default is half the spacing in the y-direction.
;   XRANGE  : Optional input specifying the range for x-values.
;   YRANGE  : Optional input specifying the range for y-values.
; Author and History:
;   Kyle R. Wodzicki     Created 17 Oct. 2014
;
;     MODIFIED 21 Oct. 2014:
;       Added an `s' to the function name.
;     MODIFIED 31 Oct. 2014:
;       Added check of regression of given contour. If greater than
;       0.5, then don't use it.
;       Also added the use of DOUBLE values for the interpolation
;       indices.
;
; NOTE: This function assumes data is evenly spaced.
;-

COMPILE_OPT IDL2                                                      ;Set compile options

IF (N_PARAMS() NE 4) THEN MESSAGE, 'Incorrect number of inputs!'      ;Check number of inputs         
dims = SIZE(z, /DIMENSIONS)                                           ;Get size of data array
IF (N_ELEMENTS(dims) NE 2) THEN MESSAGE, 'Data must be a 2-D array!'  ;Check data array is 2 dimensions

IF ~KEYWORD_SET(x_skip) THEN x_skip = ABS(x[1] - x[0])                ;Default x_skip
IF ~KEYWORD_SET(y_skip) THEN y_skip = ABS(y[1] - y[0])                ;Default y_skip

x_vals = [] & y_vals = []                                             ;Set temporary variables

FOR i = 0, dims[0]-1 DO BEGIN                                         ;Iterate over x-values
  FOR j = 0, dims[1]-2 DO BEGIN                                       ;Iterate over y-values
    IF TOTAL(FINITE(z[i,j:j+1])) NE 2 THEN CONTINUE                   ;If both values not finite, skip
    
    y_int = INTERPOL([j, j+1], z[i,j:j+1], DOUBLE(level))             ;Find y value where data array EQ level
    IF (y_int GE j AND y_int LE j+1) THEN BEGIN                       ;Index must be at or between y-values
      x_vals = [x_vals, x[i]]                                         ;Store x location
      y_vals = [y_vals, INTERPOLATE(y, y_int, /DOUBLE)]               ;Determine y-value and store
    ENDIF 
  ENDFOR                                                              ;END j
ENDFOR                                                                ;END i

;=====================================================================
; FILTER BASED ON X AND Y RANGES
IF (xrange NE !NULL) THEN BEGIN
	x_id = WHERE(xrange[0] LE x_vals AND xrange[1] GE x_vals, x_CNT)
	IF (x_CNT NE 0) THEN BEGIN
	  x_vals = x_vals[x_id] & y_vals = y_vals[x_id]
	ENDIF
ENDIF

IF (yrange NE !NULL) THEN BEGIN
	y_id = WHERE(yrange[0] LE y_vals AND yrange[1] GE y_vals, y_CNT)
	IF (y_CNT NE 0) THEN BEGIN
	  x_vals = x_vals[y_id] & y_vals = y_vals[y_id]
	ENDIF
ENDIF
  
lines = {}                                                            ;Initialize structure to hold contour lines
line_cnt = 1                                                          ;Counter for contour line
already_used = -1                                                     ;Initialize elements that have been used array

;=====================================================================
; SPLIT UP THE X-VALS AND Y-VALS ARRAYS INTO INDIVIDUAL CONTOURS
FOR i = 0, N_ELEMENTS(x_vals)-1 DO BEGIN                              ;Iterate over all values
  id = WHERE(i EQ already_used, check)
  IF (check NE 0) THEN CONTINUE                                       ;If already used, skip to next
  
  tmp_x = x_vals[i] & tmp_y = y_vals[i]                               ;Initialize temporary arrays
  FOR j = 0, N_ELEMENTS(x_vals)-1 DO BEGIN                            ;Re-iterate to find neighboring points
    id = WHERE(j EQ already_used, check)
    IF (j EQ i) OR (check NE 0) THEN CONTINUE                         ;Check if already used, or if at i iteration
    
    id = WHERE(tmp_x[-1]+x_skip GE x_vals AND $
               tmp_x[-1]        LT x_vals AND $
               tmp_y[-1]+y_skip GE y_vals AND $
               tmp_y[-1]-y_skip LE y_vals, CNT)
               
    IF (CNT NE 0) THEN BEGIN                                          ;If nearby point(s) found, append to arrays
      tmp_x = [tmp_x, x_vals[id]] 
      tmp_y = [tmp_y, y_vals[id]] 
      already_used = [already_used, id]                               ;Append indices to already used array
    ENDIF
  ENDFOR                                                              ;END j
  
  already_used = [already_used, i]                                    ;Append reference point to used array
  IF (N_ELEMENTS(tmp_x) EQ 1) THEN CONTINUE                           ;If only one point in contour, skip it
  
  lines = CREATE_STRUCT(lines, $                                      ;Append contour to structure
            'LINE_'+STRTRIM(line_cnt,2), {X_VALUES : tmp_x, $
                                          Y_VALUES : tmp_y}) 
  line_cnt++                                                          ;Increment line counter
ENDFOR                                                                ;END i

;====== Attempt to add a filter based on slope

slope_flt = {}
line_cnt  = 1
FOR i = 0, N_TAGS(lines)-1 DO BEGIN
  b = ABS(REGRESS(lines.(i).X_VALUES, lines.(i).Y_VALUES))
  IF (b[0] LT 0.5) THEN BEGIN
    tag = 'LINE_'+((line_cnt LT 10) ? '0'+STRTRIM(line_cnt,2) $
                                    :     STRTRIM(line_cnt,2))
    slope_flt = CREATE_STRUCT(slope_flt, tag, $
                              {X_VALUES : lines.(i).X_VALUES, $
                               Y_VALUES : lines.(i).Y_VALUES})
    line_cnt++
  ENDIF
ENDFOR

RETURN, slope_flt
                  
RETURN, lines
END