#' @importFrom zeallot %<-%
#' @importFrom rlang .data .env
#' @importFrom uuid UUIDgenerate
#' @importFrom stats approx density
NULL

# converts a two column tibble into a named list suitable for shiny selectInput choices
set_names <- function(.x) {
  purrr::set_names(.x[[1]], .x[[2]])
}

utils::globalVariables(c(
  "where", # source: https://github.com/r-lib/tidyselect/issues/201#issuecomment-650547846
  "ds", "sc", "cd" # because of the use of %<-%
))

`__BATCH_EP__` <- "https://batch.core.windows.net/" # nolint
`__STORAGE_EP__` <- "https://storage.azure.com/" # nolint

fyear_str <- function(y) {
  glue::glue("{y}/{stringr::str_pad((y + 1) %% 100, 2, pad = '0')}")
}

require_rows <- function(x) {
  shiny::req(x)
  shiny::req(nrow(x) > 0)
  x
}

lookup_ods_org_code_name <- function(org_code) {
  req <- httr::GET(
    "https://uat.directory.spineservices.nhs.uk",
    path = c("ORD", "2-0-0", "organisations", org_code)
  )

  httr::content(req)$Organisation$Name %||% "Unknown"
}

get_selected_file_from_url <- function(session) {
  session$clientData$url_search |>
    shiny::parseQueryString() |>
    _$file |>
    base64enc::base64decode() |>
    rawToChar()
}
