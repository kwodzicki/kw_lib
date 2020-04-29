try:
  from windspharm.standard import VectorWind
  from windspharm.tools import prep_data, recover_data, order_latdim
except:
  VectorWind = None

import numpy as np

R_e = 6.371009e+06																															# Radius of earth in meters
g   = 9.80665e00																																# Gravity

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
	Keywords:
		Global   : Sets if computing for global or for a
							 zonal subset using method of Zhang and Wang (2013)
	Author and history:
		Kyle R. Wodzicki
	'''

	if (not Global) and (not VectorWind):
		raise Exception('Failed to import windspharm.standard.VectorWind!!!')
	elif (not Global):
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

	return psi, p																																		# Return stream function and pressure

