;----------------------------------------------------------------------------
; SCCS/s.wtd_mean.pro 1.11 01/05/08 12:56:48
;
;                            function wtd_mean
;
; Purpose:
;   Computes mean of values in vector/array in_values, using the "weights"
;   for each value given in in_weights.
;
; Algorithm:
;   The "weights" can be anything (e.g.  area, a score of importance, 
;   etc.).  The algorithm works by assuming that the quantity that 
;   constitutes the "weights" is conserved, and thus that the sum of 
;   the weights divided by the sum of all the weights, equals 1.  Thus, 
;   the mean is calculated by applying those weights to the values.
;
;   NB:  For the "weights", a larger magnitude "weight" means to weight
;   the corresponding value more.
;
;   If any of values or weights equals NaN, the function skips that element
;   in the input.  The sum of the rest of the "weights" are ASSUMED to be
;   conserved.  If either all the values or all the weights are NaN,
;   out_mean is NaN.
;
;   If there is only one non-NaN point, this procedure returns that value
;   as the weighted mean.
;
; File I/O:
;   None.
;
; Entry and Exit States:
;   N/A.
;
; Input Parameter:
;   in_values   Values to take weighted mean of.  Scalar or array of any
;               dimension.  Required.
;   in_weights  "Weights" for each value in in_values.  Has same dimensions
;               and type as in_values.  Required.
;
; Output Parameter:
;   out_mean    Weighted mean of the values in in_values.  Scalar.  Type
;               DOUBLE.  Created.
;
; Keywords (optional unless otherwise noted):
;   None.
;
; Revision History:
; - 8 Feb 2001:  Orig. ver. by Johnny Lin, CIRES/Univ. of Colo.  Email:
;   air_jlin@yahoo.com.  Passed moderately reasonable tests.
;
; Notes:
; - Written for IDL 5.0.
; - Copyright (c) 2001 Johnny Lin.  For licensing and contact information
;   see http://www.johnny-lin.com/lib.html.  
; - Input can be scalar or arrays of any dimension.
; - Computations are done in double precision.
; - No procedures called with _EXTRA keyword invoked.
; - No user-written procedures called.
; - No common blocks are used in this program.
;----------------------------------------------------------------------------

FUNCTION WTD_MEAN, in_values, in_weights  $
                 , _EXTRA = extra



; -------------------- Error Check and Parameter Setting -------------------- 

ON_ERROR, 0

if (N_PARAMS() ne 2) then MESSAGE, 'error-bad param list'

values  = DOUBLE(in_values)        ;- protect input
weights = DOUBLE(in_weights)

if (N_ELEMENTS(values) ne N_ELEMENTS(weights)) then MESSAGE, 'error-mismatch'



; ------------------------------- Calculation -------------------------------

good_pts_val = WHERE(FINITE(values) eq 1, count)   ;- find non-NaN values
if (count gt 0) then begin
   values  = values[good_pts_val]
   weights = weights[good_pts_val]
endif

good_pts_wts = WHERE(FINITE(weights) eq 1, count)  ;- find also w/ corresp.
if (count gt 0) then begin                         ;  non-NaN weights
   values  = values[good_pts_wts]
   weights = weights[good_pts_wts]
endif

tot_weights   = TOTAL(weights)
if (tot_weights eq 0.0) then MESSAGE, 'error-weights sum zero'

if (N_ELEMENTS(values) eq 1) then  $               ;- calc. mean value:  if
   mean_value = values[0]  $                       ;  only 1 good pt., mean
else begin                                         ;  is the value of that pt.
   weights    = weights / tot_weights
   mean_value = TOTAL(values * weights)
endelse



; ---------------------------- Clean-Up and Output --------------------------

out_mean = mean_value
RETURN, out_mean



END         ; ===== end of function =====

; ========== end file ==========