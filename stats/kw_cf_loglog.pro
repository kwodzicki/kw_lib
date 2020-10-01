FUNCTION KW_CF_LOGLOG, val, sl, dof
;+
; Name:
;   KW_CF_LOGLOG
; Purpose:
;   An IDL function to return confidence limits for variance that can be used on
;   loglog plots
; Inputs:
;   val     : Val to compute confidence limits around
;   sl			: Significance level, in percent
;   dof			: Degrees of freedom
; Outputs:
;   Returns a two-element array where zeroth element is lower bound and first
;   element is upper bound
; Keywords:
;		None.
; Author and History:
;   Kyle R. Wodzicki     Created 03 Mar. 2017
;
; Notes:
;   Tabs set to 2
;-

COMPILE_OPT IDL2

sl2 = (1 - sl/1.0D2)/2.0D0

RETURN, [ [ val * dof / CHISQR_CVF(  sl2, dof)], $
					[ val * dof / CHISQR_CVF(1-sl2, dof)] ]


END
