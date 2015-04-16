library(XML)
library(data.table)
the_url <- 'http://www.wpoc.org/results/150322courses.htm'
tables <- readHTMLTable(the_url)
#this is ugly, but so is the website.  There's two garbage tables in the page
#If anyone has a cleaner workaround, lemme know
for(i in seq(length(tables)-2)+2){
  write.table(data.table(tables[[i]]),paste('Race_data_team_places_points',toString(i-2),sep = '_'),row.names = FALSE,col.names = FALSE)
}

the_url <- 'http://www.wpoc.org/results/2015visits.htm'
tables <- readHTMLTable(the_url)
write.table(data.table(tables[[1]]),'Race_data_checkpoint_visits',row.names = FALSE,col.names = FALSE)

the_url <- 'http://www.wpoc.org/results/150322splits.htm'
tables <- readHTMLTable(the_url)
for(i in seq(length(tables)-1)+1){
  tb = data.table(tables[[i]],keep.rownames = F)

  data_rows = complete.cases(tb)
  tb = tb[data_rows,c(3,seq(6,ncol(tb))),with = F]#two sets of two columns of BS
  new_tb = parse_splits(tb)
  
  tb <- tb[,colSums(tb == '')<nrow(tb),with = F]
  checkpoints = names - 1
  splits = names + 1
  total_time = names+2
  
  num_points = ncol(tb[names[1]]) - rowSums(tb[names[1]]=='') - 1 #the extra one is the name column
  test = data.table(Name = rep(tb[names[1],1,with=F],num_points))
  
  test = mutate(test,Checkpoint = t(tb[checkpoints[1],seq(2,num_points+1),with = F]))
  test = mutate(test,Split = t(tb[splits[1],seq(2,num_points+1),with = F]))
  test = mutate(test,Total_time = t(tb[total_time[1],seq(2,num_points+1),with = F]))
  write.table(tb[data_rows,],paste('Race_data_team_splits_checkpoints',toString(i-1),sep = '_'),row.names = FALSE,col.names = FALSE)
}

parse_splits = function(tb){
  names = as.vector(which(tb[,1,with = F] != '' & tb[,1,with = F] != 'WPOC'))
  if(sum(names[2:length(names)]-names[1:length(names)-1] != 3)){
    
  }
  tb <- tb[,colSums(tb == '')<nrow(tb),with = F]
  checkpoints = names - 1
  splits = names
  total_time = names+1
  new_tbl = matrix(ncol = 4, nrow = (ncol(tb)-1)*nrow(tb)/3)
  for(i in seq(length(names))){
    num_points = ncol(tb[names[i]]) - rowSums(tb[names[i]]=='') - 1 #the extra one is the name column
    test = data.table(Name = rep(tb[names[i],1,with=F],num_points))
  
    test = mutate(test,Checkpoint = t(tb[checkpoints[i],seq(2,num_points+1),with = F]))
    test = mutate(test,Split = t(tb[splits[i],seq(2,num_points+1),with = F]))
    test = mutate(test,Total_time = t(tb[total_time[i],seq(2,num_points+1),with = F]))
    rbind(new_tbl,test)
  }
  
}

wrap_rows <- function(sub_tb){
  if (nrow(sub_tb) == 3) {
    return(sub_tb)
  }

  sets = nrow(sub_tb)/3-1
  i = 1
  new_tbl = sub_tb[1:3]
  print(new_tbl)
  while(sets){
    w_r = sub_tb[seq(3+i,5+i),]
    new_tbl = cbind(new_tbl, w_r)
    print(new_tbl)
    i = i+3
    sets = sets-1
  }
  return(new_tbl)
}