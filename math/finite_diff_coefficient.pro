FUNCTION FINITE_DIFF_COEFFICIENT, derivative, order 
;+
; Name:
;   FINITE_DIFF_COEFFICIENT
; Purpose:
;   A function to return the coefficients for central finite differencing based
;   on the order of the derivative being taken and the accuracy required.
;   Coefficients can be found at https://en.wikipedia.org/wiki/Finite_difference_coefficient
; Inputs:
;   derivative : Order of the derivative begin computed. From 1-4.
;   order      : Order of the accuracy required. Varies based on derivative.
; Outputs:
;   Double precision array of coefficients.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 19 May 2016
;-
COMPILE_OPT IDL2, HIDDEN;   Set compiler options
CASE derivative OF
	1    :  BEGIN
	          CASE order OF
              2    : co = [-1.0D0/2.0D0,0.0D0,1.0D0/2.0D0]
              4    : co = [1.0D0/12.0D0,-2.0D0/3.0D0,0.0D1,2.0D0/3.0D0,-1.0D0/12.0D0]
              6    : co = [-1.0D0/60.0D0,3.0D0/20.0D0,-3.0D0/4.0D0,0.0D2,3.0D0/4.0D0,-3.0D0/20.0D0,1.0D0/60.0D0]
              8    : co = [1.0D0/280.0D0,-4.0D0/105.0D0,1.0D0/5.0D0,-4.0D0/5.0D0,0.0D3,4.0D0/5.0D0,-1.0D0/5.0D0,4.0D0/105.0D0,-1.0D0/280.0D0]
              ELSE : MESSAGE, 'Order not found!!!'
            ENDCASE
          END
	2    :  BEGIN
						CASE order OF
							2    : co = [1.0D0,-2.0D0,1.0D0]
							4    : co = [-1/12,4.0D0/3.0D0,-5.0D0/2.0D0,4.0D0/3.0D0,-1.0D0/12.0D0]
							6    : co = [1.0D0/90.0D0,-3.0D0/20.0D0,3.0D0/2.0D0,-49.0D0/18.0D0,3.0D0/2.0D0,-3.0D0/20.0D0,1.0D0/90.0D0]
							8    : co = [-1.0D0/560.0D0,8.0D0/315.0D0,-1.0D0/5.0D0,8.0D0/5.0D0,-205.0D0/72.0D0,8.0D0/5.0D0,-1.0D0/5.0D0,8.0D0/315.0D0,-1.0D0/560.0D0]
							ELSE : MESSAGE, 'Order not found!!!'
						ENDCASE
          END
	3    :  BEGIN
						CASE order OF
							2    : co = [-1.0D0/2.0D0,1.0D0,0.0D0,-1.0D0,1.0D0/2.0D0]
							4    : co = [1.0D0/8.0D0,-1.0D0,13.0D0/8.0D0,0.0D0,-13.0D0/8.0D0,1.0D0,-1.0D0/8.0D0]
							6    : co = [-7.0D0/240.0D0,3.0D0/10.0D0,-169.0D0/120.0D0,61.0D0/30.0D0,0.0D0,-61.0D0/30.0D0,169.0D0/120.0D0,-3.0D0/10.0D0,7.0D0/240.0D0]
							ELSE : MESSAGE, 'Order not found!!!'
						ENDCASE
          END
	4    :  BEGIN
						CASE order OF
							2    : co = [1.0D0,-4.0D0,6.0D0,-4.0D0,1.0D0]
							4    : co = [-1.0D0/6.0D0,2.0D0,-13.0D0/2.0D0,28.0D0/3.0D0,-13.0D0/2.0D0,2.0D0,-1.0D0/6.0D0]
							6    : co = [7.0D0/240.0D0,-2.0D0/5.0D0,169.0D0/60.0D0,-122.0D0/15.0D0,91.0D0/8.0D0,-122.0D0/15.0D0,169.0D0/60.0D0,-2.0D0/5.0D0,7.0D0/240.0D0]
							ELSE : MESSAGE, 'Order not found!!!'
						ENDCASE
          END
	ELSE : MESSAGE, 'Cannot compute higher than fourth derivative!'
ENDCASE
RETURN, co;  Return the coefficients
END