get_container <- function() {
  ep_uri <- Sys.getenv("AZ_STORAGE_EP")
  app_id <- Sys.getenv("AZ_APP_ID")

  token <- if (app_id != "") {
    AzureAuth::get_azure_token(
      "https://storage.azure.com",
      tenant = Sys.getenv("AZ_TENANT_ID"),
      app = app_id,
      auth_type = "device_code",
      use_cache = TRUE
    )
  } else {
    AzureAuth::get_managed_token("https://storage.azure.com/") |>
      AzureAuth::extract_jwt()
  }

  ep_uri |>
    AzureStor::blob_endpoint(token = token) |>
    AzureStor::storage_container(Sys.getenv("AZ_STORAGE_CONTAINER"))
}

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

get_result_sets <- function(
  allowed_datasets = get_user_allowed_datasets(NULL),
  folder = "prod"
) {
  ds <- tibble::tibble(dataset = allowed_datasets)

  cont <- get_container()

  cont |>
    AzureStor::list_blobs(folder, info = "all", recursive = TRUE) |>
    dplyr::filter(!.data[["isdir"]]) |>
    purrr::pluck("name") |>
    purrr::set_names() |>
    purrr::map(\(name, ...) AzureStor::get_storage_metadata(cont, name)) |>
    dplyr::bind_rows(.id = "file") |>
    dplyr::semi_join(ds, by = dplyr::join_by("dataset")) |>
    dplyr::mutate(
      dplyr::across("viewable", as.logical)
    )
}

get_results_from_azure <- function(filename) {
  cont <- get_container()

  AzureStor::download_blob(cont, filename, NULL) |>
    memDecompress(type = "gzip") |>
    yyjsonr::read_json_raw(
      yyjsonr::opts_read_json(
        obj_of_arrs_to_df = FALSE
      )
    ) |>
    parse_results()
}

get_results_from_local <- function(filename) {
  filename |>
    yyjsonr::read_json_file(
      yyjsonr::opts_read_json(
        obj_of_arrs_to_df = FALSE
      )
    ) |>
    parse_results()
}

parse_results <- function(r) {
  r$population_variants <- as.character(r$population_variants)

  r$results <- purrr::map(
    r$results,
    tibble::as_tibble
  )

  r$params <- patch_params(r$params)

  patch_results(r)
}

patch_params <- function(r) {
  if (is.list(r)) {
    return(purrr::map(r, patch_params))
  }

  if (is.numeric(r) && length(r) == 2) {
    return(as.list(r))
  }

  r
}

patch_principal <- function(results, name) {
  if (name == "step_counts") {
    return(patch_principal_step_counts(results))
  }

  dplyr::mutate(
    results,
    principal = purrr::map_dbl(.data[["model_runs"]], mean),
    median = purrr::map_dbl(.data[["model_runs"]], stats::quantile, 0.5),
    lwr_pi = purrr::map_dbl(.data[["model_runs"]], stats::quantile, 0.1),
    upr_pi = purrr::map_dbl(.data[["model_runs"]], stats::quantile, 0.9)
  )
}

patch_principal_step_counts <- function(results) {
  dplyr::mutate(
    results,
    value = purrr::map_dbl(.data[["model_runs"]], mean)
  )
}

patch_step_counts <- function(results) {
  if (!"strategy" %in% colnames(results$step_counts)) {
    results$step_counts <- dplyr::mutate(
      results$step_counts,
      strategy = NA_character_,
      .after = "change_factor"
    )
  }
  results
}

patch_results <- function(r) {
  r$results <- purrr::imap(r$results, patch_principal)
  r$results <- patch_step_counts(r$results)

  r$results[["tretspef+los_group"]] <- r$results[[
    "tretspef+los_group"
  ]] |>
    dplyr::mutate(
      dplyr::across(
        "los_group",
        \(.x) {
          forcats::lvls_expand(
            # order and include potentially missing levels
            .x,
            c(
              "0 days",
              "1 day",
              "2 days",
              "3 days",
              "4-7 days",
              "8-14 days",
              "15-21 days",
              "22+ days"
            )
          )
        }
      )
    ) |>
    dplyr::arrange(.data$pod, .data$measure, .data$sitetret, .data$los_group)

  r$results[["sex+age_group"]] <- r$results[["sex+age_group"]] |>
    dplyr::mutate(
      dplyr::across(
        "age_group",
        \(.x) {
          forcats::lvls_expand(
            # order and include potentially missing levels
            .x,
            c(
              "0",
              "1-4",
              "5-9",
              "10-15",
              "16-17",
              "18-34",
              "35-49",
              "50-64",
              "65-74",
              "75-84",
              "85+",
              "Unknown"
            )
          )
        }
      )
    ) |>
    dplyr::arrange(
      .data$pod,
      .data$measure,
      .data$sitetret,
      .data$sex,
      .data$age_group
    )

  r
}

get_user_allowed_datasets <- function(groups) {
  p <- jsonlite::read_json(
    app_sys("app", "data", "providers.json"),
    simplifyVector = TRUE
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

get_aggregation <- function(r, pod, measure, agg_col, sites) {
  agg_type <- agg_col

  if (agg_col != "tretspef") {
    agg_type <- glue::glue("sex+{agg_col}")
  }

  filtered_results <- r$results[[agg_type]] |>
    dplyr::filter(
      .data$pod %in% .env$pod,
      .data$measure == .env$measure
    ) |>
    dplyr::select(-"pod", -"measure")

  if (nrow(filtered_results) == 0) {
    return(NULL)
  }

  filtered_results |>
    dplyr::mutate(
      dplyr::across(dplyr::matches("sex|tretspef"), as.character)
    ) |>
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
