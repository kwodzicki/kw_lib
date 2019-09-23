FUNCTION SIGNIF_TEST_R, sig, N, DOF = dof, TABLE = table
;+
; Name:
;   SIGNIF_TEST_R 
; Purpose:
;   An IDL function to compute the correlation coefficient required for the 
;   relation to be significant at a user defined significance level with 
;   a user defined degrees of freedom. Values match that of Appendix E of 
;   Thomson and Emery (2014) Data Analysis Methods in Physical Oceanography, 
;   3rd Edition.
; Inputs:
;   sig  : Significance level (in percent) to test at.
;   N    : Number of samples in your data. Used to determine degrees of freedom
;           defined as (N - 2). If DOF keyword is set, this value is NOT used.
; Outputs:
;   Returns the correlation coefficient required for a significant relationship.
; Keywords:
;   DOF : Set to the degrees of freedom you wish to use. Setting this OVERRIDES
;          the number of samples. Default is to use (N - 2)
;   TABLE : Set to print out a table like that of Appendix E of Thomson and 
;            Emery (2014). A 2-D array will be returned where the first row
;            is the DOF, second is r at 5% and third is r at 1%.
; Author and History:
;   Kyle R. Wodzicki     Created 12 Apr. 2017
;-
COMPILE_OPT IDL2

;=== Code to generate table of values
IF KEYWORD_SET(TABLE) THEN BEGIN
	dof = [INDGEN(30)+1,INDGEN(4)*5+35,INDGEN(5)*10+60,125, 150,INDGEN(4)*100+200,1000]	; Generate degrees of freedom for table
	out = FLTARR(N_ELEMENTS(dof), 3, /NoZero)																			; Initialize array to return
	out[0] = dof																																	; Write degrees of freedom to the out array
	PRINT, 'DoF', '5%', '1%', FORMAT="(A-6, A7, A7)"															; Print header
	PRINT, '----------------------------'																					; Print separator line
	FOR i = 0, N_ELEMENTS(dof)-1 DO BEGIN
		out[i,1:2] = [SIGNIF_TEST_R(5, DOF=dof[i]), SIGNIF_TEST_R(1, DOF=dof[i])]		; Compute correlation coefficients required for significant relations
		PRINT, STRTRIM(dof[i],2), out[i,1], out[i,2], FORMAT="(A-6, F7.3, F7.3)"		; Print out the correlation coefficients
	ENDFOR
	RETURN, out																																		; Return the out array
ENDIF 

;=== Actual code
IF (N_PARAMS() NE 2) AND N_ELEMENTS(dof) EQ 0 THEN $
	MESSAGE, 'Must input number of samples OR set DOF keyword!!!'
	
IF N_ELEMENTS(dof) EQ 0 THEN dof = N - 2																				; Set the degrees of freedom

IF SIZE(dof,/N_DIMENSIONS) EQ 0 THEN $
	t_sqrd = T_CVF(sig/200.0, dof)^2 $
ELSE BEGIN
	t_sqrd = MAKE_ARRAY(SIZE(dof,/DIMENSIONS), TYPE=SIZE(sig, /TYPE), /NoZero)			; Initialize array to store values in
	FOR i = 0, N_ELEMENTS(dof)-1 DO t_sqrd[i] = T_CVF(sig/200.0, dof[i])^2					; Iterate over all degrees of freedom and compute squared t statistic
ENDELSE

RETURN, SQRT( t_sqrd / (dof + t_sqrd ) )																				; Return the correlation coefficient

END