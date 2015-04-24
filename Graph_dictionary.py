# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import re
from collections import OrderedDict
import distance_from_lat_long
from copy import deepcopy
import matplotlib.pyplot as plt
#%matplotlib inline

def split_to_time(splt):
    [hr,mn,sc] = splt.split(':')
    time = int(hr)*60**2 + int(mn)*60 + int(sc)
    return(time)
    
class Node(object):
    def __init__(self,num,prv = None, nxt = None,splt = None,pts = None):
        self.num = num
        self.time = split_to_time(splt)
        self.points = pts
        if (prv != None):
            self.prv = prv
            self.prv_edge = distance_from_lat_long.point_distance(self.num,self.prv)
        else: [self.prv,self.prv_edge] = [None,None]
            
        if (nxt != None):
            self.nxt = nxt
            self.nxt_edge = distance_from_lat_long.point_distance(self.num,self.nxt)
        else: [self.nxt,self.nxt_edge] = [None,None]
            
    def set_nxt(self,nxt):
        self.nxt = nxt
        self.nxt_edge = distance_from_lat_long.point_distance(self.num,self.nxt)
def team_grapher():
    f = open('Race_data_team_splits_checkpoints.csv','r')
    lines = f.readlines()[1:]
    f.close()

    team_graph = OrderedDict()
    ST_Node = Node(num =100,splt = '0:0:0')

    for l in range(len(lines)):
        line = re.sub('\"','',lines[l])
        team = line.strip().split()[0]
        splt = line.strip().split(',')[-1]    
        point = re.sub('\)','',re.sub('\(','',line.strip().split(',')[1]))

        if '*' in splt:
            continue
        
        if point == 'F':
            point = 100
   
        elif point == 'NA':
            continue
        
        else: 
            point = int(point)
    
        pts = 10+((point-101)//10)*10
        
        if (team not in team_graph.keys()):
            team_graph[team] = []
            ST_Node.set_nxt(point)
            team_graph[team].append(deepcopy(ST_Node))
            prv_Node = ST_Node

        else:
            prv_Node = team_graph[team][-1]
            prv_Node.set_nxt(point)
    
        team_graph[team].append(Node(point, prv = prv_Node.num,splt = splt,pts = pts))
    return(team_graph)

# <codecell>

#print(team_graph.keys())

# <codecell>

#sec_pt = 0
#for n,node in enumerate(team_graph['454']):
#    print node.num, node.prv_edge,node.nxt_edge,node.time,node.points
#    if node.num != 100:
#        plt.plot(n,(float(node.time)/float(node.points))**-1,'o')
#        sec_pt += node.time/float(node.points)
#print sec_pt

# <codecell>

#print '#  ','<-time','->time','pts'
#sec_pt = 0
#for n,node in enumerate(team_graph['439']):
#    print node.num,node.prv_edge,node.nxt_edge,node.time
#    if node.num != 100:
#        plt.plot(n,node.time/float(node.points),'o')
#        plt.ylim(0,200)
#        sec_pt += node.time/float(node.points)
#print sec_pt

# <codecell>

#for node in team_graph['275']:
#    print node.num,node.prv_edge,node.nxt_edge,node.time

# <codecell>

#for node in team_graph['439']:
#    print node.num,node.prv_edge,node.nxt_edge,node.time

# <codecell>

#for node in team_graph['409']:
#    print node.num,node.prv_edge,node.nxt_edge,node.time

# <codecell>


