FUNCTION localComputeSpectra, Sxx, x, y, xStart, xEnd, win, options, $
	esttype, k, cmethod, freqVectorSpecified
	COMPILE_OPT IDL2,HIDDEN
	cmethod = STRUPCASE(cmethod)																									; Force cmethod string to uppercase
	FOR i = 0, k-1 DO BEGIN																												; Iterate over windows
		IF N_ELEMENTS(y) EQ 0 THEN $																								; If only x input
			in = x[xStart[i]:xEnd[i],*] $
		ELSE $																																			; If x AND y input
			in = { X : x[xStart[i]:xEnd[i],*], Y : y[xStart[i]:xEnd[i],*] }
    options.NFFT = (xEnd[i]-xStart[i])+1
		Pxx = MATLAB_COMPUTEPERIODOGRAM(in,win,options.NFFT,esttype,FS=options.Fs)	; Compute the periodogram
		CASE cmethod OF																															; Case of cmethod
			'PLUS'	:	Sxx = TEMPORARY(Sxx) + Pxx.(0)																	; If PLUS, sum the spectra
			'MAX'   :	Sxx = MAX( [ [Sxx], [k * Pxx.(0)] ], DIMENSION = 2 )						; If MAX, find the maximum between Sxx and Pxx
			'MIN'   : Sxx = MIN( [ [Sxx], [k * Pxx.(0)] ], DIMENSION = 2 )						; If MIN, find the minimum between Sxx and Pxx
		ENDCASE
	ENDFOR
	Sxx = TEMPORARY(Sxx) / k																											; Average the sum of the periodograms
	; Generate the freq vector directly in Hz to avoid roundoff errors due to
	; conversions later.
	IF freqVectorSpecified EQ 0 THEN $
		Pxx.(1) = MATLAB_PSDFREQVEC(NPTS = options.NFFT, FS = options.Fs)
	RETURN, MATLAB_COMPUTEPSD(Sxx, Pxx.(1), options.range, options.NFFT, $
		esttype, FS = options.Fs)
END

FUNCTION MATLAB_PWELCH, xin, yin, $
	WINDOW       = window, $
	NOVERLAP     = noverlap, $
	NFFT         = nfft, $
	FS           = fs, $
	FW					 = FW, $
	FREQRANGE    = freqrange, $
	SPECTRUMTYPE = spectrumType, $
	TRACE        = trace, $
	ConfLevel    = confLevel, $
	PLOT         = plot
;+
; Name:
;   MATLAB_PWELCH
; Purpose:
;   An IDL function to emulate the MATLAB pwelch function
; Inputs:
;   Array to compute the power spectral density (PSD) of. Can be 1D or 2D. 
;   If 2D, the PSD is computed individually for each row of data. By default, x 
;   is divided into the longest possible sections to obtain as close to but not 
;   exceed 8 segments with 50% overlap. Each section is windowed with a Hamming
;   window. The modified periodograms are averaged to obtain the PSD estimate.
;   If you cannot divide the length of x exactly into an integer number of 
;   sections with 50% overlap, x is truncated accordingly.
; Outputs:
;   Returns a structure with the PSD, frequencies, units of frequencies, and
;   (depending on keywords) the confidence limits on the estimates (not yet
;   implemented).
; Keywords:
;   WINDOW       : If window is a vector, pwelch divides the signal into  
;                  sections equal in length to the length of window. The  
;                  modified periodograms are computed using the signal sections 
;                  multiplied by the vector, window. If window is an integer, 
;                  the signal is divided into sections of length window. The  
;                  modified periodograms are computed using a Hamming window of  
;                  length window.
;   NOVERLAP     : Set to an integer to use noverlap samples of overlap from 
;                  section to section. noverlap must be a positive integer 
;                  smaller than window if window is an integer. noverlap must be
;                  a positive integer less than the length of window if window 
;                  is a vector. If you do not specify noverlap, or specify 
;                  noverlap as empty, the default number of overlapped samples
;                  is 50% of the window length.
;   NFFT         : Specifies the number of discrete Fourier transform (DFT)
;                  points to use in the PSD estimate. The default nfft is the
;                  greater of 256 or the next power of 2 greater than the length
;                  of the segments.
;   FS           : Used to set the sampling frequency of the data. If the unit 
;                  of time is seconds, then f is in cycles/sec (Hz). For real–
;                  valued signals, f spans the interval [0,fs/2] when nfft is 
;                  even and [0,fs/2) when nfft is odd. For complex-valued 
;                  signals, f spans the interval [0,fs).
;   FW           : A vector containing at least 2 elements that specifies the 
;                  normalized frequencies at which to compute the PSD estimates.
;                  (May not be implemented correctly yet 20170429)
;   FREQRANGE    : Specify the frequency range over which to return the 
;                  estimates. Valid options are: 'onesided', 'twosided', and
;                  'centered'. Default is 'onesided'.
;   SPECTRUMTYPE : Set to 'psd' to return a PSD or to 'power' to return the
;                  power spectrum. Default is 'psd'.
;   TRACE        : Set to 'maxhold' to return the maximum-hold spectrum 
;                  estimates or to 'minhold' to return the minimum-hold 
;                  spectrum estimates. The default is to return the average
;                  spectrum estimates.
;   CONFLEVEL    : Set to a fractional percentage (i.e., 0-1) to return the 
;                  confidence intervals for the PSD.
; For examples, refere to the MATLAB documentation for their pwelch function.
; Author and History:
;   Kyle R. Wodzicki     Created 12 Apr. 2017
;
; Development Notes 12 Apr. 2017
;   After playing with the MATLAB pwelch, the input data are split up into
;   subsets of length nFFT, with the window being the same size. The data
;   are windowed and fed into the computeDFT program, calls the FFT program, 
;   which pads or truncates the end of the input array to match the an nFFT
;   input value. While the individual slices of the input data may be as small
;   as 2, the default length of the array for the FFT is set to 256. Thus, the
;   function localFFT was created at the beginning of this function to mimic the
;   functionality of the fft command in MATLAB.
;   === Figure out what the computepsd matlab function does
;
; Development Notes 29 Apr. 2017
;   Tested up to the 'Welch PSD Estimate of a Multichannel Signal' examples from
;   the MATLAB documentation and all are working. I did skip over the 
;   'Upper and Lower 95%-Confidence Bounds' example as I have not yet 
;   implemented the code for the confidence bands.
;-
COMPILE_OPT IDL2

;===============================================================================
;=== Parse some inputs
IF N_ELEMENTS(spectrumType) EQ 0 THEN spectrumType = 'psd'											; Set default spectrum type
; Determine if one or two signals input
is2sig = 0B																																			; Set is two signals to false as default
x = REFORM(xin)
IF N_ELEMENTS(yin) GT 0 THEN y = REFORM(yin)
;IF SIZE(xin, /TYPE) EQ 8 THEN	BEGIN																							; Check if x type is structure
;	IF N_TAGS(xin) GT 1 THEN BEGIN
;		y = REFORM(xin.(1))																													; Set y removing any dimensions of length 1
;		is2sig = 1B																																	; Set two signals flag to true
;	ENDIF
;	x = REFORM(xin.(0))																														; Get x values from the structure and remove any dimensions of length 1
;ENDIF ELSE $
;	IF TOTAL(STRMATCH(['psd','power','ms'],spectrumType,/FOLD_CASE),/INT) EQ 0 THEN $
;		MESSAGE, 'Must input structure for given specturm type!' $
;	ELSE $
;		x = REFORM(xin)																															; Remove any dimensions of length 1

x_info   = SIZE(x)																															; Get information about x
Lx       = x_info[1] 																														; Set Lx to size of first dimension of x
isreal_x = SIZE(x, /TYPE) LT 6																									; Boolean for x is real, i.e., not complex
IF is2sig EQ 1 THEN BEGIN																												; If two signals input
	isreal_x = isreal_x AND SIZE(y, /TYPE) LT 6																		; Boolean for x is real, i.e., not complex
	y_info = SIZE(y)																															; Get dimensions of x
	Ly     = y_info[1]																														; Set Ly to size of first dimension of y
	IF Lx NE Ly THEN MESSAGE, 'Mismatched Length!'																; If Lx and Ly are NOT the same, message
	IF x_info[0] EQ 1 AND y_info[0] EQ 2 THEN $
		IF x_info[2] NE 1 AND y_info[2] NE 1 AND x_info[2] NE y_info[2] THEN $			; If second dimensions are NOT 1 and are NOT equal
			MESSAGE, 'Mismatched number of channesl!'
ENDIF

;== Segment information
IF N_ELEMENTS(window) EQ 0 THEN BEGIN
	IF N_ELEMENTS(noverlap) EQ 0 THEN BEGIN
		L = FIX( Lx / 4.5 )																													; Determine number of points in the default window
		IF L LT 2 THEN MESSAGE, 'Not enough samples for default settings!'					; If L is less than 2 then message
		noverlap = FIX(0.5 * L)																											; Determine size of overlap
	ENDIF ELSE $																							
		L = FIX( (Lx + 7 * noverlap) / 8)																						; Determine L based on user input overlap
	window = MATLAB_WINDOW(l, 'HAMMING')																					; Construct Hamming window
ENDIF ELSE BEGIN
	IF SIZE(window, /TYPE) EQ 7 THEN $
		MESSAGE, 'Window must be Scalar or Vector!' $
	ELSE IF N_ELEMENTS(window) GT 1 THEN $
		L = N_ELEMENTS(window) $
	ELSE IF N_ELEMENTS(window) EQ 1 THEN BEGIN
		L = window
		window = MATLAB_WINDOW(window, 'HAMMING')
	ENDIF
	IF N_ELEMENTS(noverlap) EQ 0 THEN noverlap = FIX( 0.5 * L )										; Use 50% overlap as default
ENDELSE

; Argument validation
IF L GT Lx       THEN MESSAGE, 'Invalid Segment Length!'
IF noverlap GE L THEN MESSAGE, 'Noverlap too big!'

options = {NFFT     : MAX([256, 2^CEIL(ALOG2(L))]), $														; Size of FFTs
					 FS       : N_ELEMENTS(fs) EQ 1 ? DOUBLE(fs) : !Values.D_NaN, $				; Default frequency is set to NaN here. Other programs check
					 AVERAGE  : 0B, $																											; Initialize AVERAGE in options structure
					 MAXHOLD  : 0B, $																											; Initialize MAXHOLD in options structure
					 MINHOLD  : 0B, $																											; Initialize MINHOLD in options structure
					 RANGE    : '', $																											; Initialize RANGE in options structure
					 CENTERDC : 0B}																												; Initialize CENTERED in options structure
IF N_ELEMENTS(nFFT) NE 0 THEN options.NFFT = nFFT																; Set to use input
IF N_ELEMENTS(freqrange) EQ 1 THEN $																						; If the freqrange keyword is set	
	IF STRUPCASE(freqrange) EQ 'CENTERED' THEN options.CENTERDC = 1B							; Check if it is set to centered and set option accordingly
IF N_ELEMENTS(trace) EQ 1 THEN $																								; If the trace keyword is set
	CASE STRUPCASE(trace) OF
		'MEAN'    : options.AVERAGE = 1B																						; Set the AVERAGE option to on
		'MAXHOLD' : options.MAXHOLD = 1B																						; Set the MAXHOLD option to on
		'MINHOLD' : options.MINHOLD = 1B																						; Set the MINHOLD option to on
		ELSE      : MESSAGE, 'Unrecognized option!'																	; Throw and error
	ENDCASE
options.RANGE = isreal_x EQ 1 AND N_ELEMENTS(FW) LE 1 ? 'onesided' : 'twosided'	; Set Range option base on keyword 
k = DOUBLE( (Lx - noverlap) / (L - noverlap) )																	; Compute number of segments

;=== Finished parsing args
;===============================================================================

freqVectorSpecified = N_ELEMENTS(options.NFFT) GT 1

IF freqVectorSpecified EQ 1 THEN BEGIN
	nFreqs = N_ELEMENTS(options.NFFT);
	IF STRUPCASE(options.RANGE) EQ 'ONESIDED' THEN $
  	MESSAGE, 'Inconsistent Range Option!'
	options.RANGE = 'twosided';
ENDIF ELSE $
	nFreqs = options.NFFT;

; Set dimension size base on 1D or 2D input array
dims = x_info[0] EQ 2 ? [nFreqs, x_info[2]] : nFreqs

LminusOverlap = L-noverlap;
xStart = LINDGEN(k) * LminusOverlap
xEnd   = xStart + L - 1;

Sxx     = MAKE_ARRAY(dims, TYPE=SIZE(x, /TYPE))																	; Initialize Sxx array that will be used in every option
cmethod = 'plus'																																; Set default cmethod used by all but two options
IF TOTAL(STRMATCH(['ms','power','psd'],spectrumType,/FOLD_CASE),/INT) EQ 1 THEN BEGIN
	IF options.MAXHOLD EQ 1 THEN BEGIN
		Sxx[*] = -!Values.F_INFINITY
		cmethod = 'max'
	ENDIF ELSE IF options.MINHOLD EQ 1 THEN BEGIN
		Sxx[*] = !Values.F_INFINITY
		cmethod = 'min'	
	ENDIF
	Pxx = localComputeSpectra(Sxx,x,[],xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)
ENDIF ELSE IF STRUPCASE(spectrumType) EQ 'CPSD' THEN $
  Pxx = localComputeSpectra(Sxx, x, y, xStart, xEnd, window,options,$
		spectrumType, k, cmethod, freqVectorSpecified) $
ELSE IF STRUPCASE(spectrumType) EQ 'TFE' THEN BEGIN
	Sxy = MAKE_ARRAY(dims, TYPE=SIZE(x, /TYPE))
  Pxx = localComputeSpectra(Sxx,x,[],xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)
	Pxy = localComputeSpectra(Sxy,y,x,xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)
	Pxx.(0) = Pxy.(0) / Pxx.(0)
ENDIF ELSE IF STRUPCASE(spectrumType) EQ 'MSCOHERE' THEN BEGIN
	Sxy = MAKE_ARRAY(dims, TYPE=SIZE(x, /TYPE))
	Syy = MAKE_ARRAY(dims, TYPE=SIZE(x, /TYPE))
  Pxx = localComputeSpectra(Sxx,x,[],xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)       
  Pyy = localComputeSpectra(Syy,y,[],xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)    
  Pxy = localComputeSpectra(Sxy,x,y,xStart,xEnd,window,options,$
		spectrumType,k,cmethod,freqVectorSpecified)    
  Pxx.(0) = ABS(Pxy.(0))^2 / (Pxx.(0) *  Pyy.(0))
ENDIF ELSE $
	MESSAGE, 'Unrecognized option!'

IF N_ELEMENTS(confLevel) NE 0 THEN $
	Pxx = CREATE_STRUCT(Pxx, 'Pxxc', !Values.F_NaN)

;=== Center power and frequency
IF options.CENTERDC EQ 1 THEN BEGIN
	nFreq = N_ELEMENTS(Pxx.(1))
	iseven     = (options.NFFT / 2) MOD 2 EQ 0
	isonesided = STRUPCASE(options.RANGE) EQ 'ONESIDED'
	IF isonesided EQ 1 THEN $
		IF iseven EQ 1 THEN BEGIN
			Pxx.(0)[1:-2] = Pxx.(0)[1:-2]/2.0
			IF N_TAGS(Pxx) EQ 4 THEN Pxx.Pxxc[1:-2] = Pxx.Pxxc[1:-2]/2.0
			idx = ABS([LINDGEN(nFreq-2)-nFreq+2, LINDGEN(nFreq)])
		ENDIF ELSE BEGIN
			Pxx.(0)[1:-1] = Pxx.(0)[1:-1]/2.0
			IF N_TAGS(Pxx) EQ 4 THEN Pxx.Pxxc[1:-1] = Pxx.Pxxc[1:-1]/2.0
			idx = ABS([LINDGEN(nFreq-1)-nFreq+1, LINDGEN(nFreq)])
		ENDELSE $
	ELSE $
		IF iseven EQ 1 THEN $
			idx = [LINDGEN(nFreq/2-1)+nFreq/2+1, LINDGEN(nFreq/2+1)] $
		ELSE $
			idx = [LINDGEN(nFreq/2)+nFreq/2+1, LINDGEN(nFreq/2 + 1)]
	Pxx_tmp = Pxx.(0)[idx, *]
	F_tmp   = Pxx.W[idx]
	IF N_TAGS(Pxx) EQ 4 THEN Pxxc_tmp = Pxx.Pxxc[idx,*]
	IF FINITE(options.Fs,/NaN) THEN options.Fs = 2 * !DPI
	IF isonesided EQ 1 THEN $
		F_tmp[0:-1-nFreq] = -F_tmp[0:-1-nFreq] $
	ELSE IF iseven EQ 1 THEN $
		F_tmp[0: nFreq/2-1] = F_tmp[0:nFreq/2-1] - Fs $
	ELSE $
		FF_tmp[0:(nFreq-1)/2] = F_tmp[0:(nFreq-1)/2] - Fs;
	IF N_TAGS(Pxx) EQ 4 THEN $
		Pxx = {Pxx  : TEMPORARY(Pxx_tmp), W : TEMPORARY(F_tmp), UNITS : Pxx.UNITS, $
					 Pxxc : TEMPORARY(Pxxc_tmp)} $
	ELSE $
		Pxx = {Pxx : TEMPORARY(Pxx_tmp), W : TEMPORARY(F_tmp), UNITS : Pxx.UNITS}
ENDIF

IF ISA(Pxx.(0), /FLOAT) THEN BEGIN
	tags = TAG_NAMES(Pxx)
	tmp = CREATE_STRUCT(tags[0], PXX.(0))
	FOR i = 1, N_TAGS(Pxx)-1 DO BEGIN
		IF SIZE(Pxx.(i), /TYPE) EQ 5 THEN $
			tmp = CREATE_STRUCT(tmp, tags[i], FLOAT(Pxx.(i))) $
		ELSE $
			tmp = CREATE_STRUCT(tmp, tags[i], Pxx.(i))
	ENDFOR
	Pxx = TEMPORARY(tmp)
ENDIF

Pxx = CREATE_STRUCT(Pxx, 'N_Segments', k, 'OPTIONS', options)										; Append the number of segments used and the options to the Pxx structure 
;=== Plot the data if the plot keyword is set
IF KEYWORD_SET(plot) THEN BEGIN
	DEVICE, GET_DECOMPOSED = decomposed	& DEVICE, DECOMPOSED = 1									; Get the decomposed state and set decomposed state to 1
	ch     = [!D.X_CH_SIZE / FLOAT(!D.X_VSIZE), !D.Y_CH_SIZE / FLOAT(!D.Y_VSIZE)]	; Size of characters in normal coordinates
	psd    = 10 * ALOG10(Pxx.(0))																									; Compute power
	pinfo  = SIZE(psd)																														; Get size information about psd
	xRange = [MIN(Pxx.W), MAX(Pxx.W)]																							; Set x-range
	yRange = [FLOOR(MIN(psd)), CEIL(MAX(psd))]																		; Set y-range
	gray   = 220 * (1L+256L*257L)																										; Set grid color for plot to light gray
	!P.BACKGROUND = !D.N_COLORS-1																									; Change background color to white
	!P.COLOR      = 0																															; Change plotting color to black
	WINDOW, xSize = 720, ySize = 720
	PLOT, Pxx.W, psd, xRange=xRange, xStyle=5, yRange=yRange, yStyle=5, /NoData		; Set up plotting area
	AXIS, xAxis=0, xRange=xRange, xStyle=1, xMinor=1,	xTickLen=1, xGridStyle=0, $	; Set up light gray x-grid lines
		xTickFormat="(A1)", xThick=0.25, COLOR = gray
	AXIS, yAxis=0, yRange=yRange, yStyle=1, yMinor=1, yTickLen=1, yGridStyle=0, $	; Set up light gray y-grid lines
		yTickFormat="(A1)", yThick=0.25, COLOR = gray
	PLOT, Pxx.W, psd[*,0], /NoErase, $																						; Plot the spectra
		xRange   = xRange, xStyle = 1, $
		yRange   = yRange, yStyle = 1, $
		xTickLen = -0.5 * ch[1], $
		yTickLen = -0.5 * ch[0], $
		Title    = 'Wlech Power Spectral Density Estimate', $
		xTitle   = 'Frequency ('+Pxx.UNITS+')', $
		yTitle   = STRUPCASE(Pxx.UNITS) EQ 'HZ' ? $
			          'Magnitude (dB)' : 'Power/frequnecy (dB/rad/sample)'
	IF pinfo[0] EQ 2 THEN BEGIN
		LOADCT, 34, NCOLORS = pinfo[2]-1, RGB = rgb, /SILENT												; Load a color table
		FOR i = 0, pinfo[2]-2 DO $																									; Overplot the other spectras 
			OPLOT, Pxx.W, psd[*,i+1], COLOR = rgb[i,0]+256L*(rgb[i,1]+256L*rgb[i,2])
	ENDIF
	!P.BACKGROUND = 0																															; Set plotting color back to white
	!P.COLOR      = !D.N_COLORS-1																									; Set background color back to black
	DEVICE, DECOMPOSED = decomposed																								; Set decomposed backed to original
ENDIF

RETURN, Pxx																																			; Return the data structure

END
