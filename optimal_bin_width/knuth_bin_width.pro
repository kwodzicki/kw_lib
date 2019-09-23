FUNCTION KBW_LOCAL_FUNC, M, n, data
;+
; Name:
;   KBW_LOCAL_FUNC
; Purpose:
;   A local IDL function used in computing bin width using the Knuth method.
; Inputs:
;   M    : Number of bins
;   n    : Number of data points
;   data : Array of data
; Outputs:
;   Result of a function that must be maximized.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 22 Aug. 2017
;-
  COMPILE_OPT IDL2, HIDDEN
  nM = N_ELEMENTS(M)                                                            ; Number of elements in M
  nk = FLTARR(nM, /NoZero)                                                      ; Generate floating-point array of length nM
  FOR i = 0, nM-1 DO $                                                          ; Iterate over all Ms
    nk[i] = TOTAL( LNGAMMA( HISTOGRAM(data, NBINS=M[i]) + 0.5 ) )               ; Compute sum of the Gamma function of the histogram
	RETURN, n * ALOG(M) + LNGAMMA(M / 2.0) - M * LNGAMMA(0.5) - $                 ; Return value
	        LNGAMMA( n + M / 2.0 ) + nk
END

FUNCTION KNUTH_BIN_WIDTH, data
;+
; Name:
;   KNUTH_BIN_WIDTH
; Purpose:
;   An IDL function to compute optimized bin width using the Knuth method.
; Inputs:
;   M : Number of bins
; Outputs:
;   Result of a function that must be maximized.
; Keywords:
;   None.
; References:
;   Knuth, K.H. “Optimal Data-Based Binning for Histograms”. arXiv:0605197, 2006
; Author and History:
;   Kyle R. Wodzicki     Created 22 Aug. 2017
;-
  COMPILE_OPT IDL2
	n    = N_ELEMENTS(data)                                                       ; Number of data points
	dM   = 100                                                                    ; Set size for M; initial guess
	old  = -!Values.F_INFINITY                                                    ; Initialize old as negative infinity
	FOR M = 1, 10L^6, dm DO BEGIN                                                 ; Iterate from 1 to 1,000,000
	  new = KBW_LOCAL_FUNC(M, n, data)                                            ; Compute new value using KBW_LOCAL_FUNC
	  IF new LT old THEN BREAK ELSE old = new                                     ; If the new value is less than the old value then break, else set old equal to new
	ENDFOR
	M -= dM                                                                       ; Subtract dM from M
	WHILE 1 DO BEGIN                                                              ; While true, i.e., continue forever
	  dM   = ROUND(dM * 0.5)                                                      ; Set dM to half of old dM
    tmpM = ROUND(M + dm * [-0.5, 0.5])                                          ; Compute temporary M as M +- dM/2
	  new  = KBW_LOCAL_FUNC(tmpM, n, data)                                        ; Get new values from KBW_LOCAL_FUNC using tmpM
	  newM = new[0] GT new[1] ? tmpM[0] : tmpM[1]                                 ; Set new M to location of the larger result
	  IF newM EQ M THEN BREAK ELSE M = newM                                       ; If the newM is equal to M then break, else set M equal to new M
	ENDWHILE
	RETURN, (MAX(data) - MIN(data)) / FLOAT(newM-1)                               ; Return optimum bin spacing
END