FUNCTION KW_COHERENCE, x, y, alpha, $
  FS       = fs, $
  NOVERLAP = noverlap, $
  NPERSEG  = nperseg, $
  WINDOW   = window

COMPILE_OPT IDL2

signal     = Python.Import( 'scipy.signal' )

IF N_ELEMENTS(alpha)    EQ 0 THEN alpha    = 0.05
IF N_ELEMENTS(window)   EQ 0 THEN window   = 'hann'
IF N_ELEMENTS(fs)       EQ 0 THEN fs       = 1.0
IF N_ELEMENTS(nperseg)  EQ 0 THEN BEGIN
  res = TRIAGE_SEGMENTS(window, nperseg, x.LENGTH) 
  window  = res[0]
  nperseg = res[1]
ENDIF

IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = nperseg / 2 

IF noverlap GE nperseg THEN MESSAGE, 'NOVERLAP must be less than NPERSEG'

DoF  = FFT_DOF(N_ELEMENTS(x), nperseg, noverlap)
conf = 1 - alpha^(2.0 / (DoF-2) )

coh  = signal.coherence(x, y, fs=fs, window=window, nperseg=nperseg, noverlap=noverlap)
RETURN, {F : coh[0], Cxx : coh[1], CONF : conf, DOF : dof}

END
