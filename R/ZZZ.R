#' @importFrom zeallot %<-%
#' @importFrom rlang .data .env
NULL

# converts a 2-column tibble to a named list suitable for selectInput choices
set_names <- \(x) rlang::set_names(x[[1]], x[[2]])

`__BATCH_EP__` <- "https://batch.core.windows.net/" # nolint: object_name_linter
`__STORAGE_EP__` <- "https://storage.azure.com/" # nolint: object_name_linter

reformat_fyear <- \(y) paste0(y, "/", pad((y + 1) %% 100))
pad <- \(x) ifelse(x < 10, paste0("0", x), as.character(x))

require_rows <- function(x) {
  shiny::req(x)
  shiny::req(nrow(x) > 0)
  x
}

lookup_ods_org_code_name <- function(org_code) {
  tryCatch(
    {
      httr2::request("https://uat.directory.spineservices.nhs.uk") |>
        httr2::req_url_path_append(
          "ORD",
          "2-0-0",
          "organisations",
          org_code
        ) |>
        httr2::req_perform() |>
        httr2::resp_body_json() |>
        purrr::pluck("Organisation", "Name", .default = "Unknown")
    },
    error = function(e) {
      "Unknown"
    }
  )
}

get_model_run <- function(url) {
  hx <- "[0-9a-f]"
  uuid_rx <- glue::glue("{hx}{8}-{hx}{4}-[1-5]{hx}{3}-[89ab]{hx}{3}-{hx}{12}")
  uuid_rx_grp <- paste0("^\\?[:alnum:]+/(", uuid_rx, ")$")

  dataset <- regmatches(url, regexpr("^\\?([:alnum:]+)", url))
  run_id <- regmatches(url, regexpr(uuid_rx_grp, url))
  stopifnot(
    "URL does not match expected pattern" = all(!is.na(c(dataset, run_id)))
  )

  get_model_run_from_ats(dataset, run_id)
}

user_requested_cache_reset <- function(session) {
  if (!"nhp_devs" %in% session$groups) {
    return(FALSE)
  }
  u <- shiny::parseQueryString(session$clientData$url_search)

  !is.null(u$reset_cache)
}

get_tretspef_lookup <- function(
  tretspef_lookup = app_sys("app", "data", "tx-lookup.json")
) {
  tretspef_lookup |>
    yyjsonr::read_json_file() |>
    dplyr::select(
      "code" = "Code",
      "tretspef" = "Description"
    )
}

get_tpma_lookup <- function() {
  app_sys("app", "data", "mitigators.json") |>
    yyjsonr::read_json_file() |>
    purrr::simplify() |>
    tibble::enframe("strategy", "tpma_label") |>
    dplyr::mutate(
      tpma_code = stringr::str_extract(
        .data[["tpma_label"]],
        "[:upper:]{2}-[:upper:]{2}-[:digit:]{3}"
      )
    )
}

# Params' create_datetime is expected to be a "%Y%m%d_%H%M%S" character
# string, but older/malformed model runs may have it missing or of the
# wrong type, so guard against that rather than erroring out of
# lubridate::fast_strptime()'s underlying parse_dt().
format_create_datetime <- function(x, fmt = "%Y%m%d_%H%M%S") {
  if (is.null(x) || length(x) != 1 || !is.character(x) || is.na(x)) {
    return(NA_character_)
  }
  parsed <- tryCatch(
    lubridate::fast_strptime(x, fmt),
    error = function(e) NA
  )
  if (is.na(parsed)) {
    return(NA_character_)
  }
  format(parsed, "%d-%b-%Y %H:%M:%S")
}

md_file_to_html <- function(...) {
  file <- app_sys(...)
  if (!file.exists(file)) {
    return(NULL)
  }
  shiny::HTML(markdown::mark_html(file, output = FALSE, template = FALSE))
}
