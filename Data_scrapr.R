require(XML)
require(data.table)
require(dplyr)

wrap_rows <- function(sub_tb,sets){
  #This code is designed to read the HTML tables from the website
  #The website is badly formatted.  The rows are the teams, and the columns are the data entries
  #In some cases the data for a team stretched wider than would fit on a computer screen
  #The data was then wrapped to a new row.  This confused things, and we need to make sure which
  #row is part of which team.
  
  #sub_tb is a sub table, that will be sent to the function, and sets is
  if (nrow(sub_tb) == 3) {
    #If the table has three rows, there can be only one team, it's fine, return it
    return(sub_tb)
  }

  #seps finds how many sets of three rows belong to each individual teams in names
  seps = (tail(sets,n=-1)-head(sets,n=-1))/3
  cols = ncol(sub_tb)*max(seps)
  
  #we want to know how to group the rows.  Some are new teams, some are continuations of the same team
  groups = (which(sub_tb$V3[seq(1,nrow(sub_tb),by=3)+1] != '') - 1) * 3 +1#fuck all 1-indexed languages
  groups = append(groups,nrow(sub_tb))

  wrapped_tb = data.table()
  
  for(i in seq(length(groups) -1)){
    wrapping_tb = data.table()
   
    if(seps[i]!=max(seps)){
      wrapping_tb = rbind(wrapping_tb, sub_tb[groups[i]:(groups[i]+2)])
      empty_cols = rep('',ncol(sub_tb)*(max(seps)-seps[i]))
      empty_cols = rbind(empty_cols,empty_cols,empty_cols)
      wrapping_tb = cbind(wrapping_tb, empty_cols)
    } else{
      for(j in seq(seps[i])){
        index = seq(groups[i]+(j-1)*3,groups[i]+2+(j-1)*3)
        if(j==1){
          wrapping_tb = rbind(wrapping_tb,sub_tb[index]) 
        }
        if(j >1){
          wrapping_tb = cbind(wrapping_tb,sub_tb[index])
        }
      }
    }
    
    
    wrapped_tb = rbind(wrapped_tb,wrapping_tb,fill = T)
  }
  wrapped_tb[wrapped_tb == '']<-NA
  wrapped_tb = wrapped_tb[,colSums(is.na(wrapped_tb)) != nrow(wrapped_tb),with = F]
  return(wrapped_tb)
}



parse_splits = function(tb){
  # We find the entries with team names.  Rows without them are continuations of one teams' data.  There are also entries 'WPOC' in that
  #column that indicate membership in the orienteering club.  Again, this is meaningless in terms of sorting the data.
  
  #Team name comes in the second row of four.  We include a phantom entry past the end, since the wrap_rows needs to count ahead.
  sets = append(as.vector(which(tb[,1,with = F] != 'WPOC')),nrow(tb)+2)
  if(sum(tail(sets,n=-1)-head(sets,n=-1) != 3)){# if any of the teams' scores wrap to a new set of rows
    tb <- wrap_rows(tb,sets)
  }
  #The data is entered in the table as such - first row is the checkpoint.  Then the total time, then the split.  The first column is
  #mostly empty, except for the total time row, which is when the team name is entered.
  names = which(as.vector(!is.na(tb[,1,with = F]) & tb[,1,with = F] != 'WPOC'))

  checkpoints = names - 1
  total_time = names
  splits = names+1
  new_tbl = data.table()
  for(i in seq(length(names))){
    num_points = ncol(tb[names[i]]) - rowSums(is.na(tb[names[i]])) - 1 #the extra one is the name column, want to remove any empty columns left
    #now we begin creating the table, we want every row entry to have team name, checkpoint, split time, and total time
    test = data.table(Name = c(do.call("cbind",rep(tb[names[i],1,with=F],num_points))))
    test = mutate(test,Checkpoint = t(tb[checkpoints[i],seq(2,num_points+1),with = F]))
    test = mutate(test,Split = t(tb[splits[i],seq(2,num_points+1),with = F]))
    test = mutate(test,Total_time = t(tb[total_time[i],seq(2,num_points+1),with = F]))
    new_tbl = rbind(new_tbl,test)
  }
  return(new_tbl)
}


the_url <- 'http://www.wpoc.org/results/150322courses.htm'
tables <- tail(readHTMLTable(the_url,stringsAsFactors = F),n=-2)
tbl_6 <- tables[[2]]
cnames = tbl_6[1,]
tbl_6[1,1] <- 'Place'
tbl_6 <-mutate(tbl_6,time_limit= 6)
tbl_3 <- tables[[1]]
tbl_3 <-mutate(tbl_3,time_limit= 3)
tbl_3[1,1] <- 'Place'
tbl <- rbind(tbl_6,tail(tbl_3,n=-1))
colnames(tbl) = append(cnames,'time_limit')

tbl <- tail(tbl,n=-1)
for(i in c(1,5,6,7,8)){
  tbl[,i]<-as.numeric(tbl[,i])
}
title = 'Team_place_time_score.csv'
write.table(tbl,title,row.names = FALSE,col.names = FALSE,sep = ',')

the_url <- 'http://www.wpoc.org/results/2015visits.htm'
tables <- readHTMLTable(the_url,stringsAsFactors = F)
tbl <- tables[[1]]
title = paste(gsub(' ', '_', tbl[1,1]),'.csv',sep = '_')
colnames(tbl) <- tbl[2,]
tbl <- head(tail(tbl,n=-2),n=-1)
for(i in seq(ncol(tbl))){
  tbl[,i]<-as.numeric(tbl[,i])
}
write.table(tbl,title,sep = ',',row.names = F)

the_url <- 'http://www.wpoc.org/registrationlist2015.htm'
tables <- readHTMLTable(the_url,stringsAsFactors = F)
tbl_6 <- tables[[1]]
tbl_6 <-mutate(tbl_6,time_limit= 6)
tbl_3 <- tables[[2]]
tbl_3 <-mutate(tbl_3,time_limit= 3)
tbl <- rbind(tbl_6,tail(tbl_3,n=-1))
colnames(tbl) = tbl[1,]
colnames(tbl)[5]<- 'time_limit'
for(i in seq(ncol(tbl))){
  tbl[,i] <- gsub('Â','',tbl[,i])
}
tbl[grep('[^Y]',tbl[,4]),4] <- 'N'
tbl[2,3] <- '2'
tbl[60,3] <- '2'
title = 'registration_list.csv'
tbl <- tail(tbl,n=-1)
for(i in c(3,5)){
  tbl[,i]<-as.numeric(tbl[,i])
}
write.table(tbl,title,sep = ',',row.names = F)

the_url <- 'http://www.wpoc.org/results/150322splits.htm'
tables <- tail(readHTMLTable(the_url,stringsAsFactors = F),n=-1) #strictly decorative table starts the webpage, discard it
tb_formatted = data.table()

for(i in seq( length(tables) ) ){
  tb = data.table(tables[[i]],keep.rownames = F)[,c(-1,-2,-4,-5),with = F] #a few columns have no data as a formatting choice.  Kill them
  tb[tb ==''] <- NA #There are many empty cells in the tables on the website.  Replacing them with NA's
  tb = tb[rowSums(is.na(tb)) != ncol(tb)] #if every cell in the row is NA, discard it
  tb = tb[,colSums(is.na(tb)) != nrow(tb),with = F] #if every cell in a column is NA, discard it.
  
  tb_formatted = rbind(tb_formatted,parse_splits(tb))
}
write.table(tb_formatted,'Race_data_team_splits_checkpoints.csv',sep = ',',row.names = F)
