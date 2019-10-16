# fix_time ----

#' Fixes the time column of a data set
#'
#' Statistics Denmark data often come with times/dates that are formatted to
#' fit months or quarters. This function converts them in to proper date strings
#' in the format YYYY-MM-DD.
#'
#' @param date_string a string of dates formatted as months or quarters.
#' @param as_char whether to return the dates as data objects or character strings.
#'
#' @return a data frame
#' @export
#'
#' @examples
#' df <- statsDK::sdk_retrieve_data("FOLK1A", TID = "*", ALDER = "IALT",
#'                              CIVILSTAND = "TOT", lang = "da")
#' dplyr::glimpse(df)
#'
#' df$TID <- statsDK::sdk_fix_time(df$TID)
#' dplyr::glimpse(df)
#'
sdk_fix_time <- function(date_string, as_char = FALSE){

  # Fix quarters
  date_string <- gsub('(\\d{4})(Q|K)(1)', '\\1-01-01', date_string)
  date_string <- gsub('(\\d{4})(Q|K)(2)', '\\1-04-01', date_string)
  date_string <- gsub('(\\d{4})(Q|K)(3)', '\\1-07-01', date_string)
  date_string <- gsub('(\\d{4})(Q|K)(4)', '\\1-10-01', date_string)

  # Fix months
  date_string <- gsub('(\\d{4})(M)(\\d{2})', '\\1-\\3-01', date_string)

  # Convert to data format
  if(!as_char) date_string <- lubridate::ymd(date_string)

  # Return df with fixed time
  return(date_string)
}

# get_variables ----

#' Extracts variables from the list of meta data
#'
#' Extracts the variables and sets them up in a tibble so it is easy to see
#' what settings each parameter should have to get the desired data.
#'
#' @param metadata A list retrieved using the \link{sdk_retrieve_metadata} function.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' metadata <- statsDK::sdk_retrieve_metadata("BEV3A")
#' dplyr::glimpse(metadata)
#'
#' # See the variables as a data frame
#' variables <- sdk_get_variables(metadata)
#' dplyr::glimpse(variables)
#'
sdk_get_variables <- function(metadata){

  variables_df <- tibble::as_tibble(metadata$variables)

  variables <- tidyr::unnest(variables_df, cols = "values", names_repair = "minimal")

  names(variables) <- c("param", "type", "x", "y", "setting", "description")

  variables <- variables[, c("param", "setting", "type", "description")]

  variables <- tibble::as_tibble(variables)

  return(variables)

}
