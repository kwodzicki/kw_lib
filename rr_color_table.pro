FUNCTION RR_COLOR_TABLE, color_table, contours, $
  BOTTOM=bottom, WHITE_BOTTOM=white_bottom, MIDDLE = middle, $
  COLOR_24 = color_24
;+
; Name:
;   RR_COLOR_TABLE
; Purpose:
;   A function to return 24-bit color values for the color
;   scale found on http://water.weather.gov/precip/
; Inputs:
;   None.
; Outputs:
;   None.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 19 Aug. 2015
;-

IF (N_ELEMENTS(color_table) EQ 0) THEN BEGIN
  r = [255, 74, 90, 51, 74, 60, 52,246,249,244,242,176,135,243,134,218]
  g = [255,199,141, 55,252,169,118,249,217,156, 34, 40, 43, 34, 90,218]
  b = [255,246,198,157, 70, 62, 55, 69,119, 62, 58, 52, 48,245,222,218]
ENDIF ELSE BEGIN
  nColors = N_ELEMENTS(contours)
  LOADCT, color_table, BOTTOM=bottom, NCOLORS=nColors, /SILENT
  TVLCT, r, g, b, /GET
  r = r[0:nColors-1]
  g = g[0:nColors-1]
  b = b[0:nColors-1]
  IF KEYWORD_SET(white_bottom) THEN BEGIN
    r[0] = 255
    g[0] = 255
    b[0] = 255
  ENDIF
  IF (N_ELEMENTS(middle) NE 0) THEN BEGIN
    id = MEDIAN(INDGEN(nColors))-1
    r[id] = middle
    g[id] = middle
    b[id] = middle
  ENDIF
ENDELSE

IF ~KEYWORD_SET(color_24) THEN $
  RETURN, [ [r], [g], [b] ] $
ELSE $
  RETURN,      ((0 > LONG(r)) < 255) + $                 ;Convert RGB to 24-bit color
          256*(((0 > LONG(g)) < 255) + $
          256* ((0 > LONG(b)) < 255))
END