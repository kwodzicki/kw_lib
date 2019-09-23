PRO KW_FINITE_DIFF_TEST, data

IF N_TAGS(data) EQ 0 THEN BEGIN
	file=!ERA_Data+'6H_SRFC-100hPa_1.5/Interim_SRFC-100hPa_200408.nc'
	vars = ['u', 'v', 'level', 'time', 'longitude', 'latitude'] 
	data = READ_netCDF(file, PARAMETERS=vars)
ENDIF

lvl_id = WHERE(data.LEVEL GE 850)
ref_t  = JULDAY(8, 13, 2004, 12, 0, 0)
time   = TIME_NCDF_ERA(data.TIME, /JULIAN)
; tid    = WHERE(time GE ref_t - 3 AND time LE ref_t + 3)
tid = INDGEN(N_ELEMENTS(data.TIME))

lon = data.Longitude
lat = data.Latitude
uu   = SMOOTH(data.U[*,*,lvl_id,tid], 5, /NaN)
vv   = SMOOTH(data.V[*,*,lvl_id,tid], 5, /NaN)

scale = 1.0E5

u    = MEAN(MEAN(uu, DIMENSION=3, /NAN), DIMENSION=3, /NAN)
v    = MEAN(MEAN(vv, DIMENSION=3, /NAN), DIMENSION=3, /NAN)
div  = KW_DIV_V2(u, v, lon, lat)

memDiff = []
mem0 = MEMORY(/CURRENT)
du   = KW_FINITE_DIFF(u, lon, lat, /LAT_LON, /GLOBAL, /DOUBLE)
memDiff = [memDiff, MEMORY(/HIGHWATER)-mem0]

mem0 = MEMORY(/CURRENT)
dv   = KW_FINITE_DIFF(v, lon, lat, /LAT_LON, /GLOBAL, /DOUBLE)
memDiff = [memDiff, MEMORY(/HIGHWATER)-mem0]

div1 = du.DDX+dv.DDY


contours = FINDGEN(21)-10

xSize = 1000
ySize = 800
WINDOW, 0, xSize = xSize, ySize = ySize
pos = cgLayout([1,2], OYMARGIN=[4,2], OXMARGIN=[2,2], YGAP=4)
kw_contour, div*scale, lon, lat, /MAP_ON, /FILL, /COLORBAR, $
  CONTOURS=contours/10, POSITION=pos[*,0]
kw_contour, div1*scale, lon, lat, /MAP_ON, /FILL, /COLORBAR, $
  CONTOURS=contours/10, POSITION=pos[*,1], /NoErase, /Advance


lap  = KW_DIV_V2(div,lon,lat,DERIVATIVE=2)

mem0 = MEMORY(/CURRENT)
lap1 = KW_FINITE_DIFF(div1, lon, lat, /LAT_LON, /GLOBAL, /DOUBLE, DERIVATIVE=2, ORDER=6)
memDiff = [memDiff, MEMORY(/HIGHWATER)-mem0]

lap1 = lap1.DDx + lap1.DDY

WINDOW, 2, xSize = xSize, ySize = ySize
pos = cgLayout([1,2], OYMARGIN=[4,2], OXMARGIN=[2,2], YGAP=4)
kw_contour, lap  * 1.0E17, lon, lat, /MAP_ON, /FILL, /COLORBAR, $
  CONTOURS=contours, MAPLIMIT=[-40, 90, 40, 270], $
  POSITION=pos[*,0]
  
kw_contour, lap1 * 1.0E14, lon, lat, /MAP_ON, /FILL, /COLORBAR, $
  CONTOURS=contours, MAPLIMIT=[-40, 90, 40, 270], $
  POSITION=pos[*,1], /NoErase, /Advance

mem0 = MEMORY(/CURRENT)
lap_u = KW_FINITE_DIFF(u, lon, lat, /LAT_LON, /GLOBAL, /DOUBLE, DERIVATIVE=3)
memDiff = [memDiff, MEMORY(/HIGHWATER)-mem0]

mem0 = MEMORY(/CURRENT)
lap_v = KW_FINITE_DIFF(v, lon, lat, /LAT_LON, /GLOBAL, /DOUBLE, DERIVATIVE=3)
memDiff = [memDiff, MEMORY(/HIGHWATER)-mem0]

lap1  = lap_u.DDX + lap_v.DDY

PRINT, memDiff/1.0E6
PRINT, MEAN(memDiff)/1.0E6

WINDOW, 3, xSize = xSize, ySize = ySize/2
kw_contour, lap1 * 1.0E11, lon, lat, /MAP_ON, /FILL, /COLORBAR, $
  CONTOURS=contours, MAPLIMIT=[-40, 90, 40, 270]

END