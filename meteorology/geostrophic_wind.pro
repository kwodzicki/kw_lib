FUNCTION GEOSTROPHIC_WIND, geo, x, y, z
;+
; Name:
;   GEOSTROPHIC_WIND
; Purpose:
;   A function to calcuate the geostrophic wind based on constant
;   pressure surfaces given the geopotential, longitude, and
;   latitude values.
; Inputs:
;   geo : Geopotential in m^2 s^-2
;   x   : Longitude values in degrees.
;          NOTE: Assumes values are negative to positive.
;   y   : Latitude values in degress. 
;          NOTE: Assumes values are postive to negative.
;   z   : Pressure levels of data.
; Outputs:
;   Returns structure containing the u and v components of the wind
;   in same dimensions as z.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 23 Oct. 2014
;-
  COMPILE_OPT IDL2                                                    ;Set compile options

  IF (N_PARAMS() NE 4) THEN MESSAGE, 'Incorrect number of inputs!'

  dims = [N_ELEMENTS(x), N_ELEMENTS(y)]
  x_2D = REBIN(x, dims)                                               ;2-D array of x valuse
  y_2D = REBIN(TRANSPOSE(y), dims)                                    ;2-D array of y values
  f    = 4.0 * !DPI * SIN(y_2D*!DPI/180.0D00) / 86164.1D00            ;Calculate the Coriolis parameter

  x0 = SHIFT(x_2D, -1, 0) & x1 = SHIFT(x_2D, 1,  0)                   ;Shift x values west and east
  y0 = SHIFT(y_2D,  0, 1) & y1 = SHIFT(y_2D, 0, -1)                   ;Shift y values south and north

  dx = KWMAP_2POINTS(x0,   y_2D,   x1, y_2D, /METERS)                 ;Change in x in meters
  dy = KWMAP_2POINTS(x_2D,   y0, x_2D,   y1, /METERS)                 ;Change in y in meters

  dims = SIZE(geo, /DIMENSIONS)                                       ;Get size of geopotential
  CASE N_ELEMENTS(dims) OF                                            ;Define arrays for shifting values
    2    : BEGIN
            x0 = [-1, 0]       & x1 = [1,  0]
            y0 = [ 0, 1]       & y1 = [0, -1]
           END
    3    : BEGIN
            x0 = [-1, 0, 0]    & x1 = [1,  0, 0]
            y0 = [ 0, 1, 0]    & y1 = [0, -1, 0]
           END
    4    : BEGIN
            x0 = [-1, 0, 0, 0] & x1 = [1,  0, 0, 0]
            y0 = [ 0, 1, 0, 0] & y1 = [0, -1, 0, 0]
           END
    ELSE : MESSAGE, 'Geopotential must be between 2-4 dimensions!'
  ENDCASE

  dx = REBIN(dx, dims) & dy = REBIN(dy, dims) & f = REBIN(f, dims)    ;Rebin to correct dimension
  
;=== Calculate the geostrophic wind ===
  u_g = -1 * ( SHIFT(geo, y0)-SHIFT(geo, y1) ) / dy / f               ;Compute u component
  v_g =      ( SHIFT(geo, x0)-SHIFT(geo, x1) ) / dx / f               ;Compute v component
  
  RETURN, {U_g : u_g, V_g: v_g}
END