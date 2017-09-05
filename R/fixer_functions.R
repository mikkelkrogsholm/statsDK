# fix_time ----

#' Fixes the time column of a data set
#'
#' Statistics Denmark data often come with times/dates that are formatted to
#' fit months or quarters. This function converts them in to proper date strings
#' in the format YYYY-MM-DD.
#'
#' @param df a table with a time column from Statistics Denmark. Usually retrieved
#'     using the \link{retrieve_data} function.
#'
#' @return a data frame
#' @export
#'
#' @examples
#' df <- statsDK::retrieve_data("FOLK1A", TID = "*")
#' dplyr::glimpse(df)
#'
#' df <-  statsDK::fix_time(df)
#' dplyr::glimpse(df)
#'
fix_time <- function(df){

  # Fix quarters
  df$time <- gsub('(\\d{4})(Q)(1)', '\\1-01-01', df$time)
  df$time <- gsub('(\\d{4})(Q)(2)', '\\1-04-01', df$time)
  df$time <- gsub('(\\d{4})(Q)(3)', '\\1-07-01', df$time)
  df$time <- gsub('(\\d{4})(Q)(4)', '\\1-10-01', df$time)

  # Fix months
  df$time <- gsub('(\\d{4})(M)(\\d{2})', '\\1-\\3-01', df$time)

  # Return df with fixed time
  return(df)
}

# get_variables ----

#' Extracts variables from the list of meta data
#'
#' Extracts the variables and sets them up in a tibble so it is easy to see
#' what settings each parameter should have to get the desired data.
#'
#' @param metadata A list retrieved using the \link{retrieve_metadata} function.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' metadata <- statsDK::retrieve_metadata("BEV3A")
#' dplyr::glimpse(metadata)
#'
#' # See the variables as a data frame
#' variables <- get_variables(metadata)
#' dplyr::glimpse(variables)
#'
get_variables <- function(metadata){

  variables <- tidyr::unnest_(metadata$variables, "values")

  variables <- variables[, c("id", "id1", "text1", "text")]

  names(variables) <- c("param", "setting", "description", "type")

  variables <- tibble::as.tibble(variables)

  return(variables)

}
