FUNCTION computeDFTviaFFT, xin, nx, nfft, fs
	; Use FFT to compute raw STFT and return the F vector
	COMPILE_OPT IDL2, HIDDEN
	xin_dims = SIZE(xin, /DIMENSIONS)
	IF nx GT nfft THEN BEGIN								; This is an issue but don't have time to debug 03 May 2017
		xw = DBLARR(nfft, xin_dims[1], /NoZero)
		FOR i = 0, xin_dims[1]-1 DO xw[0,i] = MATLAB_DATAWRAP(xin[*,i], nfft)
	ENDIF ELSE $
		xw = xin
	RETURN, { xx : MATLAB_FFT(xw, NFFT=nfft), $
	          F  : MATLAB_PSDFREQVEC(NPTS=nfft, FS=fs) }
END

FUNCTION computeDFTviaGoertzel, xin, nx, nfft, fs
	; Use Goertzel to compute raw STFT and return the F vector
	COMPILE_OPT IDL2, HIDDEN
	MESSAGE, 'Goertzel Not Currently Supported!'
	f     = f MOD fs
	xdims = SIZE(xin, /DIMENSION)
	k     = f / fs * xdims[0]
	xx = MAKE_ARRAY(N_ELEMENTS(k), dims[1], TYPE = SIZE(xin, /TYPE))
	FOR i = 0, xdims[1]-1 DO xx[0,i] = MATLAB_GOERTZEL(DOUBLE(xin[*,i]), k)
	
	RETURN, { xx : FIX(xx, TYPE = SIZE(xin, /TYPE)), F : f }
END

FUNCTION computeDFTviaCZT, xin, nx, nfft, fs
	; Use CZT to compute raw STFT and return the F vector
	COMPILE_OPT IDL2, HIDDEN
	MESSAGE, 'CZT Not Currently Supported!'
	RETURN, -1
END

FUNCTION MATLAB_COMPUTEDFT, xin, nfft, FS = fs
;+
; Name:
;   MATLAB_COMPUTEDFT
; Purpose:
;   An IDL function to emulate the computeDFT matlab function
; Inputs:
;   xin    : The inpute signal
;   nfft   : As scalar or vector specifying the number of FFT points used to 
;             calculate the DFT using FFT or the frequency points at which the
;             DFT is calculated using goertzel, respectively
; Outputs:
;   Returns a structure where the first tag is the DFT xx and the second tag
;   is the frequencies
; Keywords:
;   FS : set this to the sampling frequency (samples per second)
; Author and History:
;   Kyle R. Wodzicki     Created 26 Apr. 2017
;
COMPILE_OPT IDL2

IF N_ELEMENTS(fs) EQ 0 THEN fs = 2*!PI																					; Set default value of fs

info = SIZE(xin)
nx = info[1]																																		; Get number of columns in xin

IF N_ELEMENTS(nfft) EQ 1 THEN $																									; If length of nfft is greater than 1
	RETURN, computeDFTviaFFT(xin, nx, nfft, fs) $																	; Compute the fft
ELSE BEGIN
	f = nfft																																			; If nfft is a vector then it contains a list of frequencies

	; See if we can get a uniform spacing of the freq vector
	fstart = f[0]
	fstop  = f[-1]
	n      = N_ELEMENTS(f)
	linspa = FINDGEN(n) * (fstop-fstart)/FLOAT(n-1) + fstart
	err    = MAX(ABS(f - linspa) / MAX(ABS(f)))
	
	; See if the ratio of the maximum absolute deviation relative to the largest
	; absolute in the frequency vector is less than a few eps
	isuniform = err LT 3 * (MACHAR(DOUBLE = SIZE(f, /TYPE) EQ 5)).EPS
	
	; Check if the number of stops in the Goertzel ~ 1 k1 N * M greater than the
	; expected number of stpes in CZT ~ 20 kw n * log2(n+m-1) where k2/k1 is 
	; emperically found to be ~ 80
	n = (SIZE(xin, /DIMENSIONS))[0]
	islarge = m GT 80 * ALOG2( CEIL(ALOG2(m+n-1)) )
	
	IF islarge EQ 1 AND isuniform EQ 1 THEN $
		RETURN, computeDFTviaCZT(xin, nx, nfft, fs) $
	ELSE $
		RETURN, computeDFTviaGoertzel(xin, nx, nfft, fs)
ENDELSE

END