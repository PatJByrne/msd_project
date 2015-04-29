'''
	Program - Groups data based on teams and checkpoints
	Input - Race_data_team_splits_checkpoints.csv
	Output - Team_wise_points.txt, Point_wise_time.txt
	Author - Shivangi Saxena
'''

import csv
from collections import defaultdict
with open('Race_data_team_splits_checkpoints.csv', newline = '') as ip, open('Team_wise_points.txt','w') as op_T, open('Point_wise_time.txt','w') as op_P:
	read_ip = csv.reader(ip, delimiter = ',', quotechar='"')
	firstline = True
	temp = {}	##keeps a track of the teams covered, temp dictionary
	splits = []	##main list, keeps record of team, source checkpoint, destination checkpoint, time taken between these points
	for row in read_ip:
		if firstline:
			firstline = False
			continue		##skips the header of the CSV file
		team_name = row[0]
		destination = row[1]
		time = row[3]

		if team_name not in temp:	##if new team, keep source as start-point
			source = "  (F)"
			temp[team_name] = True
		splits.append([team_name,source,destination,time])
		source = destination	##carry-over source to next iteration

	##make dictionary that groups together info from "splits" based on TEAMS
	teams = defaultdict(list)
	for row in splits:
		teams[row[0]].append([row[1],row[2],row[3]])

	for t in teams:
		op_T.write("\n" + str(t) + ":\n")
		for point in teams[t]:
			op_T.write(str(point[0]) + " " + str(point[1]) + " "  + str(point[2]) + "\n")

	##group-by start and end-points
	points = defaultdict(list)
	for row in splits:
		if ((row[1][1:4]).isdigit()):
			k1 = int(row[1][1:4])
		else:
			k1 = 0
		if ((row[2][1:4]).isdigit()):
			k2 = int(row[2][1:4])
		else:
			k2 = 0
		if (k1<k2):
			key = (row[1],row[2])
		else:
			key = (row[2],row[1])
		points[key].append([row[0],row[3]])

	for p in points:
		op_P.write("\n" + str(p[0]) + " - " + str(p[1]) + ":\n")
		for row in points[p]:
			op_P.write(str(row[0]) + " ---> " + str(row[1]) + "\n")