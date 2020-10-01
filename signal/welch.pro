FUNCTION WELCH, x, $
  Fs       = fs,       $
  WINDOW   = window,   $
  NPERSEG  = nperseg,  $
  NOVERLAP = noverlap, $
  DETREND  = detrend


COMPILE_OPT IDL2

IF N_ELEMENTS(fs)      EQ 0 THEN fs      = 1.0
IF N_ELEMENTS(window)  EQ 0 THEN window  = 'hann'
IF N_ELEMENTS(detrend) EQ 0 THEN detrend = 'constant'

res     = TRIAGE_SEGMENTS(window, nperseg, x.LENGTH)
win     = res[0]
nperseg = res[1]

IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = nperseg / 2

dof    = FFT_DOF(x.LENGTH, nperseg, noverlap)

signal = Python.Import('scipy.signal')

res    = signal.welch(x, fs=fs, window=win, nperseg=nperseg, noverlap=noverlap, $
          detrend=detrend)

RETURN, {F : res[0], PXX : res[1], DOF : dof} 

END
