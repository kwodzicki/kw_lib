PRO UPDATE_XY_CH_SIZE
;+
; Procedure to update the !X_CH_SIZE and !Y_CH_SIZE 
; system variables
;-
COMPILE_OPT IDL2, HIDDEN

DEFSYSV, '!X_CH_SIZE', EXISTS=exist
IF exist EQ 1 THEN $
  !X_CH_SIZE = !D.X_CH_SIZE / FLOAT(!D.X_VSIZE) $
ELSE $ 
  DEFSYSV, '!X_CH_SIZE', !D.X_CH_SIZE / FLOAT(!D.X_VSIZE)

DEFSYSV, '!Y_CH_SIZE', EXISTS=exist
IF exist EQ 1 THEN $
  !Y_CH_SIZE = !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE) $
ELSE $ 
  DEFSYSV, '!Y_CH_SIZE', !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)

END
