FUNCTION MATLAB_PSDFREQVEC, npts = npts, FS = fs, RANGE = range, CENTERDC = centerDC, DOUBLE = double
;+
;PSDFREQVEC Frequency vector
;   PSDFREQVEC('Npts',NPTS) returns a frequency vector in radians based on
;   the number of points specified in NPTS. The vector returned assumes 2pi
;   periodicity.
;
;   PSDFREQVEC('Fs',FS) specifies the sampling frequency FS in hertz. By
;   default Fs is set to empty indicating normalized frequency.
;   
;   PSDFREQVEC('CenterDC',CENTERDC) specifies a boolean value in CENTERDC
;   which indicates if zero hertz should be in the center of the frequency
;   vector. CENTERDC can be one of these two values [ {false} | true ]. 
;
;   PSDFREQVEC('Range',RANGE) specifies the range of frequency in RANGE.
;   RANGE can be one of the two strings [ {whole} | half ]. Assuming
;   CenterDC=false then:
;       'whole' = [0, 2pi)
;       'half'  = [0, pi] for even NPTS or [0, pi) for odd NPTS
;
;   When CenterDC=true then:
;       'whole' = (-pi, pi] for even NPTs or (-pi, pi) for odd NPTs
;       'half'  = [-pi/2, pi/2] for even* NPTS or (-pi/2, pi/2) for odd NPTS
;
;       *When NPTS is not divisible by 4, then the range is (-pi/2, pi/2).
;
;   When Range='half' the frequency vector has length (NPTS/2+1) if NPTS is
;   even**, and (NPTS+1)/2 if NPTS is odd***.
;
;       **If CenterDc=true and the number of points specified is even is
;       not divisible by 4, then the number of points returned is NPTS/2.
;       This is to avoid frequency points outside the range [-pi/2 pi/2]. 
;
;       ***If CenterDC=true and the number of points NPTS specified is odd
;       and (NPTS+1)/2 is even then the length of the frequency vector is
;       (NPTS-1)/2.
;
;   Author(s): P. Pacheco
;   Copyright 1988-2004 The MathWorks, Inc.
;
; Adapted to IDL by
;   Kyle R. Wodzicki     Created 26 Apr. 2017
;-
COMPILE_OPT IDL2

IF N_ELEMENTS(npts)     EQ 0 THEN npts     = 1024
IF N_ELEMENTS(range)    EQ 0 THEN range    = 'whole'
IF N_ELEMENTS(centerDC) EQ 0 THEN centerDC = 0 
IF N_ELEMENTS(fs)       EQ 0 THEN fs       = 2 * !DPI
IF FINITE(fs, /NaN)     EQ 1 THEN fs       = 2 * !DPI

freq_res = Fs / DOUBLE(npts)																										; Compute the frequency resolution
w        = freq_res * DINDGEN(npts)																							; Create frequency array

Nyq = Fs / 2.0D0																																; Set the Nyquist frequency
half_res = freq_res / 2.0D0																											; Half the frequency resolution

; Determine if npts is odd and determine half the number of points
isNPTSodd = 0B
IF npts MOD 2 EQ 1 THEN BEGIN
	isNPTSodd = 1B
	halfNPTS = (npts+1) / 2
ENDIF ELSE $
	halfNPTS = npts / 2 + 1	

; Determine if half npts is odd and determine quarter the number of points
ishalfNPTSodd = 0B
IF halfNPTS MOD 2 EQ 1 THEN BEGIN
	ishalfNPTSodd = 1B
	quarterNPTS  = (halfNPTS+1) / 2
ENDIF ELSE $
	quarterNPTS = halfNPTS / 2 + 1	

; Adjust points on either side of the Nyquist
IF isNPTSodd EQ 1 THEN $
	w[halfNPTS] = Nyq - [half_res, -half_res] $
ELSE $
	w[halfNPTS] = Nyq

w[npts-1] = fs - freq_res

; Calculate the correct grid based on user specified values for range, centerDC, etc.
CASE STRLOWCASE(range) OF
	; Calculated by default [0, 2pi)
	'whole' : IF centerDC EQ 1 THEN BEGIN																					; (-pi,pi] if even, (-pi, pi) if odd
							negEndPt = isNPTSodd EQ 1 ? halfNPTS : halfNPTS - 1
							w = [-REVERSE(w[1:negEndPt]), w[0:halfNPTS]]
						ENDIF
	'half'	: BEGIN
							w = w[0:halfNPTS]																									; [-pi,pi] if even, [0, pi) if odd
							; For even number of points that are not divisible by 4, you get
							; less one point to avoid going outside the [-pi/2, p/2] range.
							IF centerDC EQ 1 THEN BEGIN																				; [-pi/2,pi/2] if even, (-pi/2, pi/2) if odd
								IF ishalfNPTSodd EQ 1 THEN $
									negEndPt = quaterNPTS $
								ELSE BEGIN
									quarterNPTS = quarterNPTS-1																		; Avoid going over 2 pi
									negEndPt    = quarterNPTS
								ENDELSE
								w = [-REVERSE(w[1:negEndPt]), w[0:halfNPTS]]
								IF npts MOD 4 EQ 0 THEN w[-1] = Nyq / 2.0D											; Make sure we hit pi/2 exactly when npts is divisible by 4!
							ENDIF
						END
	ELSE		: MESSAGE, 'Invalid value for range!'																	; Print error message	
ENDCASE

RETURN, KEYWORD_SET(double) ? w : FLOAT(w)																			; Return w as correct type based on double keyword

END