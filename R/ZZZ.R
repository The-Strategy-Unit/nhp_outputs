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

get_selected_file_from_url <- function(session, key_b64 = Sys.getenv("NHP_ENCRYPT_KEY")) {
  f <- session$clientData$url_search |>
    stringr::str_sub(2L) |>
    utils::URLdecode()

  key <- openssl::base64_decode(key_b64)

  tryCatch(
    {
      fd <- openssl::base64_decode(f)

      hm <- fd[1:32]
      ct <- fd[-(1:32)]

      stopifnot("invalid hmac" = all(openssl::sha256(ct, key) == hm))

      rawToChar(openssl::aes_cbc_decrypt(ct, key, NULL))
    },
    error = \(e) NULL
  )
}

user_requested_cache_reset <- function(session) {
  if (!"nhp_devs" %in% session$groups) {
    return(FALSE)
  }
  u <- shiny::parseQueryString(session$clientData$url_search)

  !is.null(u$reset_cache)
}

server_get_results <- function(session) {
  file <- get_selected_file_from_url(session, Sys.getenv("NHP_ENCRYPT_KEY"))

  if (is.null(file)) {
    stop("No/Invalid file was requested.")
  }

  tryCatch(
    {
      get_results_from_azure(file)
    },
    error = \(e) {
      stop("Results not found.")
    }
  )
}

get_mitigator_lookup <- function() {
  mitigator_lookup <- app_sys("app", "data", "mitigators.json") |>
    jsonlite::read_json(simplifyVector = TRUE) |>
    purrr::simplify() |>
    tibble::enframe("strategy", "mitigator_name")
}
