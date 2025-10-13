#' @importFrom zeallot %<-%
#' @importFrom rlang .data .env
#' @importFrom uuid UUIDgenerate
#' @importFrom stats approx density
NULL

#' Convert a two column tibble into a named list
#'
#' @description Converts a two column tibble into a named list suitable for
#'   shiny selectInput choices.
#'
#' @param .x A two column tibble.
#'
#' @return A named list where first column values are names and second column
#'   values are list elements.
#'
#' @noRd
set_names <- function(.x) {
  purrr::set_names(.x[[1]], .x[[2]])
}

utils::globalVariables(c(
  "where", # source: https://github.com/r-lib/tidyselect/issues/201#issuecomment-650547846
  "ds",
  "sc",
  "cd" # because of the use of %<-%
))

`__BATCH_EP__` <- "https://batch.core.windows.net/" # nolint: object_name_linter
`__STORAGE_EP__` <- "https://storage.azure.com/" # nolint: object_name_linter

#' Format financial year as string
#'
#' @description Converts a year number to a financial year string format
#'   (e.g., 2023 becomes "2023/24").
#'
#' @param y Integer. The starting year of the financial year.
#'
#' @return A character string representing the financial year in "YYYY/YY" format.
#'
#' @noRd
fyear_str <- function(y) {
  glue::glue("{y}/{stringr::str_pad((y + 1) %% 100, 2, pad = '0')}")
}

#' Require data frame to have rows
#'
#' @description Validates that a data frame exists and has at least one row.
#'   Uses shiny::req to halt reactive execution if validation fails.
#'
#' @param x A data frame or tibble.
#'
#' @return The input data frame if validation passes.
#'
#' @noRd
require_rows <- function(x) {
  shiny::req(x)
  shiny::req(nrow(x) > 0)
  x
}

#' Lookup organisation name from ODS code
#'
#' @description Retrieves the organisation name from the NHS ODS API using
#'   the organisation code.
#'
#' @param org_code Character. The ODS organisation code.
#'
#' @return Character. The organisation name, or "Unknown" if not found.
#'
#' @noRd
lookup_ods_org_code_name <- function(org_code) {
  req <- httr::GET(
    "https://uat.directory.spineservices.nhs.uk",
    path = c("ORD", "2-0-0", "organisations", org_code)
  )

  httr::content(req)$Organisation$Name %||% "Unknown"
}

#' Get selected file from encrypted URL parameter
#'
#' @description Decrypts and validates the file path from the URL query string.
#'   The URL parameter is expected to be base64-encoded and encrypted with AES-CBC,
#'   with HMAC-SHA256 for integrity verification.
#'
#' @param session Shiny session object.
#' @param key_b64 Character. Base64-encoded encryption key. Defaults to
#'   NHP_ENCRYPT_KEY environment variable.
#'
#' @return Character. The decrypted file path, or NULL if decryption fails.
#'
#' @noRd
get_selected_file_from_url <- function(
  session,
  key_b64 = Sys.getenv("NHP_ENCRYPT_KEY")
) {
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

#' Check if user requested cache reset
#'
#' @description Determines if the user has requested a cache reset via URL
#'   parameter. Only available to users in the "nhp_devs" group.
#'
#' @param session Shiny session object.
#'
#' @return Logical. TRUE if cache reset is requested and user is authorized,
#'   FALSE otherwise.
#'
#' @noRd
user_requested_cache_reset <- function(session) {
  if (!"nhp_devs" %in% session$groups) {
    return(FALSE)
  }
  u <- shiny::parseQueryString(session$clientData$url_search)

  !is.null(u$reset_cache)
}

#' Get results data from server
#'
#' @description Retrieves results data by decrypting the file path from the
#'   URL and loading it from Azure storage.
#'
#' @param session Shiny session object.
#'
#' @return List. The results data structure.
#'
#' @noRd
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

#' Get mitigator lookup table
#'
#' @description Reads the mitigators.json file and creates a lookup table
#'   with strategy codes, mitigator names, and extracted mitigator codes.
#'
#' @param mitigator_lookup Character. Path to the mitigators JSON file.
#'   Defaults to the app's internal data file.
#'
#' @return Tibble. Contains columns: strategy, mitigator_name, and mitigator_code.
#'
#' @noRd
get_mitigator_lookup <- function(
  mitigator_lookup = app_sys("app", "data", "mitigators.json")
) {
  mitigator_lookup |>
    jsonlite::read_json(simplifyVector = TRUE) |>
    purrr::simplify() |>
    tibble::enframe("strategy", "mitigator_name") |>
    dplyr::mutate(
      mitigator_code = stringr::str_extract(
        .data[["mitigator_name"]],
        "[:upper:]{2}-[:upper:]{2}-[:digit:]{3}"
      )
    )
}

#' Convert markdown file to HTML
#'
#' @description Reads a markdown file and converts it to HTML suitable for
#'   display in Shiny. Returns NULL if the file doesn't exist.
#'
#' @param ... Character vectors specifying the file path components passed
#'   to app_sys().
#'
#' @return HTML object containing the rendered markdown, or NULL if file
#'   doesn't exist.
#'
#' @noRd
md_file_to_html <- function(...) {
  file <- app_sys(...)

  if (!file.exists(file)) {
    return(NULL)
  }

  shiny::HTML(markdown::mark_html(file, output = FALSE, template = FALSE))
}
