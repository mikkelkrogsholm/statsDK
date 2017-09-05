# retrieve_subjects ----

#' Retrieves an overview of the subjects from Statistics Denmark
#'
#' The function retrieves a data frame with the over all statistical subjects
#' that can be pulled from Statistics Denmark.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' subjects <- statsDK::retrieve_subjects()
#' dplyr::glimpse(subjects)

retrieve_subjects <- function(){

  url <- "http://api.statbank.dk/v1/subjects?lang=en&format=JSON"

  json_data <- jsonlite::fromJSON(url)

  json_data$subjects <- NULL

  json_data <- tibble::as.tibble(json_data)

  return(json_data)
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
#' @return a tibble
#' @export
#'
#' @examples
#' tables <- statsDK::retrieve_tables()
#' dplyr::glimpse(tables)

retrieve_tables <- function(){

  url <- "http://api.statbank.dk/v1/tables?lang=en&format=JSON"

  json_data <- jsonlite::fromJSON(url)

  json_data <- tibble::as.tibble(json_data)

  return(json_data)
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
#'
#' @return a list
#' @export
#'
#' @examples
#' metadata <- statsDK::retrieve_metadata("FOLK1A")
#' dplyr::glimpse(metadata)

retrieve_metadata <- function(table_id){

  url <- paste0("http://api.statbank.dk/v1/tableinfo/",
                table_id, "?lang=en&format=JSON")

  json_data <- jsonlite::fromJSON(url)

  return(json_data)
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
#' df <- statsDK::retrieve_data("FOLK1A", ALDER = "*")
#' dplyr::glimpse(df)

retrieve_data <- function(table_id, ...){

  base_url <- paste0("http://api.statbank.dk/v1/data/",
                     table_id, "/JSONSTAT?lang=en")

  params <- list(...)

  if(length(params) > 0){
    url_string <- paste0(names(params), "=", unlist(params))
    url_string <- paste(url_string, collapse = "&")

    url <- paste0(base_url, "&", url_string)

    url <- utils::URLencode(url)

    print(url)
  } else {
    url <- base_url
  }

  json_data <- rjstat::fromJSONstat(url)

  data_name <- names(json_data)
  message(paste("Retrieved", data_name))

  json_data_df <- tibble::as.tibble(json_data[[1]])

  return(json_data_df)
}

