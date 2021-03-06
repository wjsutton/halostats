# Merged datasets
library(dplyr)

filenames <- list.files('data',pattern = "^halo.*")
filetype <- ifelse(substr(filenames,7,7)=='a','all_matches','match_details')
version <- ifelse(substr(filenames,5,5)=='2','Halo 2','Halo 3')
tag <- ifelse(substr(filenames,7,7)=='a',
                   substr(filenames,19,nchar(filenames)-4),
                   substr(filenames,18,nchar(filenames)-4))

to_merge <- data.frame(name = filenames,type = filetype,game = version,gamertag = tag,stringsAsFactors = F)

all_matches <- filter(to_merge,type == 'all_matches')

for(i in 1:nrow(all_matches)){
  df <- read.csv(paste0('data/',all_matches$name[i]),stringsAsFactors = F)
  df$gamertag <- all_matches$gamertag[i]
  df$game <- all_matches$game[i]
  
  if(i == 1){
    all_matches_df <- df
  }
  if(i > 1){
    all_matches_df <- rbind(all_matches_df,df)
  }
}


write.csv(all_matches_df,'merged_data/all_matches.csv', row.names = F)

match_details <- filter(to_merge,type == 'match_details')

for(i in 1:nrow(match_details)){
  df <- read.csv(paste0('data/',match_details$name[i]),stringsAsFactors = F)
  #df$gamertag <- match_details$gamertag[i]
  df$game <- match_details$game[i]
  
  if(i == 1){
    match_details_df <- df
  }
  if(i > 1){
    match_details_df <- rbind(match_details_df,df)
  }
}

match_details_df <- unique(match_details_df)
match_details_df$Score <- as.integer(match_details_df$Score)

team_scores <- match_details_df %>% 
  filter(!is.na(team)) %>%
  group_by(game_id,game,team) %>%
  summarise(team_score = sum(as.integer(Score), na.rm = TRUE),
            team_kills = sum(as.integer(Kills), na.rm = TRUE))

team_scores <- team_scores %>%
  group_by(game_id,game) %>%
  mutate(game_score = sum(team_score),
         rank_team = rank(-team_score),
         rank_kill = rank(-team_kills))

team_scores$game_result <- ifelse(team_scores$game_score==0,team_scores$rank_kill,team_scores$rank_team)

match_details_df <- left_join(match_details_df,team_scores, by = c("game_id" = "game_id","game" = "game","team" = "team"))
write.csv(match_details_df,'merged_data/match_details.csv', row.names = F)

