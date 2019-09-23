FUNCTION OPTIMAL_BIN_WIDTH, data, METHOD = method_in
;+
; Name:
;   FREEDMAN_BIN_WIDTH 
; Purpose:
;   An IDL function to compute the optimal bin width using the Freedman method
; Inputs:
;   data  : Array of data to compute optimum bin width
; Outputs:
;   Returns the optimum bin width
; Keywords:
;   METHOD  : String specifying the method to use. Default is Freedom [1].
; Dependencies:
;   percentiles
; References:
;   [1] D. Freedman & P. Diaconis (1981) “On the histogram as a density 
;          estimator: L2 theory”. Probability Theory and Related Fields 57 
;          (4): 453-476
; Author and History:
;   Kyle R. Wodzicki     Created 22 Aug. 2017
;-
COMPILE_OPT IDL2

method = N_ELEMENTS(method_in) EQ 0 ? 'FREEDMAN' : STRUPCASE(method_in)         ; Set method to default if none enter or uppercase of user specified



IF method EQ 'FREEDMAN' THEN BEGIN
  q = PERCENTILES(data, VALUE = [0.25, 0.75])
  db = 2 * (q[1] - q[0]) / FLOAT(N_ELEMENTS(data))^(1.0/3.0)
ENDIF ELSE IF method EQ 'SCOTT' THEN $
  db = 3.5 * STDDEV(data) / FLOAT(N_ELEMENTS(data))^(1.0/3.0) $
ELSE IF method EQ 'KNUTH' THEN $
  db = KNUTH_BIN_WIDTH(data) $
ELSE MESSAGE, 'Unrecognized option!'

RETURN, [db, MIN(data, /NaN), MAX(data, /NaN)]

END