# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# #This is my notebook
# 
# In this notebook I solve an equation like $\int{0}{R_{earth}}$

# <codecell>

import numpy as np
Earth_Radius = 6.37e6
degrees = np.pi/180.

def distance(pt1,pt2):
    '''Trick is to assume that the point of intest is the 'North Pole'.  We're modeling 
    the Earth as a round ball, so starting from zero is fine.  Distance takes no regard for 
    Longitude when you start from the north pole...
    Requires two three-element vectors or lists.  Each with the Lat, Long and elevation'''
    
    Lat = np.array([pt1[0],pt2[0]])*degrees
    Long = np.array([pt1[1],pt2[1]])*degrees
    elev = np.array([pt1[2],pt2[2]])
    
    Lat -= Lat[0]
    #Long -= Long[0]
    elev -= elev[0]

    delta_el = elev[1]
    delta_lat = Lat[1]
    d_el_d_lat = delta_el/delta_lat
    
    dist = Earth_Radius*delta_lat
    correction = 0.5*d_el_d_lat*delta_lat**2
    return(dist,correction)

def point_data(pt,filepath):
    f = open(filepath + '/Geo_spatial_data_checkpoints.csv','r')
    lines = f.readlines()[1:]
    f.close()
    pt_index = pt-101
    

    pt_data = np.asarray(lines[pt_index].strip().split(',')[1:4],dtype = float)
 
    return(pt_data)

def point_distance(pt1,pt2,filepath = '.'):
    '''Takes two points as ints, for example, 111, 127, 15.  Reads the csv file
    at location filepath (default: the current working directory - and pulls the
    Lat Long and elvation information.Plugs them into distance and returns the answer.  
    '''
    p1_data = point_data(pt1,filepath)
    p2_data = point_data(pt2,filepath)
    (dist,correction) = distance(p1_data,p2_data)

    return(abs(dist)+correction)
        
def polar_to_cartesian(filepath = '.'):
        '''Takes the Latitudes and Longitudes and converts them into X,Y coordinates.
        Y coords calculated as R_earth*(delta_Lat)
        X coords calculated as R_earth*(delta_Long)*cosine(Latitude)
        (0,0) defined as the start/finish'''
        f = open(filepath + '/Geo_spatial_data_checkpoints.csv','r')
        lines = f.readlines()[1:]
        f.close()
        sf = lines[-1].strip().split(',')
        sf_Lat = float(sf[1])
        sf_Long = float(sf[2])
        Pt = ['100']
        X = ['0']
        Y = ['0']
        for line in lines[:-1]:
            pc = line.strip().split(',')
            Lat = float(pc[1])
            dLat = Lat-sf_Lat
            dLong = float(pc[2])-sf_Long
            Pt.append(pc[0])
            X.append(str(Earth_Radius*dLat*degrees))
            Y.append(str(Earth_Radius*dLong*degrees*np.cos(Lat*degrees)))
        f = open(filepath + '/Geo_spatial_data_checkpoints_meters.csv','w')
        f.write(','.join(['Point','X','Y']))
        for i in range(len(Pt)):
            f.write(','.join([Pt[i],X[i],Y[i]]))
        f.close()
        Pt = np.asarray(Pt,dtype = int)
        X = np.asarray(X, dtype = float)
        Y = np.asarray(Y,dtype = float)
        return(Pt,X,Y)

# <codecell>

(Pt,X,Y) = polar_to_cartesian()

import matplotlib.pyplot as plt
%matplotlib inline
point = range(101,150)
fig = plt.figure(figsize = (10,15))
ax = fig.add_subplot(111,aspect = 'equal')
for pt in point:
    pd = point_data(pt,'.')
    plt.plot(pd[1],pd[0],'bo')
    
fig = plt.figure(figsize = (10,15))
ax = fig.add_subplot(111,aspect = 'equal')
plt.plot(X,Y,'bo')

# <codecell>


