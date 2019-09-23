FUNCTION ALNORM_LOCAL, x, upper
;+
;       EVALUATES THE TAIL AREA OF THE STANDARDIZED NORMAL CURVE FROM
;       X TO INFINITY IF UPPER IS .TRUE. OR FROM MINUS INFINITY TO X
;       IF UPPER IS .FALSE.
;
;  NOTE NOVEMBER 2001: MODIFY UTZERO.  ALTHOUGH NOT NECESSARY
;  WHEN USING ALNORM FOR SIMPLY COMPUTING PERCENT POINTS,
;  EXTENDING RANGE IS HELPFUL FOR USE WITH FUNCTIONS THAT
;  USE ALNORM IN INTERMEDIATE COMPUTATIONS.
;
;
;-
  COMPILE_OPT IDL2, HIDDEN
	LTONE  =  7.0D0
	UTZERO = 38.0D0
	ZERO   =  0.0D0
	HALF   =  0.5D0
	ONE    =  1.0D0
	CON    =  1.28D0

	A = [0.398942280444D0, 0.399903438504D0, 5.75885480458D0, $
			 29.8213557808D0,  2.62433121679D0, 48.6959930692D0,  $
			 5.92885724438D0 ]
	B = [0.398942280385D0,      3.8052D-8,    1.00000615302D0, $
			 3.98064794D-4,     1.98615381364D0, 0.151679116635D0, $
			 5.29330324926D0,   4.8385912808D0,  15.1508972451D0,  $
			 0.742380924027D0,   30.789933034D0,  3.99019417011D0]

	UP = UPPER
	Z = X
	IF (Z LT ZERO) THEN BEGIN
		UP = NOT UP
		Z = -Z
	ENDIF
	IF (Z LE LTONE OR UP AND Z LE UTZERO) THEN BEGIN
		Y = HALF * Z * Z
		IF (Z GT CON) THEN $
			ALNORM = B[0]* EXP(-Y) / (Z - B[1] + B[2] / (Z + B[3] +B[4]/(Z -B[5] +B[6]/ $
				 (Z +B[7] -B[8]/ (Z +B[9] +B[10]/ (Z + B[11])))))) $
		ELSE $
			ALNORM = HALF - Z * (A[0]- A[1] * Y / (Y + A[2]- A[3] / (Y + A[4] + A[5] / $
				 (Y + A[6]))))
	ENDIF ELSE $
		ALNORM = ZERO  
	
  IF UP EQ 0B THEN ALNORM = ONE - ALNORM
    RETURN, ALNORM
END

FUNCTION PPND_LOCAL, P, IFAULT
;+
; Name:
;   PPND_LOCAL
; Purpose:
;   An IDL function to produces normal deviate corresponding to lower tail area
;   of p real version for eps = 2 **(-31). The hash sums are the sums of the
;   moduli of the coefficients they have no inherent meanings but are include
;   for use in checking transcriptions.
; Inputs:
;   P      :   
;   IFAULT :
; Outputs:
;   Returns PPND
; Keywords:
;   None.
; Author and History:
;   Ported to IDL by Kyle R. Wodzicki     12 Jul. 2017
;
;   Adapted from code in the swilk.f program Python scipy.stats.shapiro
;   https://github.com/scipy/scipy/blob/master/scipy/stats/statlib/swilk.f.
;
;  ALGORITHM AS 111  APPL. STATIST. (1977), VOL.26, NO.1
;
;  NOTE: WE COULD USE DATAPLOT NORPPF, BUT VARIOUS APPLIED
;        STATISTICS ALGORITHMS USE THIS.  SO WE PROVIDE IT TO
;        MAKE USE OF APPLIED STATISTICS ALGORITHMS EASIER.
;-
  COMPILE_OPT IDL2, HIDDEN
  ZERO  = 0.0E0
  HALF  = 0.5E0
  ONE   = 1.0E0
  SPLIT = 0.42E0
  A     = [ 2.50662823884E0, -18.61500062529E0,  41.39119773534E0, -25.44106049637E0]
  B     = [-8.47351093090E0,  23.08336743743E0, -21.06224101826E0,   3.13082909833E0]
  c     = [-2.78718931138E0,  -2.29796479134E0,   4.85014127135E0,   2.32121276858E0]
  D     = [3.54388924762E0, 1.63706781897E0]

  PPND   = FLTARR(N_ELEMENTS(p))                                                ; Initialize PPND as a float array with the same number of elements as p
  IFAULT = 0B                                                                   ; Set the IFAULT value to zero (0)
  Q      = P - HALF                                                             ; Define Q as P minus HALF
  id1 = WHERE(ABS(Q) LE SPLIT, CNT1, COMPLEMENT=id2, NCOMPLEMENT=CNT2)          ; Locate all values where the absolute value of Q is <= SPLIT and the complements
  IF CNT1 GT 0 THEN BEGIN                                                       ; If values are found that are <= split, then being
    R = Q[id1]^2                                                                ; Compute square of Q
    PPND[id1] = Q[id1] *  (((A[3]*R + A[2])*R + A[1]) * R + A[0]) / $           ; Compute PPND at those indices
                         ((((B[3]*R + B[2])*R + B[1]) * R + B[0]) * R + ONE)
  ENDIF
  IF CNT2 GT 0 THEN BEGIN                                                       ; If values found > SPLIT
		R = P[id2]                                                                  ; Set R equal to P for only those indices where ABS(Q) > SPLIT
		id3 = WHERE(Q[id2] GT ZERO, CNT3, COMPLEMENT=id4, NCOMPLEMENT=CNT4)         ; Locate where Q of those indices is > zero (0)
		IF (CNT3 GT 0) THEN R[id3] = ONE - R[id3]                                   ; IF values are found, set R at those indices to 1 - R at those indices
    id1 = WHERE(R GT 0, CNT1, NCOMPLEMENT=CNT2)                                 ; Locate where R is > zero and get the number of values that are <= zero
		IF (CNT1 GT 0) THEN BEGIN                                                   ; If there are values of R > zero
			R = SQRT(-ALOG(R[id1]))                                                   ; Reset R to new values
			PPND[id2[id1]] = (((C[3] * R + C[2]) * R + C[1]) * R + C[0]) / $          ; Compute PPND at those indices
							          ((D[1] * R + D[0]) * R + ONE)
			IF (CNT4 GT 0) THEN PPND[id2[id4]] = -PPND[id2[id4]]                      ; If CNT4 is greater than 0 the set those indices of PPND equal to the negative of themselves
		ENDIF
		IF CNT2 GT 0 THEN IFAULT = 1B                                               ; If CNT2 is greater than zero (0) then set IFAULT to one (1)
  ENDIF
  RETURN, PPND                                                                  ; Return the PPND array
END

FUNCTION POLY_LOCAL, C, X
;+
; Name:
;   POLY_LOCAL
; Purpose:
;   Calculates the algebraic polynomial of order N_ELEMENTS(C)-1 with
;   array of coefficients C.  zero order coefficient is C[0]
; Inputs:
;   C : Array of coefficients used for computing polynomail
;   X : Value to multiply coefficients by
; Outputs:
;   Returns the algebraic polynomial
; Keywords:
;   None.
; Author and History:
;   Ported to IDL by Kyle R. Wodzicki     12 Jul. 2017
;
;   Adapted from code in the swilk.f program Python scipy.stats.shapiro
;   https://github.com/scipy/scipy/blob/master/scipy/stats/statlib/swilk.f.
;
; ALGORITHM AS 181.2   APPL. STATIST.  (1982) VOL. 31, NO. 2
;-
  COMPILE_OPT IDL2, HIDDEN
  RETURN, TOTAL( C * X^FINDGEN( N_ELEMENTS(C) ) )
END

FUNCTION SHAPIRO, X, A = a, NaN = NaN
;+
; Name:
;   SHAPIRO
; Purpose:
;   An IDL function to determine if a distribution is 'normal' using the 
;   Shapiro-Wilk W test. This function and all sub-functions (i.e., *_LOCAL)
;   were adapted from the swilk.f FORTRAN 77 code used by the python 
;   scipy.stats.shapiro function. The code for the swilk.f program can be found
;   at https://github.com/scipy/scipy/blob/master/scipy/stats/statlib/swilk.f.
; Inputs:
;   X : Array of sampled data
; Outputs:
;   Returns a structure containing a bunch of info including the test value and
;   its significance.
; Keywords:
;   A  : Array of internal parameters used in the calculation. If these are not
;         given, they will be computed internally. If x has length n, then a 
;         must have length n/2.
;   NaN : Set this keyword to ignore NaN values
; Author and History:
;   Kyle R. Wodzicki     Created 12 Jul. 2017
;
; Adapted from: 
;   Python scipy.stats.shapiro -> swilk.f
;        ALGORITHM AS R94 APPL. STATIST. (1995) VOL.44, NO.4
;
;        Calculates the Shapiro-Wilk W test and its significance level
;
;        IFAULT error code details from the R94 paper:
;        - 0 for no fault
;        - 1 if N1 < 3
;        - 2 if N > 5000 (a non-fatal error)
;        - 3 if N2 < N/2, so insufficient storage for A
;        - 4 if N1 > N or (N1 < N and N < 20)
;        - 5 if the proportion censored (N-N1)/N > 0.8
;        - 6 if the data have zero range (if sorted on input)
;-
COMPILE_OPT IDL2                                                                ; Set compile options

;=== Define a structure of constants
const = {C1    : [0.0E0,       0.221157E0, -0.147981E0, -0.207119E1,  0.4434685E1, -0.2706056E1], $
         C2    : [0.0E0,       0.42981E-1, -0.293762E0, -0.1752461E1, 0.5682633E1, -0.3582633E1], $
         C3    : [0.5440E0,   -0.39978E0,   0.25054E-1, -0.6714E-3],  $
         C4    : [0.13822E1,  -0.77857E0,   0.62767E-1, -0.20322E-2], $
         C5    : [-0.15861E1, -0.31082E0,  -0.83751E-1,  0.38915E-2], $
         C6    : [-0.4803E0,  -0.82676E-1,  0.30302E-2], $
         C7    : [0.164E0,     0.533E0], $
         C8    : [0.1736E0,    0.315E0], $
         C9    : [0.256E0,    -0.635E-2], $
         G     : [-0.2273E1,   0.459E0], $
         Z90   : 0.12816E1, $
         Z95   : 0.16449E1, $
         Z99   : 0.23263E1, $
         ZM    : 0.17509E1, $
         ZSS   : 0.56268E0, $
         BF1   : 0.8378E0,  $
         XX90  : 0.556E0, $
         XX95  : 0.622E0, $
         ZERO  : 0.0E0, $
         ONE   : 1.0E0, $
         TWO   : 2.0E0, $
         THREE : 3.0E0, $
         SQRTH : 0.70711E0, $
         QTR   : 0.25E0, $
         TH    : 0.375E0, $
         SMALL : 1E-19, $
         PI6   : 0.1909859E1, $
         STQR  : 0.1047198E1, $
         UPPER : 1B}


x_sort = x[SORT(x)]
IF KEYWORD_SET(nan) THEN BEGIN
  id = WHERE(FINITE(x_sort,/NaN) EQ 0, CNT)
  x_sort = CNT GT 0 ? x_sort[id] : !Values.F_NaN
ENDIF

data = {X      : x_sort, $
        A      : N_ELEMENTS(a) GT 0 ? a : FLTARR(N_ELEMENTS(x_sort)/2), $
        N      : N_ELEMENTS(x_sort), $
        W      : const.ONE, $
        PW     : !Values.F_NaN  , $
        IFAULT : 0B}

IF N_ELEMENTS(a)  EQ 0 THEN init = 0B ELSE init = 1B                            ; If a has zero elements, set init to False (i.e., 0), else, set to True (i.e., 1)
IF N_ELEMENTS(n1) EQ 0 THEN n1   = data.N                                       ; Set default value of n1
IF N_ELEMENTS(n2) EQ 0 THEN n2   = data.N/2                                     ; Set default value of n2

data.IFAULT = 3B                                                                ; Set IFAULT to three (3)
IF (N2 LT data.N/2) THEN RETURN, data                                           ; IF N2 is less than half of N, return the data structure
data.IFAULT = 1B                                                                ; Set IFAULT to one (1)
IF (data.N LT 3) THEN RETURN, data                                              ; If there are less than three (3) data points input, return the data structure

IF (NOT INIT) THEN BEGIN                                                        ; If INIT is false, calculates coefficients for the test
  IF (data.N EQ 3) THEN $                                                       ; IF there are only three (3) values input
    data.A[0] = const.SQRTH $                                                   ; Set the first element of data.A to a constant
  ELSE BEGIN                                                                    ; ELSE
    tmp    = (FINDGEN(n2)+1 - const.TH) / (data.N + const.QTR)                  ; Calculate some temporary values
    data.A = PPND_LOCAL( tmp, data.IFAULT )                                     ; Set data.A equal to the result of PPND_LOCAL
    SUMM2  = TOTAL(data.A^2) * const.TWO                                        ; Define SUMM2 as the sum of the squares of data.A x 2
		SSUMM2 = SQRT( SUMM2 )                                                      ; Define SSUMM2 as the square root of SUMM2
    RSN    = const.ONE / SQRT(data.N)                                           ; Define RSN as 1 / (square root of number of data points input)
    A1     = POLY_LOCAL(const.C1, RSN) - data.A[0] / SSUMM2                     ; Define A1 as the result of POLY_LOCAL
    
    ;=== Normalize coefficients
    IF (data.N GT 5) THEN BEGIN                                                 ; If there were greater than five (5) data points input
      id  = 2                                                                   ; Set the index for writing data to the data.A array to two (2)
      A2  = -data.A[1] / SSUMM2 + POLY_LOCAL(const.C2, RSN)                     ; Compute value for the second element of data.A
      FAC = (SUMM2     - const.TWO * data.A[0]^2 - const.TWO * data.A[1]^2) / $ ; Compute the fator for normalizing the coefficients
            (const.ONE - const.TWO * A1^2        - const.TWO * A2^2)
      data.A[1] = A2                                                            ; Set the second element of data.A to A2
    ENDIF ELSE BEGIN
      id  = 1                                                                   ; Set the index for writing data to the data.A array to one (1)
      FAC = (SUMM2 - const.TWO * data.A[0]^2) / (const.ONE - const.TWO * A1^2)  ; Compute the factor for normalizing the coefficients
    ENDELSE
    data.A[0]    = A1                                                           ; Set the first element of data.A to A1
    data.A[id:*] = -data.A[id:*] / SQRT(FAC)
  ENDELSE
ENDIF

IF (N1 LT 3) THEN RETURN, data                                                  ; If N1 is less than three (3) then return the data structure

NCENS = data.N - N1                                                             ; Define NCENS as the number of data points input minus N1
data.IFAULT = 4B                                                                ; Set the IFAULT value to four (4)
IF (NCENS LT 0 OR (NCENS GT 0 AND data.N LT 20)) THEN RETURN, data              ; IF NCENS is negative OR (NCENS is GT zero and the number of data points input is less than 20) return the data structure
data.IFAULT = 5B                                                                ; Set the IFAULT value to five (5)

delta = FLOAT(NCENS)/data.N                                                     ; Define delta as the ratio of NCENS to data.N
IF (delta GT 0.8) THEN RETURN, data                                             ; If delta is greater than 0.8 then return the data structure
IF (data.W LT const.ZERO) THEN BEGIN                                            ; IF the data.W value is less than zero (0), calculate significance level of -W
  W1 = const.ONE + data.W                                                       ; Define the W1 variabel as data.W + 1
  data.IFAULT = 0B                                                              ; Set the IFAULT value in the data structure to zero (0)
ENDIF ELSE BEGIN                                                                ; Else, the value of data.W must be greater or equal to zero
	data.IFAULT = 6B                                                              ; Set the IFALUT value in the data structure to six (6)
	range = data.X[-1] - data.X[0]                                                ; Calculate the range of the data
	IF (range LT const.SMALL) THEN RETURN, data                                   ; If the range of the data is less than the value of small, then return the data structure
	;=== Check for correct sort order on range - scaled X
	data.IFAULT = 7B                                                              ; Set the IFALUT value in the data structure to seven (7)
	SA       = const.ZERO                                                         ; Set the SA variable to zero (0)
	scaled_X = data.X / RANGE                                                     ; Defined scaled_X as the input data divided by the range of the data. Used multiple times later; performed here to save some clock cycles
	SX       = TOTAL(scaled_X)                                                    ; Define SX as the sum of the scaled_X values
	FOR i = 1, N2 DO BEGIN                                                        ; Iterate from one (1) to N2
	  SA -= data.A[i-1]                                                           ; Subtract the first value of data.A from the SA variable
	  SA += data.A[-i]                                                            ; Add the last value of data.A from the SA variable
	ENDFOR                                                                        ; END i

	data.IFAULT = 0B                                                              ; Set the IFALUT value in the data structure to zero (0)
	IF (data.N GT 5000) THEN data.IFAULT = 2B                                     ; If the number of data points in put is greater than 5,000, then set IFAULT to two (2)
	;=== Calculate W statistic as squared correlation between data and coefficients
	SA  = SA / N1                                                                 ; Divide SA by N1
	SX  = SX / N1                                                                 ; Divide SX by N1
	SSX = scaled_X - SX                                                           ; Define SSX as the scaled_X values minus SX
	SSA = FLTARR(data.N, /NoZero)                                                 ; Initialize SSA as a float array that is the same size as the input data
	SSA[0]        = -data.A                                                       ; Write the negative of data.A to the SSA array starting at the beginning
	SSA[data.N/2] = REVERSE(data.A)                                               ; Write data.A in reverse tot he SSA array starting at the middle
  SSA -= SA                                                                     ; Subtract SA from every value in the SSA array
	IF (data.N MOD 2) EQ 1 THEN SSA[N_ELEMENTS(data.A)] = -SA                     ; If the length of the input data is odd, then write -SA to the middle of the SSA array
  SAX = TOTAL(SSA * SSX)                                                        ; Define SAX as the some of SSA x SSX
  SSA = TOTAL(SSA^2)                                                            ; Set SSA to the sum of the squares of SSA
  SSX = TOTAL(SSX^2)                                                            ; Set SSA to the sum of the squares of SSX

  ;=== W1 equals (1-W) calculated to avoid excessive rounding error
  ;=== for W very near 1 (a potential problem in very large samples)
	SSASSX = SQRT(SSA * SSX)                                                      ; Compute the square root of SSA x SSX
	W1     = (SSASSX - SAX) * (SSASSX + SAX)/(SSA * SSX)                          ; Define W1
ENDELSE

data.W = const.ONE - W1                                                         ; Set data.W to 1 - Wq

IF (data.N EQ 3) THEN BEGIN                                                     ; If there were only three (3) data points input
  data.PW = const.PI6 * (ASIN(SQRT(data.W)) - const.STQR)                       ; Calculate significance level for W (exact for N=3)
  RETURN, data                                                                  ; Return the data structure
ENDIF

Y  = ALOG(W1)                                                                   ; Define y as the log base e of W1
XX = ALOG(data.N)                                                               ; Define XX as the log base e of data.N
M  = const.ZERO
S  = const.ONE
IF (data.N LE 11) THEN BEGIN                                                    ; IF there were less than or equal to eleven (11) data points input
  GAMMA = POLY_LOCAL(const.G, data.N)                                           ; Define gamma as the result of POLY_LOCAL
  IF (Y GE GAMMA) THEN BEGIN                                                    ; If Y is greater or equal to gamma
    data.PW = const.SMALL                                                       ; Set the significane level for W to small
    RETURN, data                                                                ; Return the data structure
  ENDIF
  Y = -ALOG(GAMMA - Y)                                                          ; Re-define y as the negative of the log base e of (gamma - y)
  M = POLY_LOCAL(const.C3, data.N)                                              ; Define M as the result of POLY_LOCAL
  S = EXP(POLY_LOCAL(const.C4, data.N))                                         ; Define S as the exponential of the result of POLY_LOCAL
ENDIF ELSE BEGIN                                                                ; ELSE, the number of data points input is greater than 11
  M = POLY_LOCAL(const.C5, XX)                                                  ; Define M as the result of POLY_LOCAL
  S = EXP(POLY_LOCAL(const.C6, XX))                                             ; Define S as the exponential of the result of POLY_LOCAL
ENDELSE

IF (NCENS GT 0) THEN BEGIN                                                      ; IF NCENS is greater than zero (0)
  ;=== Censoring by proportion NCENS/N.  Calculate mean and sd of normal
  ;=== equivalent deviate of W.
  LD   = -ALOG(delta)
  BF   = const.ONE + XX * const.BF1
  Z90F = Z90 + BF * POLY_LOCAL(const.C7, XX90^XX)^LD
  Z95F = Z95 + BF * POLY_LOCAL(const.C8, XX95^XX)^LD
  Z99F = Z99 + BF * POLY_LOCAL(const.C9, XX)^LD
  ;=== Regress Z90F,...,Z99F on normal deviates Z90,...,Z99 to get
  ;=== pseudo-mean and pseudo-sd of z as the slope and intercept
  ZFM = (const.Z90F + const.Z95F + const.Z99F) / const.THREE
  ZSD = (const.Z90*(const.Z90F-const.ZFM) + $
         const.Z95*(const.Z95F-const.ZFM) + $
         const.Z99*(const.Z99F-const.ZFM)) / const.ZSS
  ZBAR = ZFM - ZSD * const.ZM
  M = M + ZBAR * S
  S = S * ZSD
ENDIF

data.PW = ALNORM_LOCAL(DOUBLE((Y - M)/S), const.UPPER)                          ; Set the significance of W to the result of ALNORM_LOCAL
RETURN, data                                                                    ; Return the data structure

END