library(plyr)
library(lattice)
library(latticeExtra)

# clear memory
rm(list=ls())

# read data
route_data <- read.csv("clean_data/team_routes.csv", )
team_data <- read.csv("clean_data/team_info_score.csv", )

##initial summaries:
#Score:
summary(team_data$Score)
#Penalty:
summary(team_data$Penalty)

##grouping by gender:
# new data frame for women
women <- rbind(team_data[grep("W3", team_data$Class), ] , team_data[grep("W6", team_data$Class), ])
png(file = "figures/women.png",width = 2400, height = 2400, res=600)
histogram(~Score|Time.Limit, data = women, type = "count",
          main="Number of teams of Women\n within a score range")
dev.off()
summary(women$Score)

# new data frame for men
men <- rbind(team_data[grep("M3", team_data$Class), ] , team_data[grep("M6", team_data$Class), ])
png(file = "figures/men.png",width = 3000, height = 3000, res=600)
histogram(~Score|Time.Limit, data = men, type = "count",
          main="Number of teams of Men\n within a score range")
dev.off()
summary(men$Score)

# new data frame for mixed groups
both <- rbind(team_data[grep("B3", team_data$Class), ], team_data[grep("B6", team_data$Class), ])
png(file = "figures/both.png",width = 3000, height = 3000, res=600)
histogram(~Score|Time.Limit, data = both, type = "count",
          main="Number of teams with both gender representation\n within a score range")
dev.off()
summary(both$Score)

## team-wise analysis:
#no of points covered by each team
no_of_points <- data.frame(table(route_data$team.ID))
colnames(no_of_points) <- c("team.ID","Total.Points")

#total time per point
total_time <- data.frame(route_data[route_data$Checkpoint == "F",c("team.ID", "Team.Name" , "Total.Time")])

#merge total time & no of points of one team
teams <- merge(total_time[,c("team.ID", "Team.Name", "Total.Time")], no_of_points, by="team.ID")

#calculate time per point
teams$Total.Time <- strptime(teams$Total.Time , "%H:%M:%S")
#converts time from integer to list to perform arithmetic operations

teams$Time.in.minutes <- teams$Total.Time[[1]]/60 + teams$Total.Time[[2]] + teams$Total.Time[[3]]*60

##plot team vs time taken
png(file = "figures/point_dist.png",width = 3000, height = 3000, res=600)
histogram(teams$Total.Points, labels=teams$team.ID, main = "Distribution of total no. \nof checkpoints covered by team", xlab = "Total points covered", ylab = "No. of teams")
dev.off()

png(file = "figures/time_vs_points.png",width = 3000, height = 3000, res=600)
plot(teams$Time.in.minutes,teams$Total.Points, main="Comparison of points crossed\n for 3-hour & 6-hour teams", 
     xlab = "Total time taken", ylab = "Total checkpoints crossed")
dev.off()

teams$Time.per.point <- teams$Time.in.minutes/teams$Total.Points

route_data$Total.Time <- strptime(route_data$Total.Time , "%H:%M:%S")
route_data$Total.Time.In.Minutes <- route_data$Total.Time[[1]]/60 + route_data$Total.Time[[2]] + route_data$Total.Time[[3]]*60

route_data$Split <- strptime(route_data$Split , "%H:%M:%S")
route_data$Split <- route_data$Split[[1]]/60 + route_data$Split[[2]] + route_data$Split[[3]]*60

###combine total time of a team with points collected
all_data <- merge(team_data,route_data,by="team.ID")[,c("team.ID","Time.Limit","Borrow","Class","Rank","Club","Score","Checkpoint","Split")]

##find correlations:
#between "Borrow" and Score
png(file = "figures/borrow_vs_score.png",width = 3000, height = 3000, res=600)
bwplot(all_data$Score~all_data$Borrow, 
     xlab = "Teams borrowing RSID", ylab = "Score")
dev.off()

#between "Club" and Score
png(file = "figures/club_vs_score.png",width = 3000, height = 3000, res=600)
bwplot(Score~Club, data=all_data,
       xlab = "Teams having club memberships", ylab = "Score")
dev.off()

##point-wise analysis
points <- ddply(all_data, .(Checkpoint), c("nrow"))
points <- points[order(-points$nrow),]
png(file = "figures/point_analysis.png",width = 3000, height = 3000, res=600)
histogram(all_data$Checkpoint[all_data$Checkpoint != "F"], xlab = "Checkpoints")
dev.off()

##top 10 & bottom 10 teams:
all_data <- all_data[order(all_data$Rank),]
top <- data.frame(all_data[all_data$Rank<=10, ])
bottom <- data.frame(all_data[all_data$Rank>=30, ])
png(file = "figures/top_10.png",width = 3000, height = 3000, res=600)
histogram(top$Checkpoint[top$Checkpoint != "F"], xlab = "Checkpoints",
          main = "Points covered by top 10 teams")
dev.off()

png(file = "figures/bottom_10.png",width = 3000, height = 3000, res=600)
histogram(bottom$Checkpoint[bottom$Checkpoint != "F"], xlab = "Checkpoints",
          main = "Points covered by bottom 10 teams")
dev.off()

xyplot(Split~Rank|Checkpoint,data=top[top$Checkpoint != "F", ])  ##no correlation between time taken to a point and rank of the team
bwplot(Score~Class|Time.Limit,data=team_data,xlab="Type of team",main = "Variation in scores for different classes of teams") 
