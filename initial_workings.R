# Bungie.net is going offline 9th Feb 2021
# AIM download all my data before then
# http://halo.bungie.net/stats/halo3/default.aspx?player=THE%20TRUTH%2012

# Halo 2 match page
# http://halo.bungie.net/stats/playerstatshalo2.aspx?player=THE%20TRUTH%2012
# RSS feed: http://halo.bungie.net/stats/halo2rss.ashx?g=THE%20TRUTH%2012

# Halo 3 match page and campaign
# http://halo.bungie.net/stats/playerstatshalo3.aspx?player=THE%20TRUTH%2012
# http://halo.bungie.net/stats/playercampaignstatshalo3.aspx?player=THE%20TRUTH%2012

### TO DO
# Halo2 - map xml_nodesets to dataframes

library(rvest)
library(dplyr)
library(stringr)
library(purrr)

halo2 <- 'http://halo.bungie.net/stats/playerstatshalo2.aspx?player=THE%20TRUTH%2012&ctl00_mainContent_bnetpgl_recentgamesChangePage=1'
halo2_html <- read_html(halo2)

h2_total_games <- rvest::html_nodes(halo2_html,'strong')[1]
h2_total_pages <- rvest::html_nodes(halo2_html,'strong')[2]

game_page <- rvest::html_nodes(halo2_html,'tbody td')

match_page <- 'http://halo.bungie.net/Stats/GameStatsHalo2.aspx?gameid=781660958&player=THE%20TRUTH%2012'
match_html <- read_html(match_page)

# take carnage pages - has more data
carnage_stats <- rvest::html_nodes(match_html,'.stats')[2]
carnage_table <- rvest::html_nodes(match_html,'.stats')[2] %>% html_table()

rvest::html_nodes(halo2_html,'tbody td')

test <- rvest::html_nodes(halo2_html,'.rgMasterTable') %>% html_table(fill = TRUE) 

test_df <- as.data.frame(test)
match_df <- test_df[8:32,1:5]
names(match_df) <- c('match_variant','date','map','playlist','place')

table_links <- as.character(rvest::html_nodes(halo2_html,'tbody tr td a'))

game_ids <- str_extract(table_links, "gameid=[0-9]+")
game_ids <- game_ids[!is.na(game_ids)]
game_id_number <- substr(game_ids,8,16)
match_df$game_id <- game_id_number

### Tried to pull RSS feed - only shows latest games
# install.packages("tidyRSS")
#library(tidyRSS)
#//*[@id="ctl00_mainContent_bnetpgl_recentgames_ctl00"]/tbody
#halo2_rss <- 'http://halo.bungie.net/stats/halo2rss.ashx?g=THE%20TRUTH%2012'
#test <- tidyfeed(halo2_rss)
