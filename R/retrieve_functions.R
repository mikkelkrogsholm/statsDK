# retrieve_subjects ----

#' Retrieves an overview of the subjects from Statistics Denmark
#'
#' The function retrieves a data frame with the over all statistical subjects
#' that can be pulled from Statistics Denmark.
#'
#' @param base_url is the base url for the API you wish to call. Statistics Denmark
#'     can sometimes create custom API's that you can use by changing this
#'     parameter.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' subjects <- statsDK::retrieve_subjects()
#' dplyr::glimpse(subjects)

retrieve_subjects <- function(base_url = "http://api.statbank.dk/v1/"){

  url <- paste0(base_url, "subjects?lang=en&format=JSON")

  # Get data ----
  get_data <- suppressWarnings(httr::GET(url))

  # Decide if error ----
  if(get_data$status_code != 200){
    content_data <- httr::content(get_data, "text", encoding = "UTF-8")
    content_data <- jsonlite::fromJSON(content_data)
    my_message <- paste(content_data$message, collapse = "\n")
    message(my_message)
    return(NULL)
  } else {
    message("Subjects collected succesfully")
  }

  content_data <- httr::content(get_data, "text", encoding = "UTF-8")
  content_data <- jsonlite::fromJSON(content_data)

  content_data$subjects <- NULL

  content_data <- tibble::as.tibble(content_data)

  return(content_data)
}

# retrieve_tables ----

#' Retrieves an overview of the tables from Statistics Denmark
#'
#' The function retrieves a data frame with all the available tables from the
#' Statistics Denmark API.
#'
#' \describe{
#'   \item{id}{The id of the table. This is used when calling specific tables
#'       later with \link{retrieve_metadata} or \link{retrieve_data}.}
#'   \item{text}{A description of what the data in the table is about.}
#'   \item{unit}{What unit the data is in.}
#'   \item{updated}{When the table was last updated}
#'   \item{firstPeriod}{The first period in the data, ie how far back the data goes.}
#'   \item{latestPeriod}{The latest period in the data.}
#'   \item{active}{If the table is still being updated}
#'   \item{variables}{A list of the variables in the tables.}
#' }
#'
#' @param base_url is the base url for the API you wish to call. Statistics Denmark
#'     can sometimes create custom API's that you can use by changing this
#'     parameter.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' tables <- statsDK::retrieve_tables()
#' dplyr::glimpse(tables)

retrieve_tables <- function(base_url = "http://api.statbank.dk/v1/"){

  url <- paste0(base_url, "tables?lang=en&format=JSON")

  # Get data ----
  get_data <- suppressWarnings(httr::GET(url))

  # Decide if error ----
  if(get_data$status_code != 200){
    content_data <- httr::content(get_data, "text", encoding = "UTF-8")
    content_data <- jsonlite::fromJSON(content_data)
    my_message <- paste(content_data$message, collapse = "\n")
    message(my_message)
    return(NULL)
  } else {
    message("Tables collected succesfully")
  }

  content_data <- httr::content(get_data, "text", encoding = "UTF-8")

  content_data <- jsonlite::fromJSON(content_data)

  content_data <- tibble::as.tibble(content_data)

  return(content_data)
}

# retrieve_metadata ----

#' Retrieves metadata for a specific table from Statistics Denmark
#'
#' The function retrieves a list with a lot of metadata about a certain table.
#'
#' \describe{
#'   \item{id}{The id of the table.}
#'   \item{text}{A description of what the data in the table is about.}
#'   \item{unit}{What unit the data is in.}
#'   \item{contact}{Who to contact regarding the data.}
#'   \item{documentation}{Link to a web page with detailed description of the data.}
#'   \item{footnote}{A footnote if applicable.}
#'   \item{variables}{Details about the variables in the table. Is very useful for
#'       when using the \link{retrieve_data} function.}
#' }
#'
#' @param table_id is the id of the table you want to call. You can get table ids
#'     by calling the \link{retrieve_tables} function.
#' @param base_url is the base url for the API you wish to call. Statistics Denmark
#'     can sometimes create custom API's that you can use by changing this
#'     parameter.
#'
#' @return a list
#' @export
#'
#' @examples
#' metadata <- statsDK::retrieve_metadata("PRIS111")
#' dplyr::glimpse(metadata)

retrieve_metadata <- function(table_id, base_url = "http://api.statbank.dk/v1/"){

  url <- paste0(base_url, "tableinfo/",
                table_id, "?lang=en&format=JSON")

  # Get data ----
  get_data <- suppressWarnings(httr::GET(url))

  # Decide if error ----
  if(get_data$status_code != 200){
    content_data <- httr::content(get_data, "text", encoding = "UTF-8")
    content_data <- jsonlite::fromJSON(content_data)
    my_message <- paste(content_data$message, collapse = "\n")
    my_message2 <- paste0('\nConsider calling retrieve_tables() to see available tables.')
    message(paste(my_message, my_message2))
    return(NULL)
  } else {
    message("Metadata collected succesfully")
  }

  content_data <- httr::content(get_data, "text", encoding = "UTF-8")

  content_data <- jsonlite::fromJSON(content_data)

  return(content_data)
}

# retrieve_data ----

#' Retrieves a specific table from Statistics Denmark
#'
#' The function retrieves a specific table from Statistics Denmark based on a
#' table ID and some parameters to the API.
#'
#' @param table_id is the id of the table you want to call. You can get table ids
#'     by calling the \link{retrieve_tables} function.
#' @param ... are parameters you need to use to specify what data you want from
#'     the API. See the data created by the \link{retrieve_metadata} function.
#'     An * indicates ALL settings in the given parameter.
#' @param base_url is the base url for the API you wish to call. Statistics Denmark
#'     can sometimes create custom API's that you can use by changing this
#'     parameter.
#' @param lang whether to return the data in english or danish.
#'
#' @return a data frame
#' @export
#'
#' @examples
#'
#' metadata <- statsDK::retrieve_metadata("FOLK1A")
#' dplyr::glimpse(metadata)
#'
#' # See the variables as a data frame
#' variables <- statsDK::get_variables(metadata)
#' dplyr::glimpse(variables)
#'
#' # Use the param and the settings columns from the variables data to set the
#' # rigth values for the API call.
#' df_en <- statsDK::retrieve_data("PRIS111", VAREGR = "000000", ENHED = "*",
#'                                 Tid = paste(paste0("2017M0", 1:8), collapse = ","))
#' dplyr::glimpse(df_en)
#'
#' df_da <- statsDK::retrieve_data("PRIS111", VAREGR = "000000", ENHED = "*",
#'                                 Tid = paste(paste0("2017M0", 1:8), collapse = ","),
#'                                 lang = "da")
#' dplyr::glimpse(df_da)

retrieve_data <- function(table_id, ..., lang = "en", base_url = "http://api.statbank.dk/v1/"){

  # Get table meta data ----
  metadata <- suppressMessages(retrieve_metadata(table_id, base_url))
  data_ids <- metadata$variables$id
  data_text <- metadata$variables$text

  # Choose baseurl based on language setting ----
  if(lang != "en"){
    base_url <- paste0(base_url, "data/",
                       table_id, "/BULK?")
  } else {
    base_url <- paste0(base_url, "data/",
                       table_id, "/BULK?lang=en")
  }

  # Params and url builder ----
  params <- list(...)

  # All params must be declared. Fill out if missing.
  missing_ids <- data_ids[!(data_ids %in% names(params))]
  if(length(missing_ids) > 0) message(paste("Autosetting missing values to * for:",
                                            paste(missing_ids, collapse = ", ")))
  missing_params <- lapply(missing_ids, function(i) "*")
  names(missing_params) <- missing_ids
  params <- c(params, missing_params)

  # Build url
  url_string <- paste0(names(params), "=", unlist(params))
  url_string <- paste(url_string, collapse = "&")

  if(lang == "en"){ url <- paste0(base_url, "&", url_string)} else {
    url <- paste0(base_url, url_string)
  }

  url <- utils::URLencode(url)

  # Get data ----
  # Notify user
  message("Getting data. This can take a while, if the data is very large.")

  get_data <- suppressWarnings(httr::GET(url))

  # Decide if error ----
  if(get_data$status_code != 200){
    content_data <- httr::content(get_data, "text", encoding = "UTF-8")
    content_data <- jsonlite::fromJSON(content_data)
    my_message <- paste(content_data$message, collapse = "\n")
    my_message2 <- paste0('\nConsider calling retrieve_metadata("', table_id,
                          '") to see available parameters.')
    message(paste(my_message, my_message2))
    return(NULL)
  } else {
    message("Data collected succesfully")
  }

  # Extract data ----
  content_data <- httr::content(get_data, "text")
  content_data <- readr::read_csv2(content_data,
                                   locale = readr::locale(
                                     decimal_mark = ",",
                                     grouping_mark = ".",
                                     tz = "CET"
                                   ))

  # Add metadata as attribute ----
  attr(content_data, "metadata") <- metadata

  # Return the data ----
  return(content_data)

}
