#' @importFrom zeallot %<-%
#' @importFrom rlang .data
NULL

# converts a two column tibble into a named list suitable for shiny selectInput choices
set_names <- function(.x) {
  purrr::set_names(.x[[1]], .x[[2]])
}

# source: https://github.com/r-lib/tidyselect/issues/201#issuecomment-650547846
utils::globalVariables("where")

BATCH_EP <- "https://batch.core.windows.net/"
STORAGE_EP <- "https://storage.azure.com/"

fyear_str <- function(y) {
  glue::glue("{y}/{stringr::str_pad((y + 1) %% 100, 2, pad = '0')}")
}
