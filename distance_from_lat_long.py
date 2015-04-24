# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

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
    
    dist = Earth_Radius*abs(delta_lat) + 0.5*d_el_d_lat*delta_lat**2
    return(dist)

def point_data(pt,filepath):
    f = open(filepath + '/Geo_spatial_data_checkpoints.csv','r')
    lines = f.readlines()[1:]
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
    dist = distance(p1_data,p2_data)

    return(dist)
        

# <codecell>


