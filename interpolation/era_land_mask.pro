FUNCTION ERA_LAND_MASK, GoM=gom

;+
; Name:
;   ERA_LAND_MASK
; Purpose:
;   A function to return a land mask array at the same grid spacing
;   of ERA-Interim data.
; Inputs:
;   None.
; Outputs:
;   An array is returned that contains zero (0) for water or 
;   one (1) for land.
; Keywords:
;   GOM  : Set this keyword to remove the Gulf of Mexico.
; Author and History:
;   Kyle R. Wodzicki     Created 17 Oct. 2014
;-

COMPILE_OPT IDL2

data=LAND_OCEAN_READ_KPB('land_ocean_masks','land_ocean_mask2','1d')  ;Get the land mask data

grid = GRID_POINTS([-90.0, 0.0, 90.0, 360.0], 1.5)                    ;Get boundaries to re-grid mask data

mask = INTARR(N_ELEMENTS(grid.LON_CENTER), $
              N_ELEMENTS(grid.LAT_CENTER))
dims = SIZE(mask, /DIMENSIONS)

FOR i = 0, N_ELEMENTS(grid.LON_BOUNDS)-2 DO BEGIN                     ;Iterate over longitude
  id = WHERE(grid.LON_BOUNDS[i]   LE data.X.VALUES AND $              ;Find data points
             grid.LON_BOUNDS[i+1] GE data.X.VALUES, CNT)
  IF (CNT NE 0) THEN tmp = data.VALUES[id,*] ELSE CONTINUE            ;Continue if no points
  FOR j = 0, N_ELEMENTS(grid.LAT_BOUNDS)-2 DO BEGIN                   ;Iterate over latitude
    id = WHERE(grid.LAT_BOUNDS[j]   GE data.Y.VALUES AND $
               grid.LAT_BOUNDS[j+1] LE data.Y.VALUES, CNT)
    IF (CNT NE 0) THEN BEGIN
      IF (MEAN(tmp[*,id],/NaN) NE 0) THEN mask[i,j] = 1               ;If any points over land, whole box over land
    ENDIF
  ENDFOR                                                              ;END j
ENDFOR                                                                ;END i

IF KEYWORD_SET(gom) THEN BEGIN
 mask_lon = REBIN(grid.LON_CENTER, dims)
 mask_lat = REBIN(TRANSPOSE(grid.LAT_CENTER), dims)
 index	= WHERE((mask_lon GE 260 AND mask_lon LE 270  AND $
                 mask_lat GE  18 AND mask_lat LE  30) OR  $						;Find Gulf of Mexico Values
								(mask_lon GE 267 AND mask_lon LE 290  AND $
								 mask_lat GE  15 AND mask_lat LE  30) OR  $
								(mask_lon GE 276 AND mask_lon LE 290  AND $
								 mask_lat GE   9 AND mask_lat LE  30) OR  $
								(mask_lon GE 282 AND mask_lon LE 290  AND $
								 mask_lat GE   8 AND mask_lat LE  30), COUNT)
	IF (COUNT NE 0) THEN mask[index]=1
ENDIF

RETURN, {MASK     : mask, $
         X_VALUES : grid.LON_CENTER, $
         Y_VALUES : grid.LAT_CENTER}

END