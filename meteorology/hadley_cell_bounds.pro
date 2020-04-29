PRO HADLEY_CELL_BOUNDS, vv, latitude, levels, psi_N, psi_S, $
	PSI      = psi, $
	PRESSURE = p, $
  PYTHON   = python
;+
; Name:
;   HADLEY_CELL_BOUNDS
; Purpose:
;   An IDL procedure to determine the boundaries of the Hadley circulation
;   using the methodology of Stachnik and Schumacher (2011).
; Inputs;
;   vv       : 2-D array of meridional winds. Should be zonal-mean
;   latitude : 1- or 2-D array of latitude values; must match size
;               of first dimension of vv if only 1-D
;   levels   : 1- or 3-D array of pressure values; must match size
;               of second dimension of vv if only 1-D; Pascals
; Outputs:
;   psi_N  : Latitude of the northern boundary of the Hadley cell
;              Will be NaN if no boundary found!
;   psi_S  : Latitude of the southern boundary of the Hadley cell
;              Will be NaN if no boundary found!
; Keywords:
;   PSI      : Set to named variable to return stream function to
;   PRESSURE : Set to named variable to return pressure levesl for psi to
;	  PYTHON   : Set to structure or dictionary containg command line arguments
;                for python version of HADLEY_CELL_BOUNDS
; Dependencies:
;   MASS_STREAM_FUNC
;   ZERO_CROSS
; Author and History:
;   Kyle R. Wodzicki     Created 18 Mar. 2019
;-
COMPILE_OPT IDL2

IF (N_ELEMENTS(python) NE 0) THEN BEGIN																					; If python keyword is set
	psi_N = !Values.F_NaN
	psi_S = !Values.F_NaN	
	IF (SIZE(python, /TYPE) NE 11) THEN $
		MESSAGE, 'python keyword MUST be dictionary!'
	IF python.HasKey('file') THEN BEGIN
		file = python.REMOVE('file')
		path = FILE_DIRNAME( ROUTINE_FILEPATH(/EITHER) )
		cmd  = [FILEPATH('hadley_cell_bounds.py', ROOT_DIR=path), file]
		FOREACH key, python.Keys() DO BEGIN
			IF (STRLEN(key) EQ 1) THEN cmd = [cmd, '-' + key, STRTRIM(python[key],2)] $
														ELSE cmd = [cmd, '--'+ key, STRTRIM(python[key],2)]
		ENDFOREACH
		python['file'] = file

		findNCDF = "import importlib; print( importlib.util.find_spec('netCDF4').origin)"	;Command to get location of netCDF4 in python
		SPAWN, 'python -c "' + findNCDF + '"', stdout, stderr
		IF (stdout NE '') THEN BEGIN
			libs = FILEPATH('.dylibs', ROOT_DIR=FILE_DIRNAME(stdout)) 
			cmd  = ['DYLD_LIBRARY_PATH='+libs, cmd]
		ENDIF

		SPAWN, STRJOIN(cmd, ' '), stdout, stderr
		IF (stdout NE '') THEN BEGIN
			tmp = STRSPLIT(stdout, ',', /EXTRACT)
			psi_N = FLOAT( (STRSPLIT(tmp[0], ':', /EXTRACT))[-1] )
			psi_S = FLOAT( (STRSPLIT(tmp[1], ':', /EXTRACT))[-1] )
		ENDIF
	ENDIF ELSE $
		MESSAGE, 'No file path in python info!!!'

	RETURN
ENDIF ELSE IF (N_PARAMS() LT 3) THEN MESSAGE, 'Incorrect number of inputs!'

MASS_STREAM_FUNC, vv, latitude, levels, psi, p                                  ; Compute stream function

lvl_700_400 = WHERE(p GE 4.0E4 AND p LE 7.0E4, cnt_700_400)                     ; Locate pressure levels between 700--400 hPa
lvl_800     = WHERE(p LE 8.0E4, cnt_800)                                        ; Locate pressure levels above 800 hPa (i.e., higher in atmosphere)
IF cnt_700_400 EQ 0 THEN MESSAGE, 'Error find pressures between 700--400hPa'    ; Throw error if no pressures found between 700--400 hPa
IF cnt_800     EQ 0 THEN MESSAGE, 'Error find pressures less than 800hPa'       ; Throw error if no pressures < 800 hPa

nid   = WHERE( latitude GT 0.0, nCNT, COMPLEMENT=sid, NCOMPLEMENT=sCNT)
IF (nCNT EQ 0) THEN $
  MESSAGE, 'No points in northern hemisphere' $
ELSE IF (sCNT EQ 0) THEN $
  MESSAGE, 'No points in southern hemisphere'

psi_800 = psi[*, lvl_800]
min     = MIN(psi_800[sid,*], minID)                                            ; Get indices of minimum stream function for pressures < 800 hPa in the southern hemisphere
max     = MAX(psi_800[nid,*], maxID)                                            ; Get indices of maximum stream function for pressures < 800 hPa in the northern hemisphere
minID   = ARRAY_INDICES( [sCNT, cnt_800], minID, /DIMENSIONS )                    ; Get col/row index of the minimum value
maxID   = ARRAY_INDICES( [nCNT, cnt_800], maxID, /DIMENSIONS )                    ; Get col/row index of the maximum value

; min   = MIN(psi[*,lvl_800], minID, SUBSCRIPT_MAX = maxID)                       ; Get indices of minimum and maximum stream function for pressures < 800 hPa
; minID = ARRAY_INDICES( [N_ELEMENTS(LATITUDE), cnt_800], minID, /DIMENSIONS )    ; Get col/row index of the minimum value
; maxID = ARRAY_INDICES( [N_ELEMENTS(LATITUDE), cnt_800], maxID, /DIMENSIONS )    ; Get col/row index of the maximum value

psi_N_star = latitude[ nid[ maxID[0] ] ]                                        ; This is the critical latitude in the northern hemisphere
psi_S_star = latitude[ sid[ minID[0] ] ]                                        ; This is the critical latitude in the southern hemisphere

p_N_star   = p[ lvl_800[maxID[1]] ]                                             ; This is the critical pressure in the northern hemisphere
p_S_star   = p[ lvl_800[minID[1]] ]                                             ; This is the critical pressure in the southern hemisphere

cross = ZERO_CROSS(latitude, MEAN(psi[*,lvl_700_400], DIMENSION=2, /NaN))       ; Locate zero-crossings in the 700--400 hPa average stream function
IF cross[0] GT cross[-1] THEN cross = REVERSE(cross)                            ; If the zeroth element is larger than the last element, reverse the array

psi_N = WHERE( cross GT psi_N_star, CNT )                                       ; Locate all crossings that are greater than critical latitude in northern hemisphere
psi_N = (CNT GT 0) ? cross[psi_n[ 0]] : !Values.F_NaN                           ; Set N.H. termination to first zero crossing if any exist, else set to NaN

psi_S = WHERE( cross LT psi_S_star, CNT )                                       ; Locate all crossings that are less than critical latitude in southern hemisphere
psi_S = (CNT GT 0) ? cross[psi_S[-1]] : !Values.F_NaN                           ; Set S.H. termination to first zero crossing if any exist, else set to NaN

END
