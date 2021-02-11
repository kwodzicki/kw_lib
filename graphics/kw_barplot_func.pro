FUNCTION KW_BARPLOT_FUNC, loc, values, $
  STACK_COLORS = stack_colors, $
  LEGEND       = legend, $
  _EXTRA = extra
;+
; Name:
;   KW_BARPLOT
; Purpose:
;   A function to extend a the barplot function.
; Keywords:
;   STACK_COLORS : Colors corresponding to stacked data, i.e., second dimension
;                   of values. Can be strings or 3 x n array of RGB values
;   LEGEND       : Set to named variable to return legend to
; Author and History:
;   Kyle R. Wodzicki
;-

COMPILE_OPT IDL2
IF N_PARAMS() EQ 0 THEN MESSAGE, 'Incorrect number of inputs!'

IF N_ELEMENTS(values) EQ 0 THEN BEGIN
  values = loc;
  dims   = SIZE(values, /DIMENSIONS)
  loc    = LINDGEN(dims[0])
ENDIF ELSE $
  dims = SIZE(values, /DIMENSIONS)
IF N_ELEMENTS(dims) GT 3 THEN MESSAGE, 'Input data has too many dimensions!' 

IF N_ELEMENTS(stack_colors) EQ 0 THEN BEGIN
  LOADCT, 34, NCOLORS=dims[1], RGB = colors
  colors = TRANSPOSE(colors)
ENDIF ELSE IF SIZE(stack_colors[0], /TYPE) EQ 7 THEN BEGIN
  colorSTR = TAG_NAMES(!COLOR)
  colors = LIST();
  FOR i = 0, N_ELEMENTS(stack_colors)-1 DO BEGIN
    id = WHERE(STRMATCH(colorSTR, stack_colors[i], /FOLD_CASE), CNT)
    IF CNT EQ 1 THEN $
      colors.ADD, !COLOR.(id[0]) $
    ELSE BEGIN
      MESSAGE, 'Color: '+stack_colors[i]+' NOT found! Using black!', /CONTINUE
      colors.ADD, [0,0,0];
    ENDELSE
  ENDFOR
  colors = colors.ToArray(/No_Copy, DIMENSIONS=2)
ENDIF

main = BARPLOT(loc, values[*,0,0], /NoData, yRange = [0, MAX(values)], $
  _EXTRA = extra)
legend = LEGEND(target = main)

IF N_ELEMENTS(dims) EQ 3 THEN BEGIN
  FOR k = 0, dims[-1]-1 DO $                                                    ; Iterate over values that are to be placed next to each other
    FOR j = 0, dims[-2]-1 DO BEGIN
      IF j GT 0 THEN old_tmp = tmp
      tmp = values[*,j,k]
      b = BARPLOT( loc, tmp, $
        INDEX         = k, $
        NBARS         = dims[-1], $
        BOTTOM_VALUES = (j GT 0) ? old_tmp : !NULL, $
        FILL_COLOR    = colors[j], $
        /OVERPLOT)
      WAIT, 2
      legend.ADD, target = b
    ENDFOR
ENDIF ELSE IF N_ELEMENTS(dims) EQ 2 THEN BEGIN
  PRINT, 'Not coded yet!'


ENDIF ELSE BEGIN
  PRINT, 'Not coded yet!'

ENDELSE

RETURN, main
END
