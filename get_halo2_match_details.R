# Halo 2 Get match details from
# http://halo.bungie.net/Stats/GameStatsHalo2.aspx?gameid=781660958&player=THE%20TRUTH%2012
# pulling carnage page as has more detail

library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)

# enter gamertag
gamertag <- ''
gamertag_link <- gsub(' ','%20',toupper(gamertag))
gamertag_for_file <- gsub(' ','_',tolower(gamertag))

matches <- read.csv(paste0('data/halo2_all_matches_',gamertag_for_file,'.csv'),stringsAsFactors = F)

ids <- matches$game_id

for(i in 1:length(ids)){
  match_page <- paste0('http://halo.bungie.net/Stats/GameStatsHalo2.aspx?gameid=',ids[i],'&player=',gamertag_link)
  
  tryCatch({
    match_html <- read_html(match_page)
  }, 
  error = function(error_condition) {
    print("error in download, waiting 5 mins then trying again...")
    Sys.sleep(5*60)
    match_html <- read_html(match_page)
  })
  
  
  # take carnage pages - has more data
  carnage_table <- rvest::html_nodes(match_html,'.stats')[2] %>% html_table()
  carnage_table <- carnage_table[[1]]
  names(carnage_table) <- c(carnage_table[1,])
  carnage_table <- carnage_table[2:nrow(carnage_table),]
  
  # Add team to table
  carnage_table$team <- str_extract(trimws(carnage_table$Players),'^.*Team$')
  carnage_table <- carnage_table %>% fill(team, .direction = "down")
  
  # Remove team subtotal
  team_total_locations <- grep(' Team',carnage_table$Players)
  number_of_players <- nrow(carnage_table)
  
  players <- 1:number_of_players 
  players <- players[!(players %in% team_total_locations)]
  
  carnage_table <- carnage_table[players,]
  
  # Extract player rank and name from Player column
  carnage_table$player_rank <- ifelse(is.na(str_locate(carnage_table$Players,'\r\n')[1]),NA,str_extract(carnage_table$Players,'\\d+$'))
  carnage_table$player <-trimws(str_extract(carnage_table$Players,'^[A-z|\\d| |(|)]*'))
  
  # add game id
  carnage_table$game_id <- ids[i]
  
  #reorder columns
  carnage_table <- carnage_table[,c(12:9,2:8)]
  
  if(i == 1001){
    match_details_df <- carnage_table
  }
  
  if(i != 1001){
    match_details_df <- rbind(match_details_df,carnage_table)
  }
  Sys.sleep(3)
  print(paste0("halo 2 match: ",i," downloaded."))
  
}

write.csv(match_details_df,paste0('data/halo2_match_data_',gamertag_for_file,'_02.csv'), row.names = F)

