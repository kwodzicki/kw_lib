#!/usr/bin/env python3

try:
  from windspharm.standard import VectorWind
  from windspharm.tools import prep_data, recover_data, order_latdim
except:
  VectorWind = None

import numpy as np

R_e = 6.371009e+06																															# Radius of earth in meters
g   = 9.80665e00																																# Gravity

def zero_cross( x, y ):
	cross = []
	for i in range( x.size-1 ):
		if (y[i] == 0):
			cross.append( x[i] )
		elif ( (y[i] > 0) and (y[i+1] < 0) ) or ( (y[i] < 0) and (y[i+1] > 0) ):
			cross.append( x[i] - y[i] * (x[i+1]-x[i]) / (y[i+1] - y[i]) ) 
	return cross

def mass_stream_func(uu, vv, lat, lvl, Global = True):
	'''
	Name:
		MASS_STREAM_FUNC
	Purpose:
		An IDL procedure to compute the zonal-mean meridional stream
		function
	Inputs:
		uu  : 3-D array of zonal winds [nlvl, nlat, nlon]
		vv  : 3-D array of meridional winds [nlvl, nlat, nlon]
		lat : A 1- or 2-D array of latitude values (degrees) [nlat]
		lvl : A 1- or 2-D array of pressure levels (Pa) [nlvl]
	Outputs:
		psi    : The meridional mass stream function (kg s**-1)
		p      : Pressures for the stream function (Pa)
		lat    : Latitude as may have been reversed
	Keywords:
		Global   : Sets if computing for global or for a
							 zonal subset using method of Zhang and Wang (2013)
	Author and history:
		Kyle R. Wodzicki
	'''

	if (not Global) and (not VectorWind):
		raise Exception('Failed to import windspharm.standard.VectorWind!!!')
	elif (not Global):
		print('Trying to use irrotational wind')
		uu, uu_info = prep_data(uu, 'pyx')																						# Prepare data for VectorWind class
		vv, vv_info = prep_data(vv, 'pyx')																						# Prepare data for VectorWind class
		lat, uu, vv = order_latdim(lat, uu, vv)																				# Fix latitude order
		VW = VectorWind(uu, vv)																												# Initialize vector wind class
		uchi, vchi = VW.irrotationalcomponent()																				# Get irrotational components
		vv = recover_data(vchi, vv_info)																							# Convert v-irrot component back to input order
 
	vv   = np.nanmean( vv, axis = 2 )																								# Average over longitude (last dimension)
	dims = vv.shape                                                    							# Get dimensions of VV
	if (lat.ndim == 1):												                                      # If the latitude is only 1-D
		if (dims[0] == lat.size):
			vv   = vv.transpose()
			dims = vv.shape
		lat = np.repeat( lat.reshape( 1, dims[1] ), dims[0], axis=0 )									# Reshape to match vv array
 
	lat = lat[:-1,:]

	if (lvl.ndim == 1):												                                      # If the level is only 1-D
		lvl = np.repeat( lvl.reshape( dims[0], 1 ), dims[1], axis=1 )									# Reshape to match vv array

	revFlat = False
	if (lvl[0,0] > lvl[-1,0]):																											# If pressure levels are decending
		revFlat = True
		lvl     = lvl[::-1,:]																													# Reverse to ascending
		vv      = vv[::-1,:]																													# Reverse vv too

	dp = lvl[1:, :] - lvl[:-1, :]                                               		# Compute change in pressure between levels
	dv = (vv[1:, :] + vv[ :-1, :]) / 2.0                                        		# Compute mean wind for level

	p    = ( (lvl[1:,0] + lvl[:-1, 0]) / 2.0 ).flatten()														# Reform mean pressure for level for output
	psi  = 2.0 * np.pi * R_e * np.cos( np.radians(lat) ) / g                        # Compute scalar for psi equation
	psi *= np.cumsum( dv * dp, axis=0 )                                    					# Multiply scalar by the integeral of vv * dp

	return psi, p, lat[0,:].flatten()																								# Return stream function and pressure

def hadley_cell_bounds(uu, vv, latitude, levels, Global = True):
	'''
	Name:
	  HADLEY_CELL_BOUNDS
	Purpose:
	  An IDL procedure to determine the boundaries of the Hadley circulation
	  using the methodology of Stachnik and Schumacher (2011).
	Inputs;
		uu       : 3-D array of zonal winds [nlvl, nlat, nlon]
		vv       : 3-D array of meridional winds [nlvl, nlat, nlon]
	  latitude : 1-D array of latitude values; must match size
	              of second dimension of vv
	  levels   : 1-D array of pressure values; must match size
	              of third dimension of vv; Pascals
	Outputs:
	  psi_N  : Latitude of the northern boundary of the Hadley cell
	             Will be NaN if no boundary found!
	  psi_S  : Latitude of the southern boundary of the Hadley cell
	             Will be NaN if no boundary found!
	Keywords:
	  PSI      : Set to named variable to return stream function to
	  PRESSURE : Set to named variable to return pressure levesl for psi to
	Dependencies:
	  MASS_STREAM_FUNC
	  ZERO_CROSS
	Author and History:
	  Kyle R. Wodzicki     Created 18 Mar. 2019
	'''	

	psi, p, latitude = mass_stream_func(uu, vv, latitude, levels, Global = Global)

	lvl_700_400 = np.where( (p >= 4.0E4) & (p <= 7.0E4) )[0]												# Locate pressure levels between 700--400 hPa
	lvl_800     = np.where( p <= 8.0E4 )[0]																					# Locate pressure levels above 800 hPa (i.e., higher in atmosphere)
	if (lvl_700_400.size == 0): 
		raise Exception('Error find pressures between 700--400hPa')										# Throw error if no pressures found between 700--400 hPa
	if (lvl_800.size == 0 ):
		raise Exception('Error find pressures less than 800hPa')											# Throw error if no pressures < 800 hPa

	nid   = np.where( latitude >  0.0 )[0]
	sid   = np.where( latitude <= 0.0 )[0]
	if (nid.size == 0):
		raise Exception('No points in northern hemisphere')
	elif (sid.size == 0):
		raise Exception('No points in southern hemisphere')

	psi_800 = psi[lvl_800, :]
	minID   = psi_800[:,sid].argmin()                                           		# Get indices of minimum stream function for pressures < 800 hPa in the southern hemisphere
	maxID   = psi_800[:,nid].argmax()                                            		# Get indices of maximum stream function for pressures < 800 hPa in the northern hemisphere
	minID   = np.unravel_index( minID, (lvl_800.size, sid.size,) )									# Get col/row index of the minimum value
	maxID   = np.unravel_index( maxID, (lvl_800.size, nid.size,) )									# Get col/row index of the maximum value

	psi_N_star = latitude[ nid[ maxID[1] ] ]                                        # This is the critical latitude in the northern hemisphere
	psi_S_star = latitude[ sid[ minID[1] ] ]                                        # This is the critical latitude in the southern hemisphere

	p_N_star   = p[ lvl_800[maxID[0]] ]                                             # This is the critical pressure in the northern hemisphere
	p_S_star   = p[ lvl_800[minID[0]] ]                                             # This is the critical pressure in the southern hemisphere

	cross = zero_cross(latitude, np.nanmean(psi[lvl_700_400,:], axis=0) )						# Locate zero-crossings in the 700--400 hPa average stream function
	if (cross[0] > cross[-1]): cross = cross[::-1]																	# If the zeroth element is larger than the last element, reverse the array

	psi_N = np.where( cross > psi_N_star )[0]                                       # Locate all crossings that are greater than critical latitude in northern hemisphere
	psi_N = cross[psi_N[0]] if (psi_N.size > 0) else np.nan                         # Set N.H. termination to first zero crossing if any exist, else set to NaN

	psi_S = np.where( cross < psi_S_star )[0]                                       # Locate all crossings that are less than critical latitude in southern hemisphere
	psi_S = cross[psi_S[-1]] if (psi_S.size >0) else np.nan                         # Set S.H. termination to first zero crossing if any exist, else set to NaN

	return psi_N, psi_S, psi, p

if __name__ == "__main__":
	import argparse
	from netCDF4 import Dataset
	parser = argparse.ArgumentParser()
	parser.add_argument('file', type=str, help='netCDF file to read data from')
	parser.add_argument('-u', '--uVarName',   type=str, metavar="'u-wind var name'",    default = 'u',         help='Name of variable for u-component')
	parser.add_argument('-v', '--vVarName',   type=str, metavar="'v-wind var name'",    default = 'v',         help='Name of variable for v-component')
	parser.add_argument('-l', '--latVarName', type=str, metavar="'latitude var name'",  default = 'latitude',  help='Name of variable for latitudes')
	parser.add_argument('-L', '--lonVarName', type=str, metavar="'longitude var name'", default = 'longitude', help='Name of variable for longitudes')
	parser.add_argument('-p', '--lvlVarName', type=str, metavar="'pressure var name'",  default = 'level',     help='Name of variable for pressures')
	parser.add_argument('-t', '--timeDim',    type=int, help='Time dimension index for time mean')
	parser.add_argument('-d', '--domain',     type=int, nargs=2, help='Time dimension index for time mean')
	parser.add_argument('-P', '--plot',       action='store_true', help='Time dimension index for time mean')
	args = parser.parse_args()
	
	data = Dataset(args.file)
	uu   = data.variables[args.uVarName][:] 
	vv   = data.variables[args.vVarName][:] 
	lat  = data.variables[args.latVarName][:]
	lon  = data.variables[args.lonVarName][:]
	lvl  = data.variables[args.lvlVarName][:] * 100.0

	data.close()

	if (args.timeDim is not None):
		uu = np.nanmean( uu, axis = args.timeDim )
		vv = np.nanmean( vv, axis = args.timeDim )

	if (uu.ndim > 3):
		print( 'Too many dimensions. Is one of them time? Use the --timeDim flag')
	else:
		if args.domain:
			if (args.domain[0] < args.domain[1]):
				lonID = np.where( (lon >= args.domain[0]) & (lon <= args.domain[1]) )[0]
			else:
				lonID = np.where( (lon >= args.domain[0]) | (lon <= args.domain[1]) )[0]

			if (lonID.size > 0):
				uu = uu[:,:,lonID]
				vv = vv[:,:,lonID]

		psi_n, psi_s, psi, p = hadley_cell_bounds(uu, vv, lat, lvl, Global=(args.domain is None) ) 
	
		print( "North: {:6.2f}, South: {:6.2f}".format( psi_n, psi_s ) )
		
		if args.plot:
			import matplotlib.pyplot as plt
			cf = plt.contourf(lat, p/100.0, psi/1.0e9, 
						cmap='RdYlBu_r', levels=np.arange(-20,21,4), extend='both')
			plt.ylim(1.0e3, 1)
			plt.xlim(90, -90)
			cb = plt.colorbar( cf )
			cb.set_label('Zonal-mean mass meridional stream function (x10$^9$)')
			plt.show(block = False)
			x = input('Hit <Enter> to continue')
			plt.close()


