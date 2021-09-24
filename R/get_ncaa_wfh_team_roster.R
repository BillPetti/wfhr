#' Acquire NCAA Women's Field Hockey Rosters
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want data.
#' If you want the 2017-18 season, you would use 2018.
#'
#' @return A data frame
#' @import dplyr rvest stringr rvest xml2 janitor
#' @export
#'
#' @examples get_ncaa_wfh_team_roster(712, 2018)

get_ncaa_wfh_team_roster <- function(team_id,
                                     year) {

  year_id <- fh_year_lu_table[which(fh_year_lu_table$season == year),]$season_id

  team <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                     fh_master_lu_table$year == year),]$school

  conference <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                           fh_master_lu_table$year == year),]$conference

  conference_id <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                              fh_master_lu_table$year == year),]$conference_id

  division <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                         fh_master_lu_table$year == year),]$division

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/roster/', year_id)

  payload_read <- xml2::read_html(url)

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
