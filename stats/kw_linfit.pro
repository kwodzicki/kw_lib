FUNCTION KW_LINFIT, xin, yin, $
  DETREND       = detrend, $
	RESIDUAL      = residual, $
	YFIT          = yhat, $
	CORRELATION   = corr, $
	CONF_INT      = conf_int, $
	CONF_VAL      = conf_val, $
	AUTOCOR       = autocor, $
	LEITH         = Leith, $
	LININTERP     = lininterp, $
  MEANINTERP    = meaninterp, $
	ALPHA_P_VAL	  = alpha_p_val, $
	BETA_P_VAL    = beta_p_val, $
	BETA_CONF_VAL = beta_conf_val, $
	CORR_SIG      = corr_sig, $
	VERBOSE       = verbose, $
	DOUBLE        = double

;+
; Name:
;   KW_LINFIT
; Purpose:
;   An IDL function to compute a linear fit of the form y = mx + b to data
;   and compute some statistics (t-tests, ANOVA) based on the keywords set.
; Inputs:
;   xin   : X-values (abscissa) of the data
;   yin   : Y-values (ordinate) of the data
; Outputs:
;   A two-element array where the first element is the y-intercept (b) and the
;   second element is the slope (m).
; Keywords:
;   RESIDUAL    : Set to named variable to return residuals of the fit to
;   YFIT        : Set to named variable to return fitted values to y-values to
;   CORR        : Set to named variable to return Pearson's sample correlation
;   CONF_INT    : Set the confidence interval for the CONF values, as a fraction
;                  Default is the 95% (0.95) confidence interval.
;   CONF_VAL    : Set to a named variable to return the values that can be added
;                  to the y-fits produce confidence limits for the data, i.e.,
;                  OPLOT, x, yfit+conf & OPLOT, x, yfit-conf.
;   AUTOCOR     : Set if the data are autocorrelated (i.e., time series data)
;   LEITH       : Set, in conjunction with the AUTOCOR keyword, to reduce the
;                  number of independent samples based on the
;   LININTERP   : Set to fill non-finite yin values using linear interpolation.
;                  If more than half the data points are not finite, no
;                  interpolation is performed and an error message is thrown.
;   ALPHA_P_VAL : Set to a named variable to return the p-value for the
;                  y-intercept
;   BETA_P_VAL  : Set to a named variable to return the p-value for the slope
;   CORR_SIG    : Set to named variable to return value the Pearson's sample
;                  variance must be GREATER THAN (less than the negative of for
;                  negative values) to be significant at the CONF_INT confidence
;                  level.
;		VERBOSE     : Set to print out table from ANOVA and t-stats
;   DOUBLE      : Set to return values in double precision. All calculations
;                  performed using double precision arithmetic.
; References
;   ch  3.2 of Devore and Farnum 2005
;   Ch 11.2 of Devore and Farnum 2005
;   Ch 9 of Gotelli and Ellison 2012
; Dependencies:
;   KW_EFFECT_DOF
;      KW_XCORR
; Author and History:
;   Kyle R. Wodzicki     Created 27 Apr. 2017
;-
COMPILE_OPT IDL2																																; Set compile options

IF (N_PARAMS() NE 2) THEN MESSAGE, 'Incorrect number of inputs!'								; Check number of inputs
IF N_ELEMENTS(xin) NE N_ELEMENTS(yin) THEN MESSAGE, 'N-elements of inputs differ!'
N = N_ELEMENTS(xin)																															; Number of elements in input array

detrend = (N_ELEMENTS(detrend) EQ 0) ? 'NONE' : STRUPCASE(detrend)

; Convert inputs to correct type based on keyword
type = KEYWORD_SET(double) ? 5 : 4
IF SIZE(xin, /TYPE) EQ 5 OR SIZE(yin, /TYPE) EQ 5 THEN type = 5

x = DOUBLE(xin)
y = DOUBLE(yin)

; Interpolate based on keyword
IF KEYWORD_SET(lininterp) THEN BEGIN
	good = WHERE(FINITE(yin), nGood, COMPLEMENT=bad, NCOMPLEMENT=nBad)						; Locate all finite and non-finite values
	IF (nBad NE 0) AND (nGood GT N/2) THEN $																														; If non-finite values are found
		y[bad] = INTERPOL(y[good], x[good], x[bad]); $
		;ELSE $
		;	MESSAGE, 'Too few good points (<1/2)...NO INTERPOLATION PERFORMED!', /CONTINUE
ENDIF ELSE IF KEYWORD_SET(meaninterp) THEN BEGIN
	good = WHERE(FINITE(yin), nGood, COMPLEMENT=bad, NCOMPLEMENT=nBad)						; Locate all finite and non-finite values
  IF (nBad NE 0) AND (ngood GT N/2) THEN y[bad] = MEAN(y[good])
ENDIF

IF detrend EQ 'BOTH' or detrend EQ 'X' THEN BEGIN
  _ = REGRESS(FINDGEN(x.LENGTH), x, YFIT=yfit)
  x -= yfit
ENDIF
IF detrend EQ 'BOTH' or detrend EQ 'Y' THEN BEGIN
  _ = REGRESS(FINDGEN(y.LENGTH), y, YFIT=yfit)
  y -= yfit
ENDIF

IF KEYWORD_SET(AUTOCOR) THEN Ns = KW_EFFECT_DOF(x, y, LEITH=Leith) ELSE Ns = N	; Set number of independent samples
IF N_ELEMENTS(conf_int) EQ 0 THEN conf_int = 0.95

Ns     = Ns > 3
beta   = REGRESS(x, y, CONST = alpha, YFIT = yHat, CORRELATION = corr)
yHat   = REFORM(yhat)
mean_x = MEAN(x)
Sxx    = TOTAL( (x - mean_x)^2, /DOUBLE )
SE     = SQRT( TOTAL( (y - yHat)^2, /DOUBLE ) / (Ns-2) ) / $
         SQRT( Sxx )


residual = y - yhat																															; Compute residuals of the fit

SSResid = TOTAL(residual^2, /DOUBLE)																						; Compute error sum of squares
MSE     = SSResid / (Ns-2)																											; Compute mean square error
MEr     = SQRT(MSE)																															; Compute mean error, i.e., square root of the mean square error


beta_sig  = MEr / SQRT(Sxx)																											; Standard deviation for slope
alpha_sig = MEr * SQRT(1.0/N + (mean_x)^2/Sxx)																	; Standard deviation for intercept

;corr_sig     = SIGNIF_TEST_R(conf_int, N)                                      ; Compute r value for significance
;beta_t_stat  = FIX( beta / beta_sig, TYPE = type)													  	; Compute t-statistic for the slope
;alpha_t_stat = FIX( alpha / alpha_sig, TYPE = type)														; Compute t-statistic for the intercept
IF Ns GT 2 THEN BEGIN
  corr_sig      = SIGNIF_TEST_R(conf_int*100.0, Ns)                               ; Compute r value for significance
  ;beta_t_stat   = FIX( beta / beta_sig, TYPE = type)														  ; Compute t-statistic for the slope
  beta_t_stat   = FIX( beta / SE, TYPE = type)														  ; Compute t-statistic for the slope
  alpha_t_stat  = FIX( alpha / alpha_sig, TYPE = type)														; Compute t-statistic for the intercept
  beta_p_val    = FIX( 2 - 2 * T_PDF(ABS(beta_t_stat), Ns-2), TYPE = type)				; Compute p-value for slope t-statistic
  alpha_p_val   = FIX( 2 - 2 * T_PDF(ABS(alpha_t_stat), Ns-2), TYPE = type)		  ; Compute p-value for intercept t-statistic
  beta_conf_val = [-1, 1] * T_CVF((1-conf_int)/2.0, Ns-2) * MEr * SQRT(1/Sxx)   ; Confidence limits
  beta_conf_val = FIX( beta + beta_conf_val, TYPE = type)
  conf_val      = FIX( T_CVF((1-conf_int)/2.0, Ns-2) * MEr * $                   ; Compute the confidence limits for the slope
                   SQRT( 1.0/N + (x-mean_x)^2 / Sxx ), TYPE = type)
;  conf_val     = FIX( T_CVF((1-CI)/2.0, Ns-2) * MEr * $                               ; Compute the confidence limits for the slope
;                   SQRT( 1.0/N + (x-mean_x)^2 / Sxx ), TYPE = type)
ENDIF ELSE BEGIN
  corr_sig     = !Values.F_NaN                                                  ; Compute r value for significance
  beta_t_stat  = !Values.F_NaN							                      					  	; Compute t-statistic for the slope
  alpha_t_stat = !Values.F_NaN							                      							; Compute t-statistic for the intercept
  beta_p_val   = !Values.F_NaN
  alpha_p_val  = !Values.F_NaN
  conf_val     = !Values.F_NaN
ENDELSE
;PRINT, beta, beta_p_val, bet a_conf_val;

;=== ANOVA
;MSRegr  = SSRegr
;MSResid = SSResid / (Ns - 2)
;F_stat  = MSRegr / MSResid
;Fp_val  = Ns GT 2 ? 1-F_PDF(F_stat, 1, Ns-2) : !Values.F_NaN

;=== VERBOSE testing
IF KEYWORD_SET(verbose) THEN BEGIN
	PRINT, 'Analysis of Variance', FORMAT="(A50)"
	PRINT,       '',   '',  'Sum of',   'Mean', FORMAT="(2A10,2A15)"
	PRINT, 'Source', 'DF', 'Squares', 'Square', 'F Value', 'Prob>F', FORMAT="(A-10,A10,4A15)"
	PRINT, STRJOIN(REPLICATE('-', 80))
	PRINT, 'Model',      1,  SSRegr, SSRegr, F_stat, Fp_val, FORMAT="(A-10,I10,2F15.5,F15.3,F15.4)"
	PRINT, 'Error',   Ns-2, SSResid,    MSE, FORMAT="(A-10,I10,2F15.5)"
	PRINT, 'C Total', Ns-1, Syy,  FORMAT="(A-10,I10,F15.5)"
	PRINT, '', 'Root MSE',     MEr, 'R-square',     Cod, FORMAT="(A3,2(A-10,F15.5,4x))"
	PRINT, '', 'Dep Mean', sum_y/N, 'Adj R-sq', CoD_adj, FORMAT="(A3,2(A-10,F15.5,4x))"
	PRINT, '', 'C.V.', 100*MEr*N/sum_y, FORMAT="(A3,A-10,F15.5)"
	PRINT, 'Parameter Estimates', FORMAT="(A50)"
	PRINT,       '',   '',  'Parameter', 'Standard',    'T for H0', FORMAT="(A12,A8,3A15)"
	PRINT, 'Variable',  'DF', 'Estimate',    'Error', 'Parameter=0', 'Prob > |T|', FORMAT="(A-12,A8,4A15)"
	PRINT, STRJOIN(REPLICATE('-', 80))
	PRINT, 'Intercept',    1,      alpha,  alpha_sig,  alpha_t_stat,  alpha_p_val, FORMAT="(A-12,I8, 4F15.6)"
	PRINT, 'Slope',        1,       beta,   beta_sig,   beta_t_stat,   beta_p_val, FORMAT="(A-12,I8, 4F15.6)"
ENDIF

RETURN, FIX([alpha, beta], TYPE = type)
END
