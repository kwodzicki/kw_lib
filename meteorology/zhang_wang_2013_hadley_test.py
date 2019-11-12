#!/usr/bin/env python3

import os
from datetime import datetime
from netCDF4 import Dataset
import numpy as np
import matplotlib.pyplot as plt

from hadley_cell_bounds import mass_stream_func

sDate = datetime(1979, 1, 1)
eDate = datetime(2011, 1, 1)
dir   = '/Volumes/flood3/ERA_Interim/Analysis/Pressure_Levels/'

u = None
v = None
n = 0
for f in os.listdir(dir):
	if f.endswith('.nc'):
		date = datetime.strptime( f.split('_')[2], '%Y%m' )
		if (date >= sDate) and (date < eDate):
			print('Processing: {}'.format(f))
			data = Dataset( os.path.join(dir, f) )
			if (u is None) and (v is None):	
				lat = data.variables['latitude'][:]
				lon = data.variables['longitude'][:]
				lvl = data.variables['level'][:]
				u   = np.sum( data.variables['u'][:], axis=0 )
				v   = np.sum( data.variables['v'][:], axis=0 )	
			else:
				u += np.sum( data.variables['u'][:], axis=0 )
				v += np.sum( data.variables['v'][:], axis=0 )	
			n += data.variables['time'].size
			data.close()

u /= n
v /= n

lid = np.where( (lon >= 290) & (lon <= 340) )[0]
u = u[:,:,lid]
v = v[:,:,lid]

psi, p, lat = mass_stream_func(u, v, lat, lvl*100.0, Global = False)

cf = plt.contourf(lat, p/100.0, psi/1.0e9,                                
cmap='RdYlBu_r', levels=np.arange(-20,21,4), extend='both')         
plt.ylim(1.0e3, 1)                                                        
plt.xlim(90, -90)                                                         
cb = plt.colorbar( cf )                                                   
cb.set_label('Zonal-mean mass meridional stream function (x10$^9$)')      
plt.show(block = False)                                                   
x = input('Hit <Enter> to continue')                                      
plt.close()                                
