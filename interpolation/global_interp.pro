FUNCTION GLOBAL_INTERP, dataIn, origLon, origLat, $
  DLON   = dLon, $
  DLAT   = dLat, $
  NEWLON = newlon, $
  NEWLAT = newlat

;+
; Name:
;   GLOBAL_INTERP
; Purpose:
;   Function to do global bi-linear interpolation that handles edges
;   of longitude bounds by wrapping data around
; Arguments:
;   dataIn  : 2D or greater array to interpolate; [lon, lat, n, m, etc.]
;   origLon : Longitude values associated with data
;   origLat : Latitude values associated with data
; Keyword arguments:
;   DLON    : Longitude spacing for interpolated data.
;               Default is to not interpolate over dimesion
;   DLAT    : Latitude spacing for interpolaoted data.
;               Default is to not interpolate over dimesion
;   NEWLON  : Set to named variable to return new longitude values to
;   NEWLAT  : Set to named variable to return new latitude values to
; Returns:
;   Interpolated data
;-

COMPILE_OPT IDL2

IF N_ELEMENTS(dLon) EQ 0 THEN $							; If dLon not set
  newLon = origLon $								; Set new lon to input longitude
ELSE $										; Else
  newLon = INDGEN( 360.0 / dLon ) * dLon + MIN(origLon)				; Build new longitudes

IF N_ELEMENTS(dLat) EQ 0 THEN $							; If dLat no set
  newLat = origLat $								; Set new lat to input latitude
ELSE BEGIN									; Else
  newLat = INDGEN( (180.0 / dLat) + 1 ) * dLat					; Build new latitudes
  IF origLat[0] GT origLat[1] THEN $						; If latitude values are decreasing
    newLat = 90.0 - newLat $							; Adjust latitudes
  ELSE $									; Else, values increasing
    newLat = newLat - 90.0							; Adjust latitudes
ENDELSE

IF N_ELEMENTS(dataIn) EQ 0 THEN RETURN, -1					; If dataIn not defined, just return -1

dd              = origLon[1] - origLon[0]					; Determine longitude grid spacing of input data
_origLonPad     = MAKE_ARRAY(origLon.LENGTH+2, TYPE=origLon.TYPECODE)		; Create new padded data space
_origLonPad[ 0] = origLon[ 0] - dd						; Set first element to one grid spacing less than left bound
_origLonPad[ 1] = origLon							; Write original longitudes into the array staring at second value
_origLonPad[-1] = origLon[-1] + dd						; St last value to one grid spacing greater than right bound

xint = INTERPOL(FINDGEN(_origLonPad.LENGTH), _origLonPad, newLon)		; Determine index into original longitude that have to be interpolated to
yint = INTERPOL(FINDGEN(origLat.LENGTH), origLat, newLat)			; Determine index into original latitude that have to be interpolated to

origDims = dataIn.DIM								; Get dimensions of input data
IF N_ELEMENTS(origDims) GT 3 THEN BEGIN						; If more than three (3) dimensions
  newDims = [origDims[0], origDims[1], PRODUCT(origDims[2:*], /INTEGER)]	; Set reshaping to 3D
  data    = REFORM(dataIn, newDims)						; Reshape data
ENDIF ELSE $									; Else
  data    = dataIn								; Use input data

dims     = data.DIM								; Get new dimensions
dims[0] += 2									; Make first dimesion 2 wider
interp   = MAKE_ARRAY( dims, TYPE=data.TYPECODE )				; Create new padded array
interp[ 0,0,0] = data[-1,*,*]							; Set first slice in x to last slice in x; wrap data
interp[ 1,0,0] = data								; Fill in middle of array
interp[-1,0,0] = data[ 0,*,*]							; Set last slice in x to first slice in x; wrap data

interp = INTERPOLATE(interp, xint, yint, INDGEN(dims[-1]), /GRID)		; Interpolate data

IF N_ELEMENTS(origDims) GT 3 THEN BEGIN						; If was greater than 3D
  dims = interp.DIM
  RETURN, REFORM(interp, [dims[0], dims[1], origDims[2:*]])			; Expand to 'old' shape and return
ENDIF

RETURN, interp									; Return interpolated data

END
