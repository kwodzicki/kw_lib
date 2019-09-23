PRO PLOT_FILLED_ERROR, x_in, high_error, low_error, COLOR = color
;+
; Name:
;   PLOT_FILLED_ERROR
; Purpose:
;   A procedure to that uses POLYFILL to contour the error on a
;   line plot. If there is missing data, make sure that the data
;   are NaN values, as these will be handled as missing, with
;   gaps at there locations.
; Calling Sequence:
;   PLOT_FILLED_ERROR, x, y+standard_deviation, y-standard_deviation
; Inputs:
;   x_in       : X values for the plot
;   high_error : Positive error values, i.e., mean+standard deviation
;   low_error  : Negative error values, i.e., mean-standard deviation
; Outputs:
;   None.
; Keywords:
;   COLOR   : Set the color. Default is GRAY70 from K.P.B COLOR_24.
;
; Usage:
;   For this example lets say you have some means (y) at given times
;   (x). To run this procedure, first set up your plot using
;   the PLOT procedure along with the NoData keyword.
;   Next, run this procedure, calling as:
;     PLOT_FILLED_ERROR, x, y+stddev, y-stddev
;   where stddev is the standard deviation of the data.
;   Lastly, run your same exact PLOT command, but this time without
;   the NoData keyword.
;
; Author and History:
;   Kyle R. Wodzicki     Created 23 Apr. 2015.
;-
COMPILE_OPT IDL2

IF (N_ELEMENTS(color) EQ 0) THEN color = 'GRAY70'

id = WHERE(FINITE(high_error, /NaN), CNT)
nx = N_ELEMENTS(x_in)
IF (CNT NE 0) THEN BEGIN
  IF (id[0]  NE 0)  THEN id = [-1, id]
  IF (id[-1] NE nx) THEN id = [id, nx]
	FOR j = 0, N_ELEMENTS(id)-2 DO BEGIN
		x = x_in[id[j]+1:id[j+1]-1]
		x = [ x, REVERSE(x), x[0] ]
		high_error_1 = high_error[id[j]+1:id[j+1]-1]
		low_error_1  = low_error[id[j]+1:id[j+1]-1]
		y = [ high_error_1, REVERSE(low_error_1), high_error_1[0] ]
		POLYFILL, x, y, COLOR=COLOR_24(color), /Data
	ENDFOR
ENDIF ELSE BEGIN
	x = [ x_in, REVERSE(x_in), x_in[0] ]
	y = [ high_error, REVERSE(low_error), high_error[0] ]
	POLYFILL, x, y, COLOR=COLOR_24(color), /Data
ENDELSE
END