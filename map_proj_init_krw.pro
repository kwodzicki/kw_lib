FUNCTION MAP_PROJ_INIT_KRW, projection, $
	MAP_OBJ    = map_obj, $
	_REF_EXTRA = _ref_extra

COMPILE_OPT IDL2

IF N_ELEMENTS(map_obj) NE 0 THEN BEGIN
	RETURN, MAP_PROJ_INIT( map_obj.MAP_PROJECTION, $
		ELLIPSOID          = map_obj.ELLIPSOID, $
		LIMIT              = map_obj.LIMIT, $
		CENTER_LATITUDE    = map_obj.CENTER_LATITUDE, $
		CENTER_LONGITUDE   = map_obj.CENTER_LONGITUDE, $
		FALSE_EASTING      = map_obj.FALSE_EASTING, $
		FALSE_NORTHING     = map_obj.FALSE_NORTHING, $ 
		HEIGHT             = map_obj.HEIGHT, $
		HOM_AZIM_LONGITUDE = map_obj.HOM_AZIM_LONGITUDE, $
		HOM_AZIM_ANGLE     = 
		HOM_LATITUDE1      = 
		HOM_LATITUDE2      =
		HOM_LONGITUDE1     =
		HOM_LONGITUDE2     =
		IS_ZONES           =
		IS_JUSTIFY         =
		MERCATOR_SCALE     =
		OEA_ANGLE			=value] [, OEA_SHAPEM=value] [, OEA_SHAPEN=value] [, ROTATION=value] [, SEMIMAJOR_AXIS=value] [, SEMIMINOR_AXIS=value] [, SOM_INCLINATION=value] [, SOM_LONGITUDE=value] [, SOM_PERIOD=value] [, SOM_RATIO=value] [, SOM_FLAG=value] [, SOM_LANDSAT_NUMBER=value] [, SOM_LANDSAT_PATH=value] [, SPHERE_RADIUS=value] [, STANDARD_PARALLEL=value] [, STANDARD_PAR1=value] [, STANDARD_PAR2=value] [, SAT_TILT=value] [, TRUE_SCALE_LATITUDE=value] [, ZONE=value]
			CENTER_AZIMUTH=value]
 RETURN, 'Yes'
ENDIF ELSE $
	RETURN, MAP_PROJ_INIT( projection, _EXTRA = _ref_extra)

END
