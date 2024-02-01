get_container <- function() {
  ep_uri <- Sys.getenv("AZ_STORAGE_EP")
  sa_key <- Sys.getenv("AZ_STORAGE_KEY")

  ep <- if (sa_key != "") {
    AzureStor::blob_endpoint(ep_uri, key = sa_key)
  } else {
    token <- AzureAuth::get_managed_token("https://storage.azure.com/") |>
      AzureAuth::extract_jwt()

    AzureStor::blob_endpoint(ep_uri, token = token)
  }
  AzureStor::storage_container(ep, Sys.getenv("AZ_STORAGE_CONTAINER"))
}

get_params <- function(r) {
  r$params
}

get_result_sets <- function(allowed_datasets = get_user_allowed_datasets(NULL),
                            app_version = "dev") {
  ds <- tibble::tibble(dataset = allowed_datasets)

  cont <- get_container()

  cont |>
    AzureStor::list_blobs(app_version, "all", TRUE) |>
    dplyr::filter(!.data[["isdir"]]) |>
    purrr::pluck("name") |>
    purrr::set_names() |>
    purrr::map(\(name, ...) AzureStor::get_storage_metadata(cont, name)) |>
    dplyr::bind_rows(.id = "file") |>
    dplyr::semi_join(ds, by = dplyr::join_by("dataset"))
}

get_results <- function(filename) {
  cont <- get_container()
  tf <- withr::local_tempfile()
  AzureStor::download_blob(cont, filename, tf)

  r <- readBin(tf, raw(), n = file.size(tf)) |>
    jsonlite::parse_gzjson_raw(simplifyVector = FALSE)

  r$population_variants <- as.character(r$population_variants)

  r$results <- purrr::map(
    r$results,
    purrr::map_dfr,
    purrr::modify_at,
    c("model_runs", "time_profiles"),
    purrr::compose(list, as.numeric)
  )

  r
}

get_user_allowed_datasets <- function(groups) {
  p <- jsonlite::read_json(app_sys("app", "data", "providers.json"), simplifyVector = TRUE)

  if (!(is.null(groups) || any(c("nhp_devs", "nhp_power_users") %in% groups))) {
    a <- groups |>
      stringr::str_subset("^nhp_provider_") |>
      stringr::str_remove("^nhp_provider_")
    p <- intersect(p, a)
  }

  c("synthetic", p)
}

get_trust_sites <- function(r) {
  r$results$default$sitetret |>
    sort() |>
    unique()
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

get_principal_high_level <- function(r, measures, sites) {
  r$results$default |>
    dplyr::filter(.data$measure %in% measures) |>
    dplyr::select("pod", "sitetret", "baseline", "principal") |>
    dplyr::mutate(dplyr::across("pod", ~ ifelse(
      stringr::str_starts(.x, "aae"), "aae", .x
    ))) |>
    dplyr::group_by(.data$pod, .data$sitetret) |>
    dplyr::summarise(dplyr::across(where(is.numeric), sum), .groups = "drop") |>
    trust_site_aggregation(sites)
}

get_model_core_activity <- function(r, sites) {
  r$results$default |>
    dplyr::select(-"model_runs") |>
    trust_site_aggregation(sites)
}

get_variants <- function(r) {
  r$population_variants |>
    utils::tail(-1) |>
    tibble::enframe("model_run", "variant")
}

get_model_run_distribution <- function(r, pod, measure, sites) {
  filtered_results <- r$results$default |>
    dplyr::filter(
      .data$pod == .env$pod,
      .data$measure == .env$measure
    ) |>
    dplyr::select("sitetret", "baseline", "principal", "model_runs")

  if (nrow(filtered_results) == 0) {
    return(NULL)
  }

  filtered_results |>
    dplyr::mutate(
      dplyr::across(
        "model_runs",
        \(.x) purrr::map(.x, tibble::enframe, name = "model_run")
      )
    ) |>
    tidyr::unnest("model_runs") |>
    dplyr::inner_join(get_variants(r), by = "model_run") |>
    trust_site_aggregation(sites)
}

get_aggregation <- function(r, pod, measure, agg_col, sites) {
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
    trust_site_aggregation(sites)
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
      "ward_type",
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
        \(.x) purrr::map(.x, tibble::enframe, name = "model_run")
      )
    ) |>
    tidyr::unnest("model_runs") |>
    dplyr::inner_join(get_variants(r), by = "model_run")
}

trust_site_aggregation <- function(data, sites) {
  data_filtered <- if (length(sites) == 0) {
    data
  } else {
    dplyr::filter(data, .data$sitetret %in% sites)
  }

  data_filtered |>
    dplyr::group_by(
      dplyr::across(
        c(tidyselect::where(is.character), dplyr::matches("model_run|year"), -"sitetret")
      )
    ) |>
    dplyr::summarise(
      dplyr::across(where(is.numeric), \(.x) sum(.x, na.rm = TRUE)),
      .groups = "drop"
    )
}

get_time_profiles <- function(r, result) {
  start_year <- r$params[["start_year"]]
  end_year <- r$params[["end_year"]]

  years <- c(start_year:end_year) |>
    tibble::enframe("year_n", "year") |>
    dplyr::mutate(dplyr::across("year_n", \(.x) .x - 1))

  df <- r$results[[result]] |>
    dplyr::select(-tidyselect::matches("^(model_runs|.*_ci|median)"))

  dplyr::bind_rows(
    df |>
      dplyr::select(-"time_profiles", -"principal") |>
      dplyr::rename(value = "baseline") |>
      dplyr::mutate(year_n = 0),
    df |>
      dplyr::select(-"baseline", -"principal") |>
      dplyr::mutate(
        dplyr::across(
          "time_profiles",
          \(.x) purrr::map(.x, tibble::enframe, "year_n")
        )
      ) |>
      tidyr::unnest("time_profiles"),
    df |>
      dplyr::select(-"time_profiles", -"baseline") |>
      dplyr::rename(value = "principal") |>
      dplyr::mutate(year_n = end_year - start_year)
  ) |>
    dplyr::inner_join(years, by = dplyr::join_by("year_n")) |>
    dplyr::select(-"year_n")
}
