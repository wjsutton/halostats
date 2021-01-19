# Script to get data from Halo 3 matchmaking
# e.g. http://halo.bungie.net/stats/playerstatshalo3.aspx?player=THE%20TRUTH%2012

library(rvest)
library(dplyr)
library(stringr)
library(purrr)

# Enter a gamertag
gamertag <- 'No Hibbert No'
gamertag_link <- gsub(' ','%20',toupper(gamertag))
gamertag_for_file <- gsub(' ','_',tolower(gamertag))

page_number <- 1

halo3 <- paste0('http://halo.bungie.net/stats/playerstatshalo3.aspx?player='
                ,gamertag_link,'&ctl00_mainContent_bnetpgl_recentgamesChangePage='
                ,page_number)
halo3_html <- read_html(halo3)

h3_total_games <- rvest::html_nodes(halo3_html,'strong')[1]
h3_total_pages <- rvest::html_nodes(halo3_html,'strong')[2]

h3_total_games <- as.integer(str_extract(as.character(h3_total_games),'[0-9]+'))
h3_total_pages <- as.integer(str_extract(as.character(h3_total_pages),'[0-9]+'))

for(i in 1:h3_total_pages){
  
  halo3 <- paste0('http://halo.bungie.net/stats/playerstatshalo3.aspx?player='
                  ,gamertag_link,'&ctl00_mainContent_bnetpgl_recentgamesChangePage='
                  ,i)
  halo3_html <- read_html(halo3)
  
  match_list <- rvest::html_nodes(halo3_html,'.rgMasterTable') %>% html_table(fill = TRUE) 
  
  match_df <- as.data.frame(match_list)
  match_df <- match_df[8:nrow(match_df),1:5]
  names(match_df) <- c('match_variant','date','map','playlist','place')
  
  table_links <- as.character(rvest::html_nodes(halo3_html,'tbody tr td a'))
  
  game_ids <- str_extract(table_links, "gameid=[0-9]+")
  game_ids <- game_ids[!is.na(game_ids)]
  game_id_number <- substr(game_ids,8,nchar(game_ids))
  match_df$game_id <- game_id_number
  
  if(i == 1){
    all_matches_df <- match_df
  }
  
  if(i != 1){
    all_matches_df <- rbind(all_matches_df,match_df)
  }
  Sys.sleep(3)
  print(paste0("halo 3 page: ",i," downloaded."))
}

write.csv(all_matches_df,paste0('data/halo3_all_matches_',gamertag_for_file,'.csv'), row.names = F)

