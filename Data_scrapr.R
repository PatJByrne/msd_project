library(XML)
library(data.table)
library(dplyr)
wrap_rows <- function(sub_tb,sets){
  
  if (nrow(sub_tb) == 3) {
    return(sub_tb)
  }

  seps = (tail(sets,n=-1)-head(sets,n=-1))/3
  cols = ncol(tb)*max(seps)

  groups = (which(sub_tb$V3[seq(1,nrow(sub_tb),by=3)+1] != '') - 1) * 3 +1#fuck all 1-indexed languages
  groups = append(groups,nrow(sub_tb))

  wrapped_tb = data.table()
  
  for(i in seq(length(groups) -1)){
    wrapping_tb = data.table()
    print(c(i,seps,seps[i],max(seps)))    
    if(seps[i]!=max(seps)){
      wrapping_tb = rbind(wrapping_tb, sub_tb[groups[i]:(groups[i]+2)])
      empty_cols = rep('',ncol(sub_tb)*(max(seps)-seps[i]))
      empty_cols = rbind(empty_cols,empty_cols,empty_cols)
      wrapping_tb = cbind(wrapping_tb, empty_cols)
    } else{
      for(j in seq(seps[i])){
        #wrapping_tb = rbind(wrapping_tb, sub_tb[(groups[i]+3*(j-1)):((groups[i]+2)+3*(j-1))])
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
  sets = append(as.vector(which(tb[,1,with = F] != 'WPOC')),nrow(tb)+2)
  if(sum(tail(sets,n=-1)-head(sets,n=-1) != 3)){# if any of the teams' scores wrap to a new set of rows
    tb <- wrap_rows(tb,sets)
  }
  names = as.vector(which(tb[,1,with = F] != '' & tb[,1,with = F] != 'WPOC'))
  #tb <- tb[,colSums(tb == NA)<nrow(tb),with = F]
  checkpoints = names - 1
  splits = names
  total_time = names+1
  new_tbl = data.table()
  for(i in seq(length(names))){
    num_points = ncol(tb[names[i]]) - rowSums(is.na(tb[names[i]])) - 1 #the extra one is the name column
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
tables <- tail(readHTMLTable(the_url,stringsAsFactors = F),n=-1) #strictly decorative table starts the webpage
tb_formatted = data.table()

for(i in seq( length(tables) ) ){
  tb = data.table(tables[[i]],keep.rownames = F)[,c(-1,-2,-4,-5),with = F]
  tb[tb ==''] <- NA
  tb = tb[rowSums(is.na(tb)) != ncol(tb)]
  tb = tb[,colSums(is.na(tb)) != nrow(tb),with = F]
  
  #tb = tb[,c(3, seq(6,ncol(tb)) ),with = F]#skipping the redundant final time and team league
  #data_rows = complete.cases(tb)
  #tb = tb[data_rows, c(3, seq(6,ncol(tb)) ),with = F]#two sets of two columns of BS
  tb_formatted = rbind(tb_formatted,parse_splits(tb))
}
write.table(tb_formatted,'Race_data_team_splits_checkpoints.csv',sep = ',',row.names = F)
