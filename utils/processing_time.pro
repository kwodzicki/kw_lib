FUNCTION PROCESSING_TIME, start_time, time_diff, num_files

;+
; Name:
;   PROCESSING_TIME
; Purpose:
;   A function to return the mean processing time based on start
;   and end times. Through the use of a common block, the start and
;   end times are passed automatically, and the time for each process
;   is appended to an array that is stored in the common block.
; Inputs:
;   start_time : Set as the start time of a given process. MUST BE SECONDS
;   time_diff  : Any variable name that is unused in program.
;   num_files  : The number of files left to process
; Outputs:
;   Returns a string containing the mean processing time.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 06 Dec. 2014.
;-

COMPILE_OPT IDL2, HIDDEN
    IF (N_ELEMENTS(time_diff) EQ 0) THEN time_diff = []               ;If variable undefined, initialize as array
  
  time_diff = [time_diff, (SYSTIME(/SECONDS) - start_time)]           ;Append the time for a given run
  mean_diff = MEAN(time_diff, /DOUBLE) * num_files                    ;Take mean of all runs times files left
    
  day    = mean_diff/86400.0                                          ;Get days
  hour   = (day    MOD 1) * 24
  minute = (hour   MOD 1) * 60
  sec    = (minute MOD 1) * 60
  
  RETURN, 'Time Remaining: ' + $
            STRING(FLOOR(day),    FORMAT='(I2)') + ' day(s) '  + $
            STRING(FLOOR(hour),   FORMAT='(I2)') + ' hr(s). '  + $
            STRING(FLOOR(minute), FORMAT='(I2)') + ' min(s). ' + $
            STRING(FLOOR(sec),    FORMAT='(I2)') + ' sec(s).'
END