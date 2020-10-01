FUNCTION TRIAGE_SEGMENTS, window, nperseg, input_length

;+
; Name:
;   TRIAGE_SEGMENTS
; Purpose:
;   function to mimic that of scipy.signal.spectral._triage_segments
;   as that function is not callable through the IDL to Python bridge.
; Inputs
;   window : string, array
;        If window is specified by a string or tuple and nperseg is not
;        specified, nperseg is set to the default of 256 and returns a window of
;        that length.
;        If instead the window is array_like and nperseg is not specified, then
;        nperseg is set to the length of the window. A ValueError is raised if
;        the user supplies both an array_like window and a value for nperseg but
;        nperseg does not equal the length of the window.
;   nperseg : int
;        Length of each segment
;   input_length: int
;        Length of input signal, i.e. x.shape[-1]. Used to test for errors.
; Returns
;   win : ndarray
;        window. If function was called with string or tuple than this will hold
;        the actual array used as a window.
;   nperseg : int
;        Length of each segment. If window is str or tuple, nperseg is set to
;        256. If window is array_like, nperseg is set to the length of the
;        6
;        window.
;-

COMPILE_OPT IDL2

; parse window; if array like, then set nperseg = win.shape
IF ISA(window, 'STRING') THEN BEGIN
  ; if nperseg not specified
  IF N_ELEMENTS(nperseg) EQ 0 THEN $
    nperseg = 256  ; then change to default
  IF nperseg GT input_length THEN $
    ;MESSAGE, 'nperseg = {0:d} is greater than input length '
    ;                ' = {1:d}, using nperseg = {1:d}'
    ;                .format(nperseg, input_length)
    nperseg = input_length
  signal = Python.Import('scipy.signal')
  win    = signal.get_window(window, nperseg)
ENDIF ELSE BEGIN
  win = window
  IF win.NDIM NE 1 THEN $
      MESSAGE, 'window must be 1-D'
  IF input_length LT win.LENGTH THEN $
      MESSAGE, 'window is longer than input signal'
  IF N_ELEMENTS(nperseg) EQ 0 THEN $
      nperseg = win.LENGTH $
  ELSE IF N_ELEMENTS(nperseg) NE 0 THEN $
    IF nperseg NE win.LENTH THEN $
      MESSAGE, 'value specified for nperseg is different from length of window'
ENDELSE

RETURN, LIST(win, nperseg)

END
