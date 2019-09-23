FUNCTION KW_LINE_JOIN, lines, width, ref_lon, ref_lat, $
	MIN_X_LENGTH = min_x_length, $
	MIN_Y_LENGTH = min_y_length, $
	WIDTH2       = width2, $
	LIMIT        = limit
;+
; Name:
;    KW_LINE_JOIN
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
;   ref_lon : Longitude values for desired ITCZ resolution
;   ref_lat : Latitude values for desired ITCZ resolution
; Outputs:
;    A structure containing the points for the joined contour
;    lines under separate tag names for each separate line.
; Keywords:
;   MIN_X_LENGTH : An optional keyword that is set to the minimum
;                   distance a line must stretch in the x-direction
;                   for it to be returned in the output data.
;   MIN_Y_LENGTH : An optional keyword that is set to the minimum
;                   distance a line must stretch in the y-direction
;                   for it to be returned in the output data.
;   width2       : Set secondary scanning with in the x-direction. 
;                   Default is width * 18
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
;     Modified 06 March 2018 by Kyle R. Wodzicki
;       Fixed issue that caused empty structure to be returned when only
;       one line was present before second joining attempt.
;-

COMPILE_OPT IDL2                                                                 ;Set compile options

IF (N_PARAMS() NE 4) THEN MESSAGE, 'Incorrect number of inputs!'                ; Check number of inputs

nLon = N_ELEMENTS(ref_lon)
nLat = N_ELEMENTS(ref_lat)

IF (N_ELEMENTS(width2)       EQ 0) THEN width2       = width * 15   			      ; Set width for second round of joining in longitude
IF (N_ELEMENTS(min_x_length) EQ 0) THEN min_x_length = 15                       ; Set default minimum distance in x that joined line must span

fmt = "(I02)"                                                                   ; Set format for converting counters to string
already_used = -1                                                               ; Initialize variable that will store index of contour lines already joined
joined = {}                                                                     ; Initialize structure to store all joined lines

line_num = 1                                                                    ; Counter for joined lines
FOR i = 0, N_TAGS(lines)-1 DO BEGIN                                             ; Iterate over tags to get starting line
  IF TOTAL(i EQ already_used, /INT) NE 0 THEN CONTINUE                          ; Check to see if given contour line was used already
  
  temp_x_I = lines.(i).X_VALUES                                                 ; Store x values of line that has not been used
  temp_y_I = lines.(i).Y_VALUES                                                 ; Store y values of line that has not been used
  
  IF (N_ELEMENTS(temp_x_I) EQ 1) THEN BEGIN                                     ; Line must have AT LEAST 3 points in it; Cannot remember why I did this
    already_used = [already_used, i]
    CONTINUE
  ENDIF
   
  IF (temp_x_I[0] GT temp_x_I[-1]) THEN BEGIN                                   ; Flip if first element in x is greater than last element in x
    temp_x_I = REVERSE(temp_x_I)
    temp_y_I = REVERSE(temp_y_I)
  ENDIF
  
  max_x_I  = WHERE(MAX(temp_x_I) EQ temp_x_I, max_cnt)                          ; Locate the maximum longitude values and how many times it occurs
  min_x_I  = WHERE(MIN(temp_x_I) EQ temp_x_I, min_cnt)                          ; Locate the minimum longitude values and how many times it occurs
  IF max_CNT NE 1 OR min_CNT NE 1 THEN BEGIN                                    ; If there is more than one maximum or minimum, do NOT use this line
    already_used = [already_used, i]                                            ; Append the line index to the already_used variable
    CONTINUE                                                                    ; Continue to the next line
  ENDIF
  
  FOR j = 0, N_TAGS(lines)-1 DO BEGIN                                           ; Iterate over tags again to find lines to join with current line
    IF (j EQ i) THEN CONTINUE                                                   ; IF j = i, then on the same line and cannot join a line to itself so skip
    id = WHERE(j EQ already_used, CNT)                                          ; Check to see if given contour line was used already
    IF (CNT NE 0) THEN CONTINUE                                                 ; Skip if line already used
    
    temp_x_J = lines.(j).X_VALUES                                               ; Store x values of line that has not been used
    temp_y_J = lines.(j).Y_VALUES                                               ; Store y values of line that has not been used
    
    IF (N_ELEMENTS(temp_x_J) EQ 1) THEN BEGIN                                   ; Line must have AT LEAST 3 points in it; Cannot remember why I did this
      already_used = [already_used, j]
      CONTINUE
    ENDIF
   
    IF (temp_x_J[0] GT temp_x_J[-1]) THEN BEGIN                                 ; Flip if first element in x is greater than last element in x
      temp_x_J = REVERSE(temp_x_J)
      temp_y_J = REVERSE(temp_y_J)
    ENDIF
    
    max_x_J = WHERE(MAX(temp_x_J) EQ temp_x_J, max_CNT)                         ; Locate the maximum longitude values and how many times it occurs in jth contour
    min_x_J = WHERE(MIN(temp_x_J) EQ temp_x_J, min_CNT)                         ; Locate the minimum longitude values and how many times it occurs in jth contour    
    IF max_CNT NE 1 OR min_CNT NE 1 THEN BEGIN                                  ; If there is more than one maximum or minimum, do NOT use this line
      already_used = [already_used, j]                                          ; Append the line index to the already_used variable
      CONTINUE                                                                  ; Continue to the next line
    ENDIF

;    tmp = MIN(temp_x_I, min_x_I, SUBSCRIPT_MAX=max_x_I)
    max_x_I  = WHERE(MAX(temp_x_I) EQ temp_x_I)                       ;Find the maximum x value for the temp contour array
    min_x_I  = WHERE(MIN(temp_x_I) EQ temp_x_I)                       ;Find the minimum x value for the temp contour array
       
    ;=== Check if to prepend (i.e., Front) ===;
    id_F = temp_x_I[min_x_I]         GT temp_x_J[max_x_J] AND $                 ; Check if min of temp is east of max of jth contour
           temp_x_I[min_x_I]-width*2 LE temp_x_J[max_x_J] AND $
           temp_y_I[min_x_I]+width   GE temp_y_J[max_x_J] AND $                 ; and check latitude is in range
           temp_y_I[min_x_I]-width   LE temp_y_J[max_x_J]
    ;=== Check if to append (i.e., Back) ===;
    id_B = temp_x_I[max_x_I]+width*2 GE temp_x_J[min_x_J] AND $                 ; Check if max of temp is west of min of jth contour
           temp_x_I[max_x_I]         LT temp_x_J[min_x_J] AND $
           temp_y_I[max_x_I]+width   GE temp_y_J[min_x_J] AND $                 ; and check latitude is in range
           temp_y_I[max_x_I]-width   LE temp_y_J[min_x_J]

    IF id_F EQ 1 THEN BEGIN                                                     ; Prepend the j line to the temp_I line
        temp_x_I       = [temp_x_J, temp_x_I]
        temp_y_I       = [temp_y_J, temp_y_I]
        already_used = [already_used, j]
    ENDIF ELSE IF id_B EQ 1 THEN BEGIN                                          ; Append the j line to the temp_I line
        temp_x_I     = [temp_x_I, temp_x_J]
        temp_y_I     = [temp_y_I, temp_y_J]
        already_used = [already_used, j]
    ENDIF
  ENDFOR                                                                        ; END j

  already_used = [already_used, i]                                              ; Add ith contour line to used list
  
  IF N_ELEMENTS(min_x_length) EQ 1 THEN BEGIN                                   ; Before adding line to structure, check if long enough
		x_range = MAX(temp_x_I)-MIN(temp_x_I)
		IF (x_range LT min_x_length/2.0) THEN CONTINUE                                  ; Skip adding to array, reset tmp_line arrays
	ENDIF
	IF N_ELEMENTS(min_y_length) EQ 1 THEN BEGIN                                   ; Before adding line, check if long enough
		y_range = MAX(temp_y_I)-MIN(temp_y_I)
		IF (y_range LT min_y_length/2.0) THEN CONTINUE                                  ; Skip adding to array, reset tmp_line arrays
	ENDIF
	
  IF (N_ELEMENTS(temp_x_I) LT 2) THEN CONTINUE                                  ; Must be at least 2 points in contour        
  b = REGRESS(temp_x_I, temp_y_I, CORRELATION=r)                                ; Determine a linear regression for the joined line
  IF (ABS(b[0]) GT 0.55) THEN CONTINUE                                          ; IF slope is too steep, then skip the line

	joined = CREATE_STRUCT(joined, '_'+STRING(line_num, FORMAT=fmt), $        ; Add line to joined line structure.
	   {X_VALUES : temp_x_I, Y_VALUES : temp_y_I})
	line_num++                                                                    ; Increment joined number line counter
ENDFOR                                                                          ; END i

IF N_TAGS(joined) EQ 0 THEN BEGIN                                               ; If no lines left after joining and minimum length
  MESSAGE, 'No lines joined/long enough!!!', /CONTINUE                          ; Print an error message
  RETURN, {}                                                                    ; Return an empty structure
ENDIF; ELSE IF N_TAGS(joined) EQ 1 THEN $                                        ; If only one line in the structure
;  RETURN, joined                                                                ; Return the structure

;=====================================================================
; Sort the structured data based on the first x value
IF N_TAGS(joined) GT 1 THEN BEGIN
	sort_x   = []                                                                   ; Initialize array to store first longitude of each line in
	new_join = {}                                                                   ; Initialize structure to store sorted lines in
	FOR i = 0, N_TAGS(joined)-1 DO sort_x = [sort_x, joined.(i).X_VALUES[0]]        ; Append first longitude in each line to the sort_x array
	sort_x = SORT(sort_x)                                                           ; Sort the sort_x array into ascending order, i.e., west to east
	FOR i = 0, N_ELEMENTS(sort_x)-1 DO $                                            ; Populate new_join structure with sorted lines
		new_join = CREATE_STRUCT(new_join, '_'+STRING(i, FORMAT=fmt), joined.(sort_x[i]))
	joined = new_join                                                               ; Replace unsorted joined structure with sorted new_join structure
ENDIF

;=====================================================================
;=====================================================================
; FURTHER JOIN BASED ONLY Extended LONGITUDE Criteria.
;
already_used = -1                                                               ; Reset already used array
line_num = 1                                                                    ; Reset line number count
new_join = {}                                                                   ; New structure to store further joined lines

FOR i = 0, N_TAGS(joined)-1 DO BEGIN                                            ; Iterate over newly joined lines
  IF TOTAL(i EQ already_used, /INT) NE 0 THEN CONTINUE                          ; If line already used, skip it
  
  temp_x_I = joined.(i).X_VALUES                                                ; Store x-values of current line in temporary variable
  temp_y_I = joined.(i).Y_VALUES                                                ; Store y-values of current line in temporary variable

  FOR j = 0, N_TAGS(joined)-1 DO BEGIN                                          ; Iterate over structure again to find lines to join.
    IF (j EQ i) THEN CONTINUE                                                   ; IF j = i, then on the same line and cannot join a line to itself so skip
    IF TOTAL(j EQ already_used, /INT) NE 0 THEN CONTINUE                        ; If line already used, skip it
    
    temp_x_J = joined.(j).X_VALUES                                              ; Store x-values of secondary line in temporary variable
    temp_y_J = joined.(j).Y_VALUES                                              ; Store y-values of secondary line in temporary variable
    
    WHERE_MATCH, temp_x_I, temp_x_J, tmp_id, x_id                               ; Determine if the lines share x-values.
    IF (N_ELEMENTS(tmp_id) NE 0) THEN CONTINUE                                  ; If they share x-values, just skip, do NOT add to already_used array

    tmp = MIN(temp_x_I, min_x_I, SUBSCRIPT_MAX=max_x_I)                         ; Find the minimum and maximum x value for the temp contour array
    tmp = MIN(temp_x_J, min_x_J, SUBSCRIPT_MAX=max_x_J)                         ; Find the minimum and maximum x value for the temp contour array
    
    ;=== Check if to prepend (i.e., Front) ===;
		id_F = temp_x_I[min_x_I]         GT temp_x_J[max_x_J] AND $                 ; Check if min of temp is east of max of jth contour
			     temp_x_I[min_x_I]-width2  LE temp_x_J[max_x_J] AND $
			     temp_y_I[min_x_I]+width*2 GE temp_y_J[max_x_J] AND $                 ; and check latitude is in range
	         temp_y_I[min_x_I]-width*2 LE temp_y_J[max_x_J]
    ;=== Check if to append (i.e., Back) ===;
    id_B = temp_x_I[max_x_I]         LT temp_x_J[min_x_J] AND $                 ; Check if max of temp is west of min of jth contour
			     temp_x_I[max_x_I]+width2  GE temp_x_J[min_x_J] AND $
			     temp_y_I[max_x_I]+width*2 GE temp_y_J[min_x_J] AND $                 ; and check latitude is in range
			     temp_y_I[max_x_I]-width*2 LE temp_y_J[min_x_J]

		IF id_F EQ 1 THEN BEGIN                                                     ; Prepend the j line to the temp_I line
			temp_x_I     = [temp_x_J, temp_x_I]
			temp_y_I     = [temp_y_J, temp_y_I]
			already_used = [already_used, j]
		ENDIF
		IF id_B EQ 1 THEN BEGIN                                                     ; Append the j line to the temp_I line
			temp_x_I     = [temp_x_I, temp_x_J]
			temp_y_I     = [temp_y_I, temp_y_J]
			already_used = [already_used, j]
		ENDIF
  ENDFOR                                                                        ; END j
    
  already_used = [already_used, i]                                              ; Add ith contour line to used list

  IF N_ELEMENTS(min_x_length) EQ 1 THEN BEGIN                                   ; Before adding line, check if long enough
		x_range = MAX(temp_x_I)-MIN(temp_x_I)
		IF (x_range LT min_x_length * 2) THEN CONTINUE                              ; Skip adding to array, reset tmp_line arrays
	ENDIF
	IF N_ELEMENTS(min_y_length) EQ 1 THEN BEGIN                                   ; Before adding line, check if long enough
		y_range = MAX(temp_y_I)-MIN(temp_y_I)
		IF (y_range LT min_y_length) THEN CONTINUE                                  ; Skip adding to array, reset tmp_line arrays
	ENDIF

;===================================================================== 
;  Interpolate to nearest neighbors
	
	  prime_meridian = (lines.(i).X_VALUES[0]  LT 0 AND $                         ; This is a check for if the line crosses the prime meridian
	                    lines.(i).X_VALUES[-1] GT 0) OR $
	  								 (lines.(i).X_VALUES[0]  GT 0 AND $
	  								  lines.(i).X_VALUES[-1] LT 0)
	IF prime_meridian EQ 1 THEN BEGIN
		id = WHERE(temp_x_I GT 180, CNT)																						; Find values greater than 180
		IF CNT GT 0 THEN temp_x_I[id] -= 360																				; Subtract 360, i.e., convert to -180 to 180 range
		ref_id = WHERE(ref_lon GT 180, ref_CNT)
		IF ref_CNT GT 0 THEN ref_lon[ref_id] -= 360																	; Convert ref_lon to -180 to 180 range
	ENDIF
	
	id = WHERE(ref_lon GE MIN(temp_x_I) AND ref_lon LE MAX(temp_x_I), CNT)        ; Find all reference longitudes within the longitude range of the joined line
	IF (CNT EQ 0) THEN CONTINUE                                                   ; IF no points found, skip the line
  temp_y_I = INTERPOL(temp_y_I, temp_x_I, ref_lon[id])                          ; Interpolate line latitudes to have latitude at every reference longitude

  tmp1 = REBIN(ref_lat, nlat, CNT)                                              ; Rebin the input latitude to
  tmp2 = REBIN(REFORM(temp_y_I, 1, CNT), nLat, CNT)                             ; Reform and rebin the lines latitudes
  tmp  = MIN(tmp1 - tmp2, min_id, DIMENSION=1, /ABSOLUTE)                       ; Find the minimums between the differences
  temp_y_I = tmp1[min_id]                                                       ; Get those values as the new latitudes

	IF prime_meridian EQ 1 THEN IF ref_CNT GT 0 THEN ref_lon[ref_id] += 360				; Convert ref lon back to 0 to 360 range
	x_vals = ref_lon[id]
	y_vals = temp_y_I
	IF N_ELEMENTS(limit) EQ 4 THEN BEGIN
	  id = WHERE(x_vals GE limit[1] AND x_vals LE limit[3], CNT)
	  IF (CNT GT 0) THEN BEGIN
	    x_vals = x_vals[id]
	    y_vals = y_vals[id]
	  ENDIF
	  id = WHERE(y_vals GE limit[0] AND y_vals LE limit[2], CNT)
	  IF (CNT GT 0) THEN BEGIN
	    x_vals = x_vals[id]
	    y_vals = y_vals[id]
	  ENDIF
	ENDIF
	new_join = CREATE_STRUCT(new_join, $
	  'LINE_'+STRING(line_num,FORMAT=fmt), {X_VALUES : x_vals, $             ; Append line to output array
															            Y_VALUES : y_vals})
	line_num++
ENDFOR                                                                          ; END i

IF N_ELEMENTS(old_lon) NE 0 THEN ref_lon = old_lon
IF N_ELEMENTS(old_lat) NE 0 THEN ref_lat = old_lat

RETURN, new_join
END