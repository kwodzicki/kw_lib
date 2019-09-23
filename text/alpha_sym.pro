PRO ALPHA_SYM, input, COLOR=color, FILL=fill, THICK=thick
;+
; Name:
;   ALPHA_SYM
; Purpose:
;   A function to return x and y indices for letters for use
;   as symbols in plotting
; Inputs:
;   A letter one wishes to plot.
; Outputs:
;   A two dimension array where the first row contains x values
;   for the letters and the second row contains y values for the
;   letters.
; Keywords:
;   COLOR   : Set to color to use for symbols.
;   FILL    : Set to fill in symbol.
;   THICK   : Set to the thickness of the symbol
; Dependencies
;   Requiers Ken Bowmans COLOR_24 fuction if the COLOR keyword is 
;   to be used
; Author and History:
;   Kyle R. Wodzicki    Created 2 Oct. 2014
;-

  COMPILE_OPT IDL2
  
  IF KEYWORD_SET(color) THEN color = COLOR_24(color)
  
  circ   = FINDGEN(17) * (!PI*2/16.0)
  lCirc  = FINDGEN(9)  * (!PI*2/16.0)-!PI/2                           ;Half circle opening to left
	rCirc  = FINDGEN(9)  * (!PI*2/16.0)+!PI/2                           ;Half circle opening to right
	uCirc  = FINDGEN(9)  * (!PI*2/16.0)+!PI                             ;Half circle opening to up
	dCirc  = FINDGEN(9)  * (!PI*2/16.0)-!PI                             ;Half circle opening to down
	
	tRCirc = FINDGEN(5)  * (!PI*2/16.0)                                 ;Top Right portion of circle
	bRCirc = FINDGEN(5)  * (!PI*2/16.0)-!PI/2                           ;bottom Right portion of circle
	bLCirc = FINDGEN(5)  * (!PI*2/16.0)-!PI                             ;Bottom left portion of circle
	tLCirc = FINDGEN(5)  * (!PI*2/16.0)+!PI/2                           ;Top left portion of circle
	CASE STRUPCASE(input) OF
	  'A'  : id = [[-1.0,  0.0,  1.0,  0.5, -0.5], $
	               [-1.0,  1.0, -1.0,  0.0,  0.0]]
	  'B'  : id = [[COS(lCirc),      COS(lCirc)], $
	               [SIN(lCirc)/2+0.5,SIN(lCirc)/2-0.5]]
	  'C'  : id = [[COS(FINDGEN(13)*(!PI*2/16.0)+!PI/4)], $
	               [SIN(FINDGEN(13)*(!PI*2/16.0)+!PI/4)]]
	  'D'  : id = [[-1.0, COS(lCirc), -1.0, -1.0], $
	               [-1.0, SIN(lCirc),  1.0, -1.0]]
	  'E'  : id = [[ 1.0, -1.0, -1.0, 0.0, -1.0, -1.0, -1.0, 1.0], $
	               [-1.0, -1.0,  0.0, 0.0,  0.0,  1.0,  1.0, 1.0]]
	  'F'  : id = [[-1.0, -1.0, 0.0, -1.0, -1.0, -1.0, 1.0], $
	               [-1.0,  0.0, 0.0,  0.0,  1.0,  1.0, 1.0]]
	  'G'  : id = [[0.1, COS(FINDGEN(13)*(!PI*2/16.0)+!PI/2), 0.2], $
	               [1.0, SIN(FINDGEN(13)*(!PI*2/16.0)+!PI/2), 0.0]]
	  'H'  : id = [[-0.8, -0.8, -0.8, 0.8, 0.8,  0.8], $
	               [-1.0,  1.0,  0.0, 0.0, 1.0, -1.0]]
	  'I'  : id = [[-0.8,  0.8,  0.0, 0.0, -0.8, 0.8], $
	               [-1.0, -1.0, -1.0, 1.0,  1.0, 1.0]]
	  'J'  : id = [[COS([bLCirc,bRCirc])/2, 0.5, 0.05, 0.95], $
	               [SIN([bLCirc,bRCirc])/2,   1.0, 1.0,  1.0]]
	  'K'  : id = [[-0.8, -0.8, -0.8, 0.8, -0.1,  0.8], $
	               [-1.0,  1.0,  0.0, 1.0,  0.4, -1.0]]
	  'L'  : id = [[0.9, -0.9, -0.9], [-1.0, -1.0, 1.0]]
	  'M'  : id = [[-1.0, -1.0,  0.0,  1.0,  1.0], $
	               [-1.0,  1.0,  0.0,  1.0, -1.0]]
	  'N'  : id = [[-0.8, -0.8,  0.8, 0.8], [-1.0,  1.0, -1.0, 1.0]]
	  'O'  : id = [[COS(circ)], [SIN(circ)]]
    'P'  : id = [[-0.5, COS([bRCirc, tRCirc])/2, -0.5, -0.5], $
                 [ 0.0, SIN([bRCirc, tRCirc])/2+0.5, 1.0, -1.0]]
    'Q'  : id = [[COS(circ-!PI/4)/1.1,  0.1,  1.0], $
                 [SIN(circ-!PI/4)/1.1, -0.1, -1.0]]
    'R'  : id = [[ 1.0, -1.0, COS([tRCirc,bRCirc]), -1.0, -1.0], $
                 [-1.0,  0.0, SIN([tRCirc,bRCirc])/2+0.5, 1.0, -1.0]]
    'S'  : id = [[-1.0, COS([bRCirc,tRCirc]), COS([bLCirc[-1:0:-1], tLCirc[-1:0:-1]]), 1.0], $
                 [-1.0, SIN([bRCirc,tRCirc])/2-0.5, SIN([blCirc[-1:0:-1], tLCirc[-1:0:-1]])/2+0.5, 1.0]]
    'T'  : id = [[-0.8, 0.8, 0.0, 0.0], [1.0, 1.0, 1.0, -1.0]]
    'U'  : id = [[-1.0, COS(uCirc), 1.0], [0.8, SIN(uCirc)-0.8, 0.8]]
    'V'  : id = [[-0.8, 0.0, 0.8], [0.8, -0.8, 0.8]]
    'W'  : id = [[-1.0, -0.4, 0.0,  0.4, 1.0], $
                 [ 1.0, -1.0, 0.0, -1.0, 1.0]]
    'X'  : id = [[-1.0, 1.0, 0.0, -1.0,  1.0], $
                 [-1.0, 1.0, 0.0,  1.0, -1.0]]
    'Y'  : id = [[-0.8, 0.0, 0.8, 0.0, 0.0], $
                 [1.0, 0.0, 1.0, 0.0, -1.0]]
    'Z'  : id = [[-1.0, 1.0, -1.0, 1.0], [1.0, 1.0, -1.0, -1.0]]
	  ELSE : MESSAGE, 'Must enter a letter from A-Z!!!'
	ENDCASE
	
	USERSYM, id[*,0], id[*,1], COLOR=color, $                 ;Set user symbol
	                           FILL=fill, THICK=thick
END