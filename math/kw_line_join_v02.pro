FUNCTION KW_LINE_JOIN_V02, lines_in, width, $
  REF_X        = ref_x, $
  REF_Y        = ref_y, $
	MIN_X_LENGTH = min_x_length, $
	MIN_Y_LENGTH = min_y_length, $
	WIDTH2       = width2, $
	LIMIT        = limit
;+
; Name:
;    KW_LINE_JOIN_V02
; Purpose:
;    A function to join points returned from CONTOUR if they
;    with in a given distance from each other. This program is
;    developed in to simulate what the line joining algorithm
;    from Berry and Reeder (2014). However, due to little
;    explanation in that paper about exactly how their algorithm
;    works, this code does not claim to work exactly the same.
;    This function assumes data is in degrees of lon/lat for x/y. 
; Inputs:
;   lines   : A structure containing the x- and y-values for lines for the
;              initial ITCZ identification. This should, ideally, be the 
;              output from the IDENTIFY_ITCZ function
;   width   : Width to check around x and y values.
; Outputs:
;    A structure containing the points for the joined contour
;    lines under separate tag names for each separate line.
; Keywords:
;   REF_X   : Longitude values for desired ITCZ resolution. Used with REF_LAT
;   REF_X   : Latitude values for desired ITCZ resolution. Used with REF_LON
;   MIN_X_LENGTH : An optional keyword that is set to the minimum
;                   distance a line must stretch in the x-direction
;                   for it to be returned in the output data.
;   MIN_Y_LENGTH : An optional keyword that is set to the minimum
;                   distance a line must stretch in the y-direction
;                   for it to be returned in the output data.
;   width2       : Set secondary scanning with in the x-direction. 
;                   Default is width * 18
; Dependencies:
;   NEAREST_NEIGHBOR_INTERPOL
; Author and History:
;    Kyle R. Wodzicki 23 May 2016
;
;     Adapted from KW_LINE_JOIN.pro.depreciated
;     
;     12 January 2017 Updated to return empty structure if no ITCZ can be found.  
;
;     Modified 19 May 2017 by Kyle R. Wodzicki
;       Added WIDTH2 keyword
;       Added some code to account for crossing the prime meridian
;
;   Version 02 Notes:
;     Updated to reduce lines of code required. The second round of joining was
;     replaced by putting the first round of joining in a for loop.
;-

COMPILE_OPT IDL2                                                                 ;Set compile options

IF (N_PARAMS() NE 2) THEN MESSAGE, 'Incorrect number of inputs!'                ; Check number of inputs

lines = lines_in
nX  = N_ELEMENTS(ref_x)
nY  = N_ELEMENTS(ref_y)

IF (N_ELEMENTS(width2)       EQ 0) THEN width2       = width * 18   			      ; Set width for second round of joining in longitude
IF (N_ELEMENTS(min_x_length) EQ 0) THEN min_x_length = 15                       ; Set default minimum distance in x that joined line must span

fmt = "(I02)"                                                                   ; Set format for converting counters to string

x_width   = [width*2, width2]                                                   ; Set up widths in x-direction for 2 rounds of joining
y_width   = [width,   width*2]                                                  ; Set up widths in y-direction for 2 rounds of joining
x_min_fac = [0.5, 2.0]                                                          ; Set up factors for scaling the minimum length in the x-direction
y_min_fac = [0.5, 1.0]                                                          ; Set up factors for scaling the minimum length in the x-direction

FOR k = 0, 1 DO BEGIN                                                           ; Iterate twice for two (2) rounds of joining; the x- and y-distance restrictions are relaxed in the second round
  already_used = -1                                                             ; Initialize variable that will store index of contour lines already joined
  joined    = {}                                                                ; Initialize structure to store all joined lines
  line_num  = 1                                                                 ; Counter for joined lines
	FOR i = 0, N_TAGS(lines)-1 DO BEGIN                                           ; Iterate over tags to get starting line
    IF TOTAL(i EQ already_used, /INTEGER) NE 0 THEN CONTINUE                    ; Check to see if given contour line was used already
		IF (N_ELEMENTS(lines.(i).X_VALUES) EQ 1) THEN BEGIN                         ; Line must have AT LEAST 2 points in it; Cannot remember why I did this
			already_used = [already_used, i]                                          ; Add the line number to the already_used array
			CONTINUE                                                                  ; Skip to the next line
		ENDIF
	 
		IF (lines.(i).X_VALUES[0] GT lines.(i).X_VALUES[-1]) THEN BEGIN             ; Flip if first element in x is greater than last element in x
			temp_x_I = REVERSE(lines.(i).X_VALUES)                                    ; Store x values of line that has not been used after reversing them
			temp_y_I = REVERSE(lines.(i).Y_VALUES)                                    ; Store y values of line that has not been used after reversing them
		ENDIF ELSE BEGIN
			temp_x_I = lines.(i).X_VALUES                                             ; Store x values of line that has not been used
		  temp_y_I = lines.(i).Y_VALUES                                             ; Store y values of line that has not been used
    ENDELSE
    
    IF k EQ 0 THEN BEGIN                                                        ; Only check on first iteration
      n_temp_x_I = N_ELEMENTS(temp_x_I)                                         ; Number of points in the line
      uniq_id    = UNIQ(temp_x_I, SORT(temp_x_I))                               ; Get indices for unique values
	    IF N_ELEMENTS(uniq_id) LT n_temp_x_I OR n_temp_x_I EQ 1 THEN BEGIN        ; If there are duplicate x-values in the line OR if there is only one point in the 'line', then skip it
	      already_used = [already_used, i]                                        ; Add the line number to the already_used array
	      CONTINUE                                                                ; Continue to next line
	    ENDIF
	  ENDIF
	  
		FOR j = 0, N_TAGS(lines)-1 DO BEGIN                                         ; Iterate over tags again to find lines to join with current line
		  IF (j EQ i) OR (TOTAL(j EQ already_used, /INTEGER) NE 0) THEN CONTINUE    ; IF j = i, then on the same line and cannot join a line to itself so skip OR j has already been used
		  IF (N_ELEMENTS(lines.(j).X_VALUES) EQ 1) THEN BEGIN                       ; Line must have AT LEAST 3 points in it; Cannot remember why I did this
			  already_used = [already_used, j]
				CONTINUE
			ENDIF		

			IF (lines.(j).X_VALUES[0] GT lines.(j).X_VALUES[-1]) THEN BEGIN           ; Flip if first element in x is greater than last element in x
				temp_x_J = REVERSE(lines.(j).X_VALUES)
				temp_y_J = REVERSE(lines.(j).Y_VALUES)
			ENDIF ELSE BEGIN
				temp_x_J = lines.(j).X_VALUES                                           ; Store x values of line that has not been used
				temp_y_J = lines.(j).Y_VALUES                                           ; Store y values of line that has not been used
      ENDELSE

      IF k EQ 0 THEN BEGIN                                                      ; Only check on first iteration
        n_temp_x_J = N_ELEMENTS(temp_x_J)                                       ; Number of points in the line
        uniq_id    = UNIQ(temp_x_J, SORT(temp_x_J))                             ; Get indices for unique values
	      IF N_ELEMENTS(uniq_id) LT n_temp_x_J OR n_temp_x_J EQ 1 THEN BEGIN      ; If there are duplicate x-values in the line OR if there is only one point in the 'line', then skip it
			    already_used = [already_used, j]                                      ; Add the line number to the already_used array
			    CONTINUE                                                              ; Skip to the next line
         ENDIF
      ENDIF

	    tmp = MIN(temp_x_I, min_x_I, SUBSCRIPT_MAX=max_x_I)                       ; Locate minimum and maximum values of the I arrays
	    tmp = MIN(temp_x_J, min_x_J, SUBSCRIPT_MAX=max_x_J)                       ; Locate minimum and maximum values of the J arrays
					 
			;=== Check if to prepend (i.e., Front) ===;
			id_F = temp_x_I[min_x_I]            GT temp_x_J[max_x_J] AND $            ; Check if min of temp is east of max of jth contour
						 temp_x_I[min_x_I]-x_width[k] LE temp_x_J[max_x_J] AND $
						 temp_y_I[min_x_I]+y_width[k] GE temp_y_J[max_x_J] AND $            ; and check latitude is in range
						 temp_y_I[min_x_I]-y_width[k] LE temp_y_J[max_x_J]
			;=== Check if to append (i.e., Back) ===;
			id_B = temp_x_I[max_x_I]+x_width[k] GE temp_x_J[min_x_J] AND $            ; Check if max of temp is west of min of jth contour
						 temp_x_I[max_x_I]            LT temp_x_J[min_x_J] AND $
						 temp_y_I[max_x_I]+y_width[k] GE temp_y_J[min_x_J] AND $            ; and check latitude is in range
						 temp_y_I[max_x_I]-y_width[k] LE temp_y_J[min_x_J]

			IF id_F EQ 1 THEN BEGIN                                                   ; Prepend the j line to the temp_I line
					temp_x_I       = [temp_x_J, temp_x_I]
					temp_y_I       = [temp_y_J, temp_y_I]
					already_used = [already_used, j]
			ENDIF ELSE IF id_B EQ 1 THEN BEGIN                                        ; Append the j line to the temp_I line
					temp_x_I     = [temp_x_I, temp_x_J]
					temp_y_I     = [temp_y_I, temp_y_J]
					already_used = [already_used, j]
			ENDIF
		ENDFOR                                                                      ; END j

		already_used = [already_used, i]                                            ; Add ith contour line to used list

		IF N_ELEMENTS(min_x_length) EQ 1 THEN BEGIN                                 ; Before adding line to structure, check if long enough
			x_range = MAX(temp_x_I)-MIN(temp_x_I)
			IF (x_range LT min_x_length * x_min_fac[k]) THEN CONTINUE                 ; Skip adding to array, reset tmp_line arrays
		ENDIF
		IF N_ELEMENTS(min_y_length) EQ 1 THEN BEGIN                                 ; Before adding line, check if long enough
			y_range = MAX(temp_y_I)-MIN(temp_y_I)
			IF (y_range LT min_y_length * y_min_fac[k]) THEN CONTINUE                 ;Skip adding to array, reset tmp_line arrays
		ENDIF
	
		IF (N_ELEMENTS(temp_x_I) LT 2) THEN CONTINUE                                ; Must be at least 2 points in contour        
		b = REGRESS(temp_x_I, temp_y_I, CORRELATION=r)                              ; Determine a linear regression for the joined line
		IF (ABS(b[0]) GT 0.55) THEN CONTINUE                                        ; IF slope is too steep, then skip the line
		
		joined = CREATE_STRUCT(joined, '_'+STRING(line_num, FORMAT=fmt), $          ; Add line to joined line structure.
			 {X_VALUES : temp_x_I, Y_VALUES : temp_y_I})
		line_num++                                                                  ; Increment joined number line counter
	ENDFOR                                                                        ; END i

	IF N_TAGS(joined) EQ 0 THEN BEGIN                                             ; If no lines left after joining and minimum length
		MESSAGE, 'No lines joined/long enough!!!', /CONTINUE                        ; Print an error message
		RETURN, {}                                                                  ; Return an empty structure
	ENDIF

	;=====================================================================
	; Sort the structured data based on the first x value
	sort_x   = []                                                                 ; Initialize array to store first longitude of each line in
	new_join = {}                                                                 ; Initialize structure to store sorted lines in
	FOR i = 0, N_TAGS(joined)-1 DO sort_x = [sort_x, joined.(i).X_VALUES[0]]      ; Append first longitude in each line to the sort_x array
	sort_x = SORT(sort_x)                                                         ; Sort the sort_x array into ascending order, i.e., west to east
	FOR i = 0, N_ELEMENTS(sort_x)-1 DO new_join = $                               ; Populate new_join structure with sorted lines
		CREATE_STRUCT(new_join, '_'+STRING(i, FORMAT=fmt), joined.(sort_x[i]))
	lines = new_join                                                              ; Replace unsorted joined structure with sorted new_join structure
ENDFOR                                                                          ; END k

;===================================================================== 
;  Interpolate to nearest neighbors
IF N_ELEMENTS(ref_x) GT 0 AND N_ELEMENTS(ref_y) GT 0 THEN BEGIN
	new_join = {}
  tmp_lon = ref_x
  FOR i = 0, N_TAGS(lines)-1 DO BEGIN
    
	  prime_meridian = (lines.(i).X_VALUES[0]  LT 0 AND $                         ; This is a check for if the line crosses the prime meridian
	                    lines.(i).X_VALUES[-1] GT 0) OR $
	  								 (lines.(i).X_VALUES[0]  GT 0 AND $
	  								  lines.(i).X_VALUES[-1] LT 0)

		IF prime_meridian EQ 1 THEN BEGIN
			id = WHERE(lines.(i).X_VALUES GT 180, CNT)																; Find values greater than 180
			IF CNT GT 0 THEN lines.(i).X_VALUES[id] -= 360														; Subtract 360, i.e., convert to -180 to 180 range
			ref_id = WHERE(tmp_lon GT 180, ref_CNT)                                   ; Find values greater than 180 in the reference longitude
			IF ref_CNT GT 0 THEN tmp_lon[ref_id] -= 360																; Convert ref_x to -180 to 180 range
		ENDIF
	
    id = WHERE(ref_x GE MIN(lines.(i).X_VALUES) AND $                           ; Find all reference longitudes within the longitude range of the joined line
               ref_x LE MAX(lines.(i).X_VALUES), CNT)

    IF (CNT EQ 0) THEN CONTINUE                                                 ; IF no points found, skip the line
    y_vals = INTERPOL(lines.(i).Y_VALUES, lines.(i).X_VALUES, tmp_lon[id])      ; Interpolate line latitudes to have latitude at every reference longitude
    x_vals = ref_x[id]                                                          ; New x-values
    tmp1   = REBIN(ref_y, nY, CNT)                                              ; Rebin the input latitude to
    tmp2   = REBIN(REFORM(y_vals, 1, CNT), nY, CNT)                             ; Reform and rebin the lines latitudes
    tmp    = MIN(tmp1 - tmp2, min_id, DIMENSION=1, /ABSOLUTE)                   ; Find the minimums between the differences
    y_vals = tmp1[min_id]                                                       ; Get those values as the new latitudes

		IF N_ELEMENTS(limit) EQ 4 THEN BEGIN                                        ; If the limit keyword is set
			id = WHERE(x_vals GE limit[1] AND x_vals LE limit[3], CNT)                ; Filter in the x-direction
			IF (CNT GT 0) THEN BEGIN
				x_vals = x_vals[id]
				y_vals = y_vals[id]
			ENDIF
			id = WHERE(y_vals GE limit[0] AND y_vals LE limit[2], CNT)                ; Filter in the y-direction
			IF (CNT GT 0) THEN BEGIN
				x_vals = x_vals[id]
				y_vals = y_vals[id]
			ENDIF
		ENDIF
		new_join = CREATE_STRUCT(new_join, $
			'_'+STRING(i ,FORMAT=fmt), {X_VALUES : x_vals, $                          ; Append line to output array
																	Y_VALUES : y_vals})
		line_num++
	ENDFOR                                                                         ; END i
	RETURN, new_join
ENDIF ELSE $
	RETURN, lines

END