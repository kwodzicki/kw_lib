FUNCTION SIGN_LOCAL, a, b

infoA  = SIZE(a)
infoB  = SIZE(b)

IF infoB[-1] GT 1 THEN BEGIN
  IF infoA[-1] EQ 1 THEN $
    signs = MAKE_ARRAY( infoB[1:infoB[0]], TYPE = infoA[-2] ) $
  ELSE IF infoB[-1] NE infoA[-1] THEN $
    MESSAGE, 'Size missmatch'
 
  here_ge = WHERE( b GE 0, nge, COMPLEMENT=here_lt, NCOMPLEMENT=nlt )
  IF nge GT 0 THEN signs[ here_ge ] =  a[ here_ge ] 
  IF nlt GT 0 THEN signs[ here_lt ] = -a[ here_lt ] 
ENDIF ELSE IF infoA[-1] EQ 1 THEN BEGIN
  IF b GE 0 THEN RETURN, ABS(a) ELSE RETURN, -ABS(a)
ENDIF ELSE $
  MESSAGE, 'Size missmatch'

RETURN, signs

END
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
	
  IF NOT UP THEN ALNORM = ONE - ALNORM
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

FUNCTION POLY_LOCAL, C, NORD, X
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
  POLY = c[0]
  IF (NORD EQ 1) THEN RETURN, POLY
  P = X * c[NORD-1]
  IF NORD NE 2 THEN BEGIN
    N2 = NORD-2
    J  = N2 + 1
    FOR i = 1, N2 DO BEGIN
      P = (P+c[j-1]) * X
      J = J -1
    ENDFOR 
  ENDIF
  RETURN, POLY + p
  ;RETURN, TOTAL( C * X^FINDGEN( N_ELEMENTS(C) ) )
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION SWILK, X, A, INIT
;+
; Name:
;   SWILK
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
COMPILE_OPT IDL2, HIDDEN                                                        ; Set compile options

;=== Define a structure of constants
C1    = [0.0E0,       0.221157E0, -0.147981E0, -0.207119E1,  0.4434685E1, -0.2706056E1]
C2    = [0.0E0,       0.42981E-1, -0.293762E0, -0.1752461E1, 0.5682633E1, -0.3582633E1]
C3    = [0.5440E0,   -0.39978E0,   0.25054E-1, -0.6714E-3]
C4    = [0.13822E1,  -0.77857E0,   0.62767E-1, -0.20322E-2]
C5    = [-0.15861E1, -0.31082E0,  -0.83751E-1,  0.38915E-2]
C6    = [-0.4803E0,  -0.82676E-1,  0.30302E-2]
C7    = [0.164E0,     0.533E0]
C8    = [0.1736E0,    0.315E0]
C9    = [0.256E0,    -0.635E-2]
G     = [-0.2273E1,   0.459E0]
Z90   = 0.12816E1
Z95   = 0.16449E1
Z99   = 0.23263E1
ZM    = 0.17509E1
ZSS   = 0.56268E0
BF1   = 0.8378E0
XX90  = 0.556E0
XX95  = 0.622E0
ZERO  = 0.0E0
ONE   = 1.0E0
TWO   = 2.0E0
THREE = 3.0E0
SQRTH = 0.70711E0
QTR   = 0.25E0
TH    = 0.375E0
SMALL = 1E-19
PI6   = 0.1909859E1
STQR  = 0.1047198E1
UPPER = 1B

PW     = 0.0
W      = 0.0
INIT   = 0B

N      = N_ELEMENTS(x)
N1     = N
N2     = N/2
PW     = ONE
AN     = N
IFAULT = 3B
NN2    = N / 2
IF (N2 LT nn2) THEN RETURN, -1
IFAULT = 1B
IF (N LT 3) THEN RETURN, -1


IF (NOT INIT) THEN BEGIN                                                        ; If INIT is false, calculates coefficients for the test
  IF N EQ 3 THEN $                                                       ; IF there are only three (3) values input
    A[0] = SQRTH $                                                   ; Set the first element of A to a constant
  ELSE BEGIN                                                                    ; ELSE
    AN25   = AN + QTR
    tmp    = ((FINDGEN(N2)+1) - TH) / AN25
    A[0]   = PPND_LOCAL( tmp, IFAULT )                                     ; Set A equal to the result of PPND_LOCAL
    SUMM2  = TOTAL(A^2) * TWO																							; Define SUMM2 as the sum of the squares of A x 2
		SSUMM2 = SQRT( SUMM2 )                                                      ; Define SSUMM2 as the square root of SUMM2
    RSN    = ONE / SQRT(AN)                                           ; Define RSN as 1 / (square root of number of data points input)
    A1     = POLY_LOCAL(C1, 6, RSN) - A[0] / SSUMM2                     ; Define A1 as the result of POLY_LOCAL
    
    ;=== Normalize coefficients
    IF (N GT 5) THEN BEGIN                                                 ; If there were greater than five (5) data points input
      I1  = 3
      A2  = -A[1] / SSUMM2 + POLY_LOCAL(C2, 6, RSN)                     ; Compute value for the second element of A
      FAC = (SUMM2     - TWO * A[0]^2 - TWO * A[1]^2) / $ ; Compute the fator for normalizing the coefficients
            (ONE - TWO * A1^2        - TWO * A2^2)
      A[1] = A2                                                            ; Set the second element of A to A2
    ENDIF ELSE BEGIN
      I1  = 2                                                                   ; Set the index for writing data to the A array to one (1)
      FAC = (SUMM2 - TWO * A[0]^2) / (ONE - TWO * A1^2)  ; Compute the factor for normalizing the coefficients
    ENDELSE
    A[0]    = A1                                                           ; Set the first element of A to A1
    A[I1-1] = -A[I1-1:*] / SQRT(FAC)
  ENDELSE
ENDIF

IF (N1 LT 3) THEN RETURN, {W : w, PW : pw}                                                 ; If N1 is less than three (3) then return the data structure

NCENS = N - N1                                                             ; Define NCENS as the number of data points input minus N1
IFAULT = 4B                                                                ; Set the IFAULT value to four (4)
IF (NCENS LT 0 OR (NCENS GT 0 AND N LT 20)) THEN RETURN, {W : w, PW : pw}             ; IF NCENS is negative OR (NCENS is GT zero and the number of data points input is less than 20) return the data structure
IFAULT = 5B                                                                ; Set the IFAULT value to five (5)

delta = FLOAT(NCENS)/N                                                     ; Define delta as the ratio of NCENS to N
IF (delta GT 0.8) THEN RETURN, {W : w, PW : pw}                                 ; If delta is greater than 0.8 then return the data structure
IF (W LT ZERO) THEN BEGIN                                            ; IF the W value is less than zero (0), calculate significance level of -W
  W1 = ONE + W                                                       ; Define the W1 variabel as W + 1
  IFAULT = 0B                                                              ; Set the IFAULT value in the data structure to zero (0)
ENDIF ELSE BEGIN                                                                ; Else, the value of W must be greater or equal to zero
	IFAULT = 6B                                                              ; Set the IFALUT value in the data structure to six (6)
	range = X[-1] - X[0]                                                ; Calculate the range of the data
	IF (range LT SMALL) THEN RETURN, {W : w, PW : pw}                       ; If the range of the data is less than the value of small, then return the data structure
	;=== Check for correct sort order on range - scaled X
	IFAULT = 7B                                                              ; Set the IFALUT value in the data structure to seven (7)
  XX = x / RANGE
  SX = TOTAL(XX)
	SA = -a[0]
	FOR i = 1, N2 DO BEGIN                                                        ; Iterate from one (1) to N2
	  SA -= A[i-1]                                                           ; Subtract the first value of A from the SA variable
	  SA += A[-i]                                                            ; Add the last value of A from the SA variable
	ENDFOR                                                                        ; END i

	IFAULT = 0B                                                              ; Set the IFALUT value in the data structure to zero (0)
	IF (N GT 5000) THEN IFAULT = 2B                                     ; If the number of data points in put is greater than 5,000, then set IFAULT to two (2)
	;=== Calculate W statistic as squared correlation between data and coefficients
	SA   = SA / N1                                                                 ; Divide SA by N1
	SX   = SX / N1                                                                 ; Divide SX by N1
	SSX  = SX - SX                                                           ; Define SSX as the scaled_X values minus SX
	ASA  = MAKE_ARRAY(N, VALUE=-SA)                                                 ; Initialize SSA as a float array that is the same size as the input data
  i    = LINDGEN(N1)
  j    = REVERSE(i)
  idNE = WHERE( i NE j, cntNE )
  IF cntNE GT 0 THEN $
    ASA[idNE] += SIGN_LOCAL(1, i[idNE] - j[idNE] ) * $
                 A[ MIN( [ [ i[idNE] ], [ j[idNE] ] ], DIMENSION=2) ]
  XSX = X / RANGE - SX
  SSA = TOTAL(ASA * ASA)
  SSX = TOTAL(XSX * XSX)
  SAX = TOTAL(ASA * XSX)


  ;=== W1 equals (1-W) calculated to avoid excessive rounding error
  ;=== for W very near 1 (a potential problem in very large samples)
	SSASSX = SQRT(SSA * SSX)                                                      ; Compute the square root of SSA x SSX
	W1     = (SSASSX - SAX) * (SSASSX + SAX)/(SSA * SSX)                          ; Define W1
ENDELSE

W = ONE - W1                                                         ; Set W to 1 - Wq

IF (N EQ 3) THEN BEGIN                                                     ; If there were only three (3) data points input
  PW = PI6 * (ASIN(SQRT(W)) - STQR)                       ; Calculate significance level for W (exact for N=3)
  RETURN, {W : w, PW : pw}                                                                  ; Return the data structure
ENDIF

Y  = ALOG(W1)                                                                   ; Define y as the log base e of W1
XX = ALOG(N)                                                               ; Define XX as the log base e of N
M  = ZERO
S  = ONE
IF (N LE 11) THEN BEGIN                                                    ; IF there were less than or equal to eleven (11) data points input
  GAMMA = POLY_LOCAL(G, 2, AN)                                           ; Define gamma as the result of POLY_LOCAL
  IF (Y GE GAMMA) THEN BEGIN                                                    ; If Y is greater or equal to gamma
    PW = SMALL                                                       ; Set the significane level for W to small
    RETURN, {W : w, PW : pw}                                                    ; Return the data structure
  ENDIF
  Y = -ALOG(GAMMA - Y)                                                          ; Re-define y as the negative of the log base e of (gamma - y)
  M = POLY_LOCAL(C3, 4, AN)                                              ; Define M as the result of POLY_LOCAL
  S = EXP(POLY_LOCAL(C4, 4, AN))                                         ; Define S as the exponential of the result of POLY_LOCAL
ENDIF ELSE BEGIN                                                                ; ELSE, the number of data points input is greater than 11
  M = POLY_LOCAL(C5, 4, XX)                                                  ; Define M as the result of POLY_LOCAL
  S = EXP(POLY_LOCAL(C6, 3, XX))                                             ; Define S as the exponential of the result of POLY_LOCAL
ENDELSE

IF (NCENS GT 0) THEN BEGIN                                                      ; IF NCENS is greater than zero (0)
  ;=== Censoring by proportion NCENS/N.  Calculate mean and sd of normal
  ;=== equivalent deviate of W.
  LD   = -ALOG(delta)
  BF   = ONE + XX * BF1
  Z90F = Z90 + BF * POLY_LOCAL(C7, 2, XX90^XX)^LD
  Z95F = Z95 + BF * POLY_LOCAL(C8, 2, XX95^XX)^LD
  Z99F = Z99 + BF * POLY_LOCAL(C9, 2, XX)^LD
  ;=== Regress Z90F,...,Z99F on normal deviates Z90,...,Z99 to get
  ;=== pseudo-mean and pseudo-sd of z as the slope and intercept
  ZFM = (Z90F + Z95F + Z99F) / THREE
  ZSD = (Z90*(Z90F-ZFM) + Z95*(Z95F-ZFM) + Z99*(Z99F-ZFM)) / ZSS
  ZBAR = ZFM - ZSD * ZM
  M = M + ZBAR * S
  S = S * ZSD
ENDIF

PW = ALNORM_LOCAL(DOUBLE((Y - M)/S), UPPER)                          ; Set the significance of W to the result of ALNORM_LOCAL
RETURN, {W : w, PW : pw}                                                                    ; Return the data structure

END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION SHAPIRO, X_IN, NaN = NaN, DIMENSION=dimension
;+
; Name:
;   SHAPIRO
; Purpose:
;   Perform Shapiro Wilk test for normality
; Inputs:
;   x_in : Array of data
; Keywords:
;   NaN      : Boolean, set to exclude NaN values
;   DIMENSION : Set to dimesion to perform test over; Default is 1
; Returns:
;   Structure:
;      W    : Test statistic
;      PW   : p-value for the hypothesis test
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1
x    = x_in
nn   = 1
info = SIZE(x)
IF (info[0] GT 1) THEN BEGIN
  IF dimension NE 1 THEN BEGIN
    dimIDs              = INDGEN(info[0])
    dimIDs[dimension-1] = 0
    dimIDS[0]           = dimension-1
    x                   = TRANSPOSE(x, dimIDs)
    info[1:info[0]]     = info[dimIDs+1]
  ENDIF
  nn = PRODUCT( info[2:info[0]], /INTEGER )
  x  = REFORM(x, info[1], nn )
ENDIF 
n = info[1]

IF n LT 3 THEN MESSAGE, 'Data must be at least length 3.'

W    = FLTARR(nn, /NoZero)
PW   = FLTARR(nn, /NoZero)

FOR i = 0, nn-1 DO BEGIN
  a = FLTARR(n)
  y = x[*,i]
  y = y[SORT(y)]
  IF KEYWORD_SET(nan) THEN BEGIN
    id = WHERE(FINITE(y,/NaN) EQ 0, CNT)
    y  = CNT GT 0 ? y[id] : !Values.F_NaN
  ENDIF
  data  = SWILK(y, a[0:(n/2)-1])
  W[ i] = data.W
  Pw[i] = data.PW
ENDFOR

IF nn GT 1 THEN BEGIN
  W  = REFORM(w,  info[2:info[0]])
  PW = REFORM(Pw, info[2:info[0]])
ENDIF

IF N_ELEMENTS(dimIDs) GT 0 THEN BEGIN
  sIDs = SORT(dimIDs)-1
  iid  = WHERE(sIDs GE 0)
  W    = TRANSPOSE(W,  sIDs[iid])
  PW   = TRANSPOSE(PW, sIDs[iid])
ENDIF

IF n GT 5000 THEN $
  MESSAGE, 'p-value may not be accurate for N > 5000', /CONTINUE

RETURN, {W : w, PW : pw}

END
