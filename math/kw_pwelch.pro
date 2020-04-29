FUNCTION KW_PWELCH, time, xx, yy, DIMENSION=dimension, WINDOW=window, NOVERLAP=noverlap
COMPILE_OPT IDL2

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1
info = SIZE(xx)
Lx   = info[dimension]

;== Segment information
IF N_ELEMENTS(window) EQ 0 THEN BEGIN
  IF N_ELEMENTS(noverlap) EQ 0 THEN BEGIN
    L = FIX( Lx / 4.5 )                                                         ; Determine number of points in the d
    IF L LT 2 THEN MESSAGE, 'Not enough samples for default settings!'          ; If L is less than 2 then message
    noverlap = FIX(0.5 * L)                                                     ; Determine size of overlap
  ENDIF ELSE $
    L = FIX( (Lx + 7 * noverlap) / 8)                                           ; Determine L based on user input ove
  window = MATLAB_WINDOW(l, 'HAMMING')                                          ; Construct Hamming window
ENDIF ELSE BEGIN
  IF SIZE(window, /TYPE) EQ 7 THEN $
    MESSAGE, 'Window must be Scalar or Vector!' $
  ELSE IF N_ELEMENTS(window) GT 1 THEN $
    L = N_ELEMENTS(window) $
  ELSE IF N_ELEMENTS(window) EQ 1 THEN BEGIN
    L = window
    window = MATLAB_WINDOW(window, 'HAMMING')
  ENDIF
  IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = FIX( 0.5 * L )                   ; Use 50% overlap as default
ENDELSE

; Argument validation
k = DOUBLE( (Lx - noverlap) / (L - noverlap) )                                  ; Compute number of segments
IF L GT Lx       THEN MESSAGE, 'Invalid Segment Length!'
IF noverlap GE L THEN MESSAGE, 'Noverlap too big!'

LminusOverlap = L-noverlap
xStart = LINDGEN(k) * LminusOverlap
xEnd   = xStart + L - 1
nn     = (xEnd[0]-xStart[0])+1
psd    = DCOMPLEXARR( nn )

FOR i = 0, N_ELEMENTS(xStart)-1 DO $
  IF N_ELEMENTS(yy) GT 0 THEN $
    psd += KW_PSD(time[xStart[i]:xEnd[i]], xx[xStart[i]:xEnd[i]], yy[xStart[i]:xEnd[i]], WINDOW=window ) $
  ELSE $
    psd += KW_PSD(time[xStart[i]:xEnd[i]], xx[xStart[i]:xEnd[i]], WINDOW=window)
psd /= N_ELEMENTS(xStart)

RETURN, psd
END  
