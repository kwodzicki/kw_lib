FUNCTION reassignPeriodogram, P, f, fcorr, nfft, range
	COMPILE_OPT IDL2, HIDDEN
	; for each column input of Sxx, reassign the power additively
	; independently.

	nChan = (SIZE(P, /DIMENSIONS))[1];

	nf = N_ELEMENTS(f);
	fmin = f[0];
	fmax = f[-1];

	; compute the destination row for each spectral estimate
	; allow cyclic frequency reassignment only if we have a full spectrum
	IF ISA(nfft, /SCALAR) AND STRLOWCASE(range) EQ 'twosided' THEN $
		rowIdx = 1 + (ROUND((fcorr-fmin)*(nf-1)/(fmax-fmin)) MOD nf) $
	ELSE $
		rowIdx = 1 + ROUND((fcorr-fmin)*(nf-1)/(fmax-fmin))

	; compute the destination column for each spectral estimate
	colIdx = INDGEN(nChan);repmat(1:nChan,nf,1);

	; reassign the estimates that fit inside the frequency range
;	P = P(:);
	idx = WHERE(rowIdx GE 1 AND rowIdx LE nf);
	RETURN, MATLAB_ACCUMARRAY([rowIdx[idx], colIdx[idx]], P[idx], [nf, nChan])
END

FUNCTION MATLAB_COMPUTEPERIODOGRAM, xin, winin, nfft, esttype, $
	Fs       = fs, $
	REASSIGN = reassign, $
	RANGE    = range
;+
;COMPUTEPERIODOGRAM   Periodogram spectral estimation.
;   This function is used to calculate the Power Spectrum Sxx, and the
;   Cross Power Spectrum Sxy.
;
;   Sxx = COMPUTEPERIODOGRAM(X,WIN,NFFT) where x is a vector returns the
;   Power Spectrum over the whole Nyquist interval, [0, 2pi).
;
;   Sxy = COMPUTEPERIODOGRAM({X,Y},WIN,NFFT) returns the Cross Power
;   Spectrum over the whole Nyquist interval, [0, 2pi).
;
;   Inputs:
;    X           - Signal vector or a cell array of two elements containing
;                  two signal vectors.
;    WIN         - Window
;    NFFT        - Number of frequency points (FFT) or vector of
;                  frequencies at which periodogram is desired
;    ESTTYPE     - A string indicating the type of window compensation to
;                  be done. The choices are: 
;                  'ms'    - compensate for Mean-square (Power) Spectrum;
;                            maintain the correct power peak heights.
;                  'power' - compensate for Mean-square (Power) Spectrum;
;                            maintain the correct power peak heights.
;                  'psd'   - compensate for Power Spectral Density (PSD);
;                            maintain correct area under the PSD curve.
;     REASSIGN   - A logical (boolean) indicating whether or not to perform
;                  frequency reassignment
;
;   Output:
;    Sxx         - Power spectrum [Power] over the whole Nyquist interval. 
;      or
;    Sxy         - Cross power spectrum [Power] over the whole Nyquist
;                  interval.
;
;    F           - (vector) list frequencies analyzed
;    RSxx        - reassigned power spectrum [Power] over Nyquist interval
;                  has same size as Sxx.  Empty when 'reassigned' option
;                  not present.
;    Fc          - center of gravity frequency estimates.  Same size as
;                  Sxx.  Empty when 'reassigned' option not present.
;
;   Copyright 1988-2015 The MathWorks, Inc.
;
; Adapted to IDL by Kyle R. Wodzicki 26 Apr. 2017
;-
COMPILE_OPT IDL2

IF N_PARAMS()           EQ 3 THEN esttype  = 'psd'															; Set default esttype
IF N_ELEMENTS(esttype)  EQ 0 THEN esttype  = 'psd'															; Set default esttype if empty variably input
IF N_ELEMENTS(reassign) EQ 0 THEN reassign = 0B																	; Set default value of reassign to false
IF N_ELEMENTS(Fs)       EQ 0 THEN Fs = 2 * !DPI																	; Use normalized frequencies when Fs is empty or is a NaN
IF FINITE(Fs, /NaN)     EQ 1 THEN Fs = 2 * !DPI

; Validate inputs and convert row vectors to column vectors.
is2sig = 0B
IF SIZE(xin, /TYPE) EQ 8 THEN BEGIN
	IF N_TAGS(xin) EQ 2 THEN BEGIN
		is2sig = 1B
		y = REFORM(xin.(1))
	ENDIF
	x = REFORM(xin.(0))
ENDIF ELSE $
	x = REFORM(xin)
win = REBIN(winin, SIZE(x, /DIMENSIONS))																				; Rebin the window input to be same size as x

xw = x * win																																		; Window the data

; Compute the periodogram power spectrum [Power] estimate
; A 1/N factor has been omitted since it cancels
dftX = MATLAB_computeDFT(xw, nfft, FS = Fs);

IF reassign EQ 1 THEN BEGIN
  xtw    = x * Fs / (2 * !PI) * DERIV(FINDGEN(N_ELEMENTS(win)), win);
  dftX_c = MATLAB_computeDFT(xtw, nfft, Fs);
  Fc     = -IMAGINARY( dftX_c.(0) / dftX.(0) );
  id     = WHERE(FINITE(Fc) EQ 0, CNT)
  IF CNT GT 0 THEN Fc[id] = 0
  Fc = dftX.(1) + TEMPORARY(Fc)
ENDIF

; if two signals are used, we are being called from welch and are not
; performing reassignment.
IF is2sig EQ 1 THEN yw = y * win

; Evaluate the window normalization constant.  A 1/N factor has been
; omitted since it will cancel below.
IF TOTAL(STRMATCH(['ms', 'power'], esttype, /FOLD_CASE), /INT) EQ 1 THEN BEGIN
  IF reassign EQ 1 THEN BEGIN
    IF ISA(nfft, /SCALAR) THEN $
      U = nfft * MATRIX_MULTIPLY(winin, winin, /ATRANSPOSE) $
    ELSE $
      U = N_ELEMENTS(winin) * MATRIX_MULTIPLY(winin, winin, /ATRANSPOSE)
  ENDIF ELSE $
    U = TOTAL(winin)^2																														; The window is convolved with every power spectrum peak, therefore compensate for the DC value squared to obtain correct peak heights.
ENDIF ELSE $
    U = TOTAL(winin^2)																														; compensates for the power of the window.

IF is2sig EQ 1 THEN BEGIN
  dftY = MATLAB_computeDFT(yw, nfft, FS = Fs);
  ; We use bsxfun here because Yy can be a single vector or a matrix
  Pxx = dftX.(0) * CONJ(dftY.(0)) / U;  ; Cross spectrum.
ENDIF ELSE $
  Pxx = dftX.(0) * CONJ(dftX.(0)) / U																						; Auto spectrum.

; Perform reassignment
IF reassign EQ 1 THEN $
;	MESSAGE, 'This option is not currently supported!' $
	RPxx = reassignPeriodogram(Pxx, dftX.(1), Fc, nfft, range) $ 
ELSE BEGIN
  RPxx = !Values.F_NaN; 
  Fc   = !Values.F_NaN;
ENDELSE

RETURN, {Pxx : Pxx, F : dftX.(1), RPxx : RPxx, Fc : Fc}

END