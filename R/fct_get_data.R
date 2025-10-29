#' Get Azure storage container
#'
#' @description Authenticates to Azure and returns a storage container object.
#'   Uses either device code authentication or managed identity depending on
#'   environment configuration.
#'
#' @return Azure storage container object.
#'
#' @noRd
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

#' Get parameters from results object
#'
#' @description Extracts and cleans parameters from results object, converting
#'   two-element numeric vectors to named intervals with "lo" and "hi" elements,
#'   and removing empty list elements.
#'
#' @param r List. Results object containing params element.
#'
#' @return List. Cleaned parameters with intervals formatted and empty
#'   elements removed.
#'
#' @noRd
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

#' Get available result sets from Azure
#'
#' @description Lists all available result files in Azure storage that match
#'   the user's allowed datasets, with their metadata.
#'
#' @param allowed_datasets Character vector. Dataset identifiers the user
#'   has permission to access. Defaults to all datasets allowed for NULL user.
#' @param folder Character. The folder path in Azure storage to search.
#'   Defaults to "prod".
#'
#' @return Tibble containing file paths and metadata for available result sets.
#'
#' @noRd
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

#' Get results from Azure storage
#'
#' @description Downloads a results file from Azure storage, decompresses it,
#'   parses the JSON, and processes the results.
#'
#' @param filename Character. The path to the file in Azure storage.
#'
#' @return List. Parsed and processed results data structure.
#'
#' @noRd
get_results_from_azure <- function(filename) {
  cont <- get_container()
  tf <- withr::local_tempfile()
  AzureStor::download_blob(cont, filename, tf)

  readBin(tf, raw(), n = file.size(tf)) |>
    jsonlite::parse_gzjson_raw(simplifyVector = FALSE) |>
    parse_results()
}

#' Get results from local file
#'
#' @description Reads a results JSON file from local storage and processes it.
#'
#' @param filename Character. The path to the local JSON file.
#'
#' @return List. Parsed and processed results data structure.
#'
#' @noRd
get_results_from_local <- function(filename) {
  jsonlite::read_json(filename, simplifyVector = FALSE) |>
    parse_results()
}

#' Parse results data
#'
#' @description Processes raw results data by converting population variants
#'   to character, transforming model runs to data frames, and applying patches.
#'
#' @param r List. Raw results data from JSON.
#'
#' @return List. Parsed and patched results data structure.
#'
#' @noRd
parse_results <- function(r) {
  r$population_variants <- as.character(r$population_variants)

  r$results <- purrr::map(
    r$results,
    purrr::map_dfr,
    purrr::modify_at,
    c("model_runs"),
    purrr::compose(list, as.numeric)
  )

  patch_results(r)
}

#' Patch principal projection statistics
#'
#' @description Adds principal projection statistics (mean, median, and
#'   prediction intervals) to results data. Handles step_counts separately.
#'
#' @param results Data frame. Results data containing model_runs column.
#' @param name Character. The name of the results dataset.
#'
#' @return Data frame. Results with added principal, median, lwr_pi, and
#'   upr_pi columns (or value column for step_counts).
#'
#' @noRd
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

#' Patch principal step counts
#'
#' @description Adds mean value column to step_counts results.
#'
#' @param results Data frame. Step counts results with model_runs column.
#'
#' @return Data frame. Results with added value column containing means.
#'
#' @noRd
patch_principal_step_counts <- function(results) {
  dplyr::mutate(
    results,
    value = purrr::map_dbl(.data[["model_runs"]], mean)
  )
}

#' Patch step counts structure
#'
#' @description Ensures step_counts has a strategy column, adding it as NA
#'   if missing (for backwards compatibility).
#'
#' @param results List. Results object containing step_counts element.
#'
#' @return List. Results with patched step_counts structure.
#'
#' @noRd
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

#' Patch results data structure
#'
#' @description Applies multiple patches to results including adding principal
#'   statistics, ensuring proper factor levels for length of stay and age groups,
#'   and sorting data appropriately.
#'
#' @param r List. Results object to be patched.
#'
#' @return List. Fully patched results data structure.
#'
#' @noRd
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

#' Get user's allowed datasets
#'
#' @description Determines which datasets a user has permission to access based
#'   on their group memberships. Devs and power users get all datasets, while
#'   others get only their provider-specific datasets.
#'
#' @param groups Character vector. User's group memberships, or NULL.
#'
#' @return Character vector. Dataset identifiers the user can access, always
#'   including "synthetic".
#'
#' @noRd
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

#' Get trust sites from results
#'
#' @description Extracts unique site codes from results data in sorted order.
#'
#' @param r List. Results object containing default results with sitetret column.
#'
#' @return Character vector. Sorted unique site codes.
#'
#' @noRd
get_trust_sites <- function(r) {
  r$results$default$sitetret |>
    sort() |>
    unique()
}

#' Get available aggregations from results
#'
#' @description Identifies which aggregation types are available for each
#'   activity type (extracted from pod prefixes).
#'
#' @param r List. Results object.
#'
#' @return Named list. Activity types as names, with vectors of available
#'   aggregation types as values.
#'
#' @noRd
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

#' Get model run years
#'
#' @description Extracts the start and end years from model parameters.
#'
#' @param r List. Results object containing params.
#'
#' @return List with start_year and end_year elements.
#'
#' @noRd
get_model_run_years <- function(r) {
  r$params[c("start_year", "end_year")]
}

#' Get principal high-level summary
#'
#' @description Aggregates baseline and principal projections by POD,
#'   grouping A&E pods together, and applying site filtering.
#'
#' @param r List. Results object.
#' @param measures Character vector. Measures to include in the summary.
#' @param sites Character vector. Site codes to filter by (empty for all sites).
#'
#' @return Data frame. Aggregated baseline and principal values by POD.
#'
#' @noRd
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

#' Get model core activity data
#'
#' @description Retrieves default results excluding model runs, aggregated
#'   by selected sites.
#'
#' @param r List. Results object.
#' @param sites Character vector. Site codes to filter by (empty for all sites).
#'
#' @return Data frame. Core activity data aggregated by site selection.
#'
#' @noRd
get_model_core_activity <- function(r, sites) {
  r$results$default |>
    dplyr::select(-"model_runs") |>
    trust_site_aggregation(sites)
}

#' Get population variants
#'
#' @description Extracts population variants from results, excluding the first
#'   element (principal projection), and formats as a tibble.
#'
#' @param r List. Results object containing population_variants.
#'
#' @return Tibble with model_run index and variant name columns.
#'
#' @noRd
get_variants <- function(r) {
  r$population_variants |>
    utils::tail(-1) |>
    tibble::enframe("model_run", "variant")
}

#' Get model run distribution data
#'
#' @description Retrieves distribution of model runs for specified PODs and
#'   measure, joining with population variants and aggregating by sites.
#'
#' @param r List. Results object.
#' @param pod Character vector. POD identifiers to filter by.
#' @param measure Character. Measure to filter by.
#' @param sites Character vector. Site codes to filter by (empty for all sites).
#'
#' @return Data frame. Model run distribution with variants, or NULL if no
#'   matching data.
#'
#' @noRd
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

#' Get aggregated results by dimension
#'
#' @description Retrieves results aggregated by a specific dimension
#'   (e.g., age_group, tretspef) for given PODs and measure.
#'
#' @param r List. Results object.
#' @param pod Character vector. POD identifiers to filter by.
#' @param measure Character. Measure to filter by.
#' @param agg_col Character. Aggregation column name (e.g., "age_group",
#'   "tretspef").
#' @param sites Character vector. Site codes to filter by (empty for all sites).
#'
#' @return Data frame. Aggregated results, or NULL if no matching data.
#'
#' @noRd
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

#' Get principal change factors
#'
#' @description Extracts step counts showing the impact of each change factor
#'   for a specific activity type, aggregated by sites.
#'
#' @param r List. Results object containing step_counts.
#' @param activity_type Character. Activity type code: "aae", "ip", or "op".
#' @param sites Character vector. Site codes to filter by (empty for all sites).
#'
#' @return Data frame. Change factors with values by change factor and strategy.
#'
#' @noRd
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

#' Aggregate data by trust sites
#'
#' @description Filters data to selected sites and aggregates numeric columns
#'   while grouping by character, factor, and key identifier columns
#'   (excluding sitetret).
#'
#' @param data Data frame. Data to be aggregated.
#' @param sites Character vector. Site codes to filter by. If empty, all sites
#'   are included.
#'
#' @return Data frame. Aggregated data with numeric values summed across sites.
#'
#' @noRd
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
