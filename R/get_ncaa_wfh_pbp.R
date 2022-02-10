#' Acquire NCAA Women's Field Hockey Play-by-Play Data
#'
#' @param game_id The unique game ID associated with each field hockey game.
#' This ID can be found in the url when viewing a game on ncaa.com. For example:
#' https://www.ncaa.com/game/5843349
#'
#' @return A data frame
#' @import jsonlite dplyr rvest stringr rvest xml2 janitor
#' @export
#'
#' @examples get_ncaa_wfh_team_roster(712, 2018)

get_ncaa_wfh_pbp <- function(game_id,
                             year) {

  # year_id <- fh_year_lu_table[which(fh_year_lu_table$season == year),]$season_id
  #
  # team <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
  #                                    fh_master_lu_table$year == year),]$school
  #
  # conference <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
  #                                          fh_master_lu_table$year == year),]$conference
  #
  # conference_id <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
  #                                             fh_master_lu_table$year == year),]$conference_id
  #
  # division <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
  #                                        fh_master_lu_table$year == year),]$division

  url <- paste0('https://data.ncaa.com/casablanca/game/', game_id, '/pbp.json')

  payload_read <- jsonlite::fromJSON(url)

  return(payload_read)
}

x <- get_ncaa_wfh_pbp(5892515, 2021)

x_all <- map_df(.x = seq(1,length(x[["periods"]][["playStats"]]),1),
       ~{x[["periods"]][["playStats"]][[.x]] %>%
          as.data.frame()
         })

gather(x_all) %>%
  filter(grepl('Text', key)) %>%
  View()



  payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[1] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame()

  names(payload_df) <- payload_df[1,]

  payload_df <- payload_df %>%
    janitor::clean_names() %>%
    .[-1,]

  payload_df <- payload_df %>%
    dplyr::mutate(team = team,
                  team_id = team_id,
                  year = year,
                  conference = conference,
                  conference_id = conference_id)

  payload_df <- payload_df %>%
    dplyr::select(team:conference_id, everything())

  return(payload_df)
}
