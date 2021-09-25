#' Look up Team Information
#'
#' @param school_name Full or partial name of the school (string)
#' @param school_division Division of the school (numeric)
#' @param school_conference Full or partial name of the conference (string)
#'
#' @import dplyr
#' @import magrittr
#' @return A data frame
#' @export
#'
#' @examples \dontrun{school_lu(school_name = 'California', school_division = 1, school_conference = 'PAC')}

school_lu <- function(school_name,
                      school_division,
                      school_conference) {

  payload <- fh_master_lu_table %>%
    dplyr::filter(grepl(school_name, school, ignore.case = T))

  if (!missing(school_division)) {

    payload <- payload %>%
      dplyr::filter(division == school_division)

  }

  if (!missing(school_conference)) {

    payload <- payload %>%
      dplyr::filter(grepl(school_conference, conference, ignore.case = T))

  }

  return(payload)
}
