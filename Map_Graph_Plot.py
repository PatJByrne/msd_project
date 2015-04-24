# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import Graph_dictionary
import distance_from_lat_long
from collections import OrderedDict
team_graph = Graph_dictionary.team_grapher()
edge_count = OrderedDict()
max_edge = 0
for team in team_graph.keys():
    course_map = team_graph[team]
    for node in course_map[:-1]:
        edge = [node.num,node.nxt]
        edge.sort()
        edge_name = '%d-%d' % (edge[0],edge[1])
        if edge_name not in edge_count.keys():
            edge_count[edge_name] = 0
        edge_count[edge_name] += 1
        if edge_count[edge_name] > max_edge:
            max_edge = edge_count[edge_name]

# <codecell>

fig = plt.figure()
ax = fig.add_subplot(111,aspect = 'equal')
(yst,xst,elev) = distance_from_lat_long.point_data(100,'.')

for edge in edge_count.keys():
    (y1,x1,elev) = distance_from_lat_long.point_data(int(edge.split('-')[0]),'.')
    (y2,x2,elev) = distance_from_lat_long.point_data(int(edge.split('-')[1]),'.')

    x1 -= xst
    x2 -= xst
    
    y1 -= yst
    y2 -= yst
    
    plt.plot([x1,x2],[y1,y2],'r',linewidth = 1+edge_count[edge]%4,alpha = edge_count[edge]/float(max_edge))
    plt.plot([x1,x2],[y1,y2],'ob')

# <codecell>

for node in team_graph['454'][:-1]:
    (y1,x1,elev) = distance_from_lat_long.point_data(node.num,'.')
    (y2,x2,elev) = distance_from_lat_long.point_data(node.nxt,'.')

    x1 -= xst
    x2 -= xst
    
    y1 -= yst
    y2 -= yst
    
    plt.plot([x1,x2],[y1,y2],'b',linewidth =1,alpha = .5)

# <codecell>


