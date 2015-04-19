# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

Earth_Radius = 6.37e6
degrees = np.pi/180.
import numpy as np

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
    #elev -= elev[0]
    
    dist = Earth_Radius*abs(Lat[1])
    return(dist)
    
def point_distance(pt1,pt2,filepath = '.'):
    '''Takes two points as ints, for example, 111, 127, 15.  Reads the csv file
    at location filepath (default: the current working directory - and pulls the
    Lat Long and elvation information.Plugs them into distance and returns the answer.  
    '''
    f = open(filepath + '/Geo_spatial_data_checkpoints.csv','r')
    lines = f.readlines()[1:]
    pt1_index = pt1-101
    pt2_index = pt2-101

    p1_data = np.asarray(lines[pt1_index].strip().split(',')[1:4],dtype = float)
    p2_data = np.asarray(lines[pt2_index].strip().split(',')[1:4],dtype = float)

    dist = distance(p1_data,p2_data)
    print (dist)
    
point_distance(113,135,'/home/patbyrne/Documents/modeling_social_data')

# <codecell>

?distance

# <codecell>


# <codecell>


