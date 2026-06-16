get_params <- function(r) {
  is_scalar_numeric <- \(x) rlang::is_scalar_atomic(x) && is.numeric(x)

  to_interval <- function(x) {
    if (
      length(x) == 2 && purrr::every(x, is_scalar_numeric) && is.null(names(x))
    ) {
      x |>
        purrr::flatten_dbl() |>
        purrr::set_names(c("lo", "hi"))
    } else {
      x
    }
  }

  recursive_discard <- function(x) {
    if (!is.list(x)) {
      return(x)
    }

    x |>
      purrr::map(recursive_discard) |>
      purrr::discard(\(.y) length(.y) == 0) |>
      to_interval()
  }

  recursive_discard(r$params)
}

get_model_run_from_ats <- function(dataset, model_run_id) {
  azkit::read_azure_table_single_entity(
    Sys.getenv("AZ_TABLE_NAME"),
    dataset,
    model_run_id,
    Sys.getenv("AZ_TABLE_EP")
  )
}

get_results_from_azure <- function(directory) {
  container <- azkit::get_container(
    container_name = Sys.getenv("AZ_STORAGE_CONTAINER"),
    endpoint_url = Sys.getenv("AZ_STORAGE_EP")
  )

  blobs <- AzureStor::list_blobs(container, directory) |> dplyr::pull(name)
  params_file <- blobs[grepl("params\\.json$", blobs)]
  variants_file <- blobs[grepl("variants\\.json$", blobs)]
  parquet_files <- blobs[grepl("\\.parquet$", blobs)]
  results_names <- parquet_files |> basename() |> tools::file_path_sans_ext()

  params <- azkit::read_azure_json(container, params_file)
  population_variants <- azkit::read_azure_json(container, variants_file)
  results <- purrr::map(
    parquet_files,
    \(file) azkit::read_azure_parquet(container, file)
  ) |>
    purrr::set_names(results_names)

  dplyr::lst(params, population_variants, results)
}

get_results_from_local <- function(directory) {
  files <- list.files(directory, full.names = TRUE)
  params_file <- files[grepl("params\\.json$", files)]
  variants_file <- files[grepl("variants\\.json$", files)]
  parquet_files <- files[grepl("\\.parquet$", files)]
  results_names <- parquet_files |> basename() |> tools::file_path_sans_ext()

  params <- yyjsonr::read_json_file(params_file)
  population_variants <- yyjsonr::read_json_file(variants_file)
  results <- parquet_files |>
    purrr::map(arrow::read_parquet) |>
    purrr::set_names(results_names)

  dplyr::lst(params, population_variants, results)
}

get_user_allowed_datasets <- function(groups) {
  p <- yyjsonr::read_json_file(
    app_sys("app", "data", "providers.json")
  )

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
      \(.x) {
        .x |>
          dplyr::pull("pod") |>
          stringr::str_extract("^[a-z]*") |>
          unique()
      }
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
    dplyr::mutate(dplyr::across(
      "pod",
      ~ ifelse(
        stringr::str_starts(.x, "aae"),
        "aae",
        .x
      )
    )) |>
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
      .data$pod %in% .env$pod,
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

get_principal_change_factors <- function(r, activity_type, sites) {
  stopifnot(
    "Invalid activity_type" = activity_type %in% c("aae", "ip", "op")
  )

  r$results$step_counts |>
    dplyr::filter(.data$activity_type == .env$activity_type) |>
    dplyr::select(-where(is.list)) |>
    dplyr::mutate(dplyr::across(
      "strategy",
      \(.x) tidyr::replace_na(.x, "-")
    )) |>
    trust_site_aggregation(sites)
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
        c(
          tidyselect::where(is.character),
          tidyselect::where(is.factor),
          tidyselect::any_of(c("model_run", "year")),
          -"sitetret"
        )
      )
    ) |>
    dplyr::summarise(
      dplyr::across(where(is.numeric), \(.x) sum(.x, na.rm = TRUE)),
      .groups = "drop"
    )
}
