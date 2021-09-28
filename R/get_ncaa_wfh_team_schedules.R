#' Acquire NCAA Women's Field Hockey Schedules and Results
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want data.
#' If you want the 2017-18 season, you would use 2018.
#'
#' @return A data frame
#' @import dplyr rvest stringr rvest xml2 janitor
#' @export
#'
#' @examples get_ncaa_wfh_team_schedules(712, 2018)

get_ncaa_wfh_team_schedules <- function(team_id,
                                        year,
                                        get_boxscore_urls = FALSE) {

  year_id <- fh_year_lu_table[which(fh_year_lu_table$season == year),]$season_id

  team <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                     fh_master_lu_table$year == year),]$school

  conference <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                           fh_master_lu_table$year == year),]$conference

  conference_id <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                              fh_master_lu_table$year == year),]$conference_id

  division <- fh_master_lu_table[which(fh_master_lu_table$school_id == team_id &
                                         fh_master_lu_table$year == year),]$division

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/', year_id)

  payload_read <- xml2::read_html(url)

  main_payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[2] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame()

  # if the user wants boxscores
  if (get_boxscore_urls == FALSE) {

    if (year >= 2019) {

      payload_df <- main_payload_df %>%
        janitor::clean_names() %>%
        dplyr::mutate(date = lubridate::mdy(date)) %>%
        dplyr::filter(!is.na(date)|date != '')

      payload_df <- payload_df %>%
        dplyr::filter(result != '')

      payload_df <- payload_df %>%
        dplyr::mutate(attendance = as.character(attendance)) %>%
        dplyr::mutate(attendance = readr::parse_number(attendance))

    } else {

      names(main_payload_df) <- main_payload_df[2,]

      payload_df <- main_payload_df[-c(1:2),]

      payload_df <- payload_df %>%
        dplyr::filter(Result != '')

      payload_df <- payload_df %>%
        janitor::clean_names() %>%
        dplyr::mutate(date = lubridate::mdy(date))

      payload_df <- payload_df %>%
        dplyr::mutate(attendance = NA) %>%
        dplyr::mutate(attendance = as.numeric(attendance))

    }

  } else {

    if (year >= 2019) {

      payload_df <- main_payload_df %>%
        janitor::clean_names() %>%
        dplyr::mutate(date = lubridate::mdy(date)) %>%
        dplyr::filter(!is.na(date)|date != '')

      payload_df <- payload_df %>%
        dplyr::filter(result != '')

      payload_df <- payload_df %>%
        dplyr::mutate(attendance = as.character(attendance)) %>%
        dplyr::mutate(attendance = readr::parse_number(attendance))

      box_score_slugs <- payload_read %>%
        rvest::html_nodes('fieldset .skipMask') %>%
        rvest::html_attr('href') %>%
        as.data.frame() %>%
        dplyr::rename(boxscore_url = '.') %>%
        dplyr::mutate(boxscore_url = paste0('http://stats.ncaa.org', boxscore_url)) %>%
        dplyr::filter(grepl('box_score', boxscore_url))

      if(nrow(box_score_slugs) < nrow(payload_df)) {

        joined_boxscores <- payload_df %>%
          dplyr::mutate(row = row_number()) %>%
          dplyr::filter(!result %in% c('Ppd', 'Canceled')) %>%
          dplyr::bind_cols(box_score_slugs) %>%
          dplyr::select(row, boxscore_url)

        payload_df <- payload_df %>%
          dplyr::mutate(row = row_number()) %>%
          dplyr::left_join(joined_boxscores, by = 'row') %>%
          dplyr::select(-row)

      } else {

        payload_df <- payload_df %>%
          dplyr::mutate(boxscore_url = box_score_slugs$boxscore_url)
      }

    } else {

      names(main_payload_df) <- main_payload_df[2,]

      payload_df <- main_payload_df[-c(1:2),]

      payload_df <- payload_df %>%
        dplyr::filter(Result != '')

      payload_df <- payload_df %>%
        janitor::clean_names() %>%
        dplyr::mutate(date = lubridate::mdy(date))

      payload_df <- payload_df %>%
        dplyr::mutate(attendance = NA) %>%
        dplyr::mutate(attendance = as.numeric(attendance))

    }

  }

  payload_df <- payload_df %>%
    dplyr::mutate(result = stringr::str_extract_all(payload_df$result, '[A-Z]', simplify = TRUE)[,1]) %>%
    dplyr::mutate(goals_for = stringr::str_extract_all(payload_df$result, pattern = '[0-9]+', simplify = TRUE)[,1],
                  goals_against = stringr::str_extract_all(payload_df$result, pattern = '[0-9]+', simplify = TRUE)[,2])

  payload_df <- payload_df %>%
    dplyr::mutate(location = ifelse(grepl('^@.*', payload_df$opponent), 'away',
                                    ifelse(!grepl('@', payload_df$opponent), 'home', 'neutral'))) %>%
    dplyr::mutate(location = ifelse(result == "P", 'game postponed', location)) %>%
    dplyr::mutate(location = ifelse(result == "Ppd", 'game postponed', location)) %>%
    dplyr::mutate(opponent = ifelse(location == 'neutral', gsub('@.*', '', opponent), opponent)) %>%
    dplyr::mutate(opponent = gsub(pattern = '(?<![A-Z])@[A-Z].*',
                                  replacement = '',
                                  .$opponent, perl = TRUE)) %>%
    dplyr::mutate(opponent = gsub('@', '', opponent)) %>%
    dplyr::mutate(opponent = stringr::str_trim(opponent))

  payload_df <- payload_df %>%
    dplyr::mutate(opponent = stringr::str_trim(payload_df$opponent)) %>%
    dplyr::mutate(opponent = gsub('\\(|\\)', '', opponent))

  payload_df <- payload_df %>%
    dplyr::mutate(opponent = unlist(regmatches(payload_df$opponent,
                                               gregexpr(paste0(fh_distinct_teams, collapse = "|"),
                                                        payload_df$opponent))))
  payload_df <- payload_df %>%
    dplyr::mutate(team = team,
                  conference = conference,
                  conference_id = conference_id,
                  division = division) %>%
    dplyr::select(team, conference, conference_id, division, everything())

  return(payload_df)
}
