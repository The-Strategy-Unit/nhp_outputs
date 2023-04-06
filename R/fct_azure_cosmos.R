get_results_container <- function() {
  resource <- `__STORAGE_EP__`

  t <- if (Sys.getenv("AAD_TENANT_ID") == "") {
    AzureAuth::get_managed_token(resource)
  } else {
    AzureAuth::get_azure_token(
      resource,
      Sys.getenv("AAD_TENANT_ID"),
      Sys.getenv("AAD_APP_ID"),
      Sys.getenv("AAD_APP_SECRET")
    )
  }

  AzureStor::storage_container(
    glue::glue("{Sys.getenv('STORAGE_URL')}/results"),
    token = AzureAuth::extract_jwt(t)
  )
}

get_result_sets <- function(dataset, local = getOption("golem.app.prod")) {
  if (local) {
    path <- file.path(Sys.getenv("RESULTS_PATH"), dataset)

    files <- fs::dir_ls(path, glob = "*.json")

    return(
      purrr::set_names(
        files,
        stringr::str_sub(files, stringr::str_length(path) + 2, -6)
      )
    )
  }

  app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
    stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

  AzureStor::list_blobs(
    get_results_container(),
    paste(app_version, dataset, sep = "/"),
    "name"
  )
}

get_results <- function(filename, local = getOption("golem.app.prod")) {
  if (local) {
    r <- jsonlite::read_json(filename, simplifyVector = FALSE)
  } else {
    cont <- get_results_container()
    tf <- withr::local_tempfile()
    AzureStor::download_blob(cont, filename, tf)

    r <- readBin(tf, raw(), n = file.size(tf)) |>
      jsonlite::parse_gzjson_raw(simplifyVector = FALSE)
  }

  r$population_variants <- as.character(r$population_variants)

  r$results <- purrr::map(
    r$results,
    purrr::map_dfr,
    purrr::modify_at,
    "model_runs",
    purrr::compose(list, as.numeric)
  )

  r
}

get_user_allowed_datasets <- function(user) {
  # TODO: this should be grabbed from cosmos
  if (is.null(user)) {
    "synthetic"
  } else {
    c(
      "synthetic",
      "RA9", "RD8", "RGP", "RGR", "RH5", "RH8", "RHW", "RN5", "RNQ", "RX1", "RXC", "RXN_RTX", "RYJ"
    )
  }
}

get_trust_sites <- function(r) {
  sites <- r$results$default$sitetret
  unique(c("trust", sort(sites)))
}

get_available_aggregations <- function(r) {
  r$results |>
    purrr::keep(\(.x) "pod" %in% colnames(.x)) |>
    purrr::map(
      \(.x) .x |>
        dplyr::pull("pod") |>
        stringr::str_extract("^[a-z]*") |>
        unique()
    ) |>
    tibble::enframe() |>
    tidyr::unnest("value") |>
    dplyr::group_by(.data$value) |>
    dplyr::summarise(dplyr::across("name", list)) |>
    tibble::deframe()
}

get_model_run_years <- function(r) {
  r$params[c("start_year", "end_year")]
}

get_principal_high_level <- function(r) {
  r$results$default |>
    dplyr::filter(!.data$measure %in% c("beddays", "procedures", "tele_attendances")) |>
    dplyr::select("pod", "sitetret", "baseline", "principal") |>
    dplyr::mutate(
      dplyr::across("pod", ~ ifelse(stringr::str_starts(.x, "aae"), "aae", .x))
    ) |>
    dplyr::group_by(.data$pod, .data$sitetret) |>
    dplyr::summarise(dplyr::across(where(is.numeric), sum), .groups = "drop") |>
    trust_site_aggregation()
}

get_model_core_activity <- function(r) {
  r$results$default |>
    dplyr::select(-"model_runs") |>
    trust_site_aggregation()
}

get_variants <- function(r) {
  r$population_variants |>
    utils::tail(-1) |>
    tibble::enframe("model_run", "variant")
}

get_model_run_distribution <- function(r, pod, measure) {
  filtered_results <- r$results$default |>
    dplyr::filter(
      .data$pod == .env$pod,
      .data$measure == .env$measure
    ) |>
    dplyr::select("sitetret", "baseline", "model_runs")

  if (nrow(filtered_results) == 0) {
    return(NULL)
  }

  filtered_results |>
    dplyr::mutate(
      dplyr::across(
        "model_runs",
        purrr::map,
        tibble::enframe,
        name = "model_run"
      )
    ) |>
    tidyr::unnest("model_runs") |>
    dplyr::inner_join(get_variants(r), by = "model_run") |>
    trust_site_aggregation()
}

get_aggregation <- function(r, pod, measure, agg_col) {
  agg_type <- glue::glue("sex+{agg_col}") # nolint
  filtered_results <- r$results[[agg_type]] |>
    dplyr::filter(
      .data$pod == .env$pod,
      .data$measure == .env$measure
    ) |>
    dplyr::select(-"pod", -"measure")

  if (nrow(filtered_results) == 0) {
    return(NULL)
  }

  filtered_results |>
    dplyr::mutate(
      dplyr::across(dplyr::matches("sex"), as.character)
    ) |>
    trust_site_aggregation()
}

get_principal_change_factors <- function(r, activity_type) {
  stopifnot(
    "Invalid activity_type" = activity_type %in% c("aae", "ip", "op")
  )

  r$results$step_counts |>
    dplyr::filter(.data$activity_type == .env$activity_type) |>
    dplyr::select("measure", "change_factor", "strategy", "value") |>
    dplyr::mutate(dplyr::across("strategy", \(.x) tidyr::replace_na(.x, "-")))
}

get_bed_occupancy <- function(r) {
  r$results$bed_occupancy |>
    dplyr::select(
      "measure",
      "quarter",
      "ward_group",
      "baseline",
      "principal",
      "median",
      "lwr_ci",
      "upr_ci",
      "model_runs"
    ) |>
    dplyr::mutate(
      dplyr::across(
        "model_runs",
        purrr::map,
        tibble::enframe,
        name = "model_run"
      )
    ) |>
    tidyr::unnest("model_runs") |>
    dplyr::inner_join(get_variants(r), by = "model_run")
}

get_theatres_available <- function(r) {
  r$results$theatres_available |>
    dplyr::select(
      "tretspef",
      "baseline",
      "principal",
      "median",
      "lwr_ci",
      "upr_ci",
      "model_runs"
    )
}

trust_site_aggregation <- function(data) {
  data |>
    dplyr::filter(.data$sitetret != "trust") |>
    dplyr::group_by(
      dplyr::across(
        c(where(is.character), dplyr::matches("model_run"), -"sitetret")
      )
    ) |>
    dplyr::summarise(
      sitetret = "trust",
      dplyr::across(where(is.numeric), sum, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::bind_rows(data)
}
